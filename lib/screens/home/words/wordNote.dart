import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/data/AdHelper.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:mymedic1/data/word.dart';
import 'package:mymedic1/screens/home/drawing.dart';
import 'package:mymedic1/screens/home/words/wordNote_edit.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum Menu { camera, gallery, drawing }

class WordNote extends StatefulWidget {
  const WordNote({super.key, required this.folder});

  final Folder folder;

  @override
  State<WordNote> createState() => _WordNoteState();
}

class _WordNoteState extends State<WordNote> {
  XFile? _pickedFile;
  List<ImageProvider?> _pickedFiles = [];
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Word> words = [];
  InterstitialAd? _interstitialAd;
  bool _isButtonDisabled = false;

  final FlutterTts tts = FlutterTts();

  void renew() {
    setState(() {
      _engController.clear();
      _krController.clear();
    });
  }

  Future<List<Word>> _getWord() async {
    var snapshot = await _firestore
        .collection('words')
        .where('folderId', isEqualTo: widget.folder.id)
        .orderBy('time', descending: true)
        .get();
    List<Word> words = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return Word(map['english'], map['korean'], map['time'], map['image'],
          element.id, map['folderId'], map['uid'], map['randomIndex']);
    }).toList();
    // for (int i = 0; i < words.length; ++i) _pickedFiles.add(null);
    return words;
  }

  void _createInterstitialAd() {
    // InterstitialAd.load(
    //     adUnitId: AdHelper.interstitialAdUnitId!,
    //     request: const AdRequest(),
    //     adLoadCallback: InterstitialAdLoadCallback(
    //         onAdLoaded: (ad) => _interstitialAd = ad,
    //         onAdFailedToLoad: (error) => _interstitialAd = null));

    final unitId = AdHelper.interstitialAdUnitId;
    if (unitId == null || unitId.isEmpty) {
      _interstitialAd = null;
      return;
    }

    InterstitialAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) => _interstitialAd = ad,
            onAdFailedToLoad: (error) => _interstitialAd = null));
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createInterstitialAd();
      });
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void initState() {
    super.initState();

    _createInterstitialAd();

    tts.setLanguage("en-US");
    tts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.folder.name),
        actions: [
          IconButton(
              onPressed: () async {
                if (_isButtonDisabled) return;

                setState(() {
                  _isButtonDisabled = true;
                });

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext) =>
                        WordNoteEdit(words, folder: widget.folder),
                  ),
                );

                // 갱신 코드
                setState(() {});
                _showInterstitialAd();

                setState(() {
                  _isButtonDisabled = false;
                });
              },
              icon: Icon(
                Icons.mode_edit_outline,
                // color: Colors.grey.shade800,
              ))
        ],
      ),
      body: FutureBuilder<List<Word>>(
        future: _getWord(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snap.hasError) {
            print(snap.error.toString());
            return Center(
              child: Text('오류가 발생했습니다.'),
            );
          }

          final words = snap.data ?? const <Word>[];
          this.words = words;

          if (words.isEmpty) {
            return _EmptyState();
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: words.length,
            separatorBuilder: (_, __) => SizedBox(
              height: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Card(
                // color: Color(0xfff1f8fd),
                clipBehavior: Clip.antiAlias,
                // color: Colors.white,
                child: ListTile(
                  dense: true,
                  onTap: null,
                  title: Row(children: [
                    Container(
                      width: size.width * 0.28,
                      height: size.width * 0.28,
                      child: ClipRRect(
                        // borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: words[index].imagePath == null
                              ? Text(
                                  '편집 버튼을 눌러 \n사진을 추가해주세요.',
                                  style: TextStyle(fontSize: 10),
                                )
                              : Image.network(
                                  words[index].imagePath!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Expanded(
                      child: Container(
                        height: 135,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 35,
                              child: Text(
                                words[index].english,
                                style: TextStyle(
                                    fontSize: words[index].english.length > 17
                                        ? 17
                                        : 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 35,
                              child: Text(
                                words[index].korean,
                                style: TextStyle(
                                  fontSize:
                                      words[index].korean.length > 17 ? 15 : 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: size.width * 0.28,
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          tts.speak(words[index].english);
                        },
                        icon: Icon(
                          Icons.volume_up_rounded,
                          size: size.width * 0.055,
                        ),
                      ),
                    ),
                  ]),
                  // trailing: Container(
                  //   // alignment: Alignment.topRight,
                  //   child: IconButton(
                  //     onPressed: () {
                  //       tts.speak(words[index].english);
                  //     },
                  //     icon: Icon(
                  //       Icons.volume_up_rounded,
                  //       size: size.width * 0.055,
                  //     ),
                  //   ),
                  // ),
                  // contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 12),
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(width: 1, color: Color(0x14000000)),
                ),
              );
            },
            // separatorBuilder: (context, index) {
            //   return Divider();
            // }
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  _EmptyState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              '오른쪽 위 연필 아이콘을 눌러 단어를 추가해 보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            )
          ],
        ),
      ),
    );
  }
}
