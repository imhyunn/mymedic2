import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:mymedic1/data/word.dart';
import 'package:mymedic1/screens/home/drawing.dart';
import 'package:mymedic1/screens/home/words/wordNote_edit.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../data/levelWord.dart';

enum Menu { camera, gallery, drawing }

class RecWordNote extends StatefulWidget {
  const RecWordNote({super.key, required this.folder});

  final Folder folder;

  @override
  State<RecWordNote> createState() => _RecWordNoteState();
}

class _RecWordNoteState extends State<RecWordNote> {
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<LevelWord> levelWords = [];

  final FlutterTts tts = FlutterTts();

  void renew() {
    setState(() {
      _engController.clear();
      _krController.clear();
    });
  }

  Future<List<LevelWord>> _getWord() async {
    var snapshot = await _firestore.collection('levelWord').get();
    List<LevelWord> levelWords = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return LevelWord(
        map['e3'],
        map['e4'],
        map['e5'],
        map['e6'],
        map['m1'],
        map['m2'],
        map['m3'],
        map['h1'],
        map['h2'],
        map['h3'],
        map['t1'],
        map['t2'],
        map['t3'],
        map['t4'],
        map['t5'],
        map['t6'],
        map['english'],
        map['korean'],
        element.id
      );
    }).toList();
    // for (int i = 0; i < words.length; ++i) _pickedFiles.add(null);
    return levelWords;
  }

  @override
  void initState() {
    // for (int i = 0; i < wordlist.length; ++i) {
    //   _pickedFiles.add(null);
    // }
    _getWord();
    super.initState();

    tts.setLanguage("en-US");
    tts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          IconButton(
              onPressed: () async {
                // A
                // await Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (BuildContext) =>
                //         WordNoteEdit(words, folder: widget.folder),
                //   ),
                // );
                // 갱신 코드
                setState(() {});
              },
              icon: Icon(Icons.mode_edit_outline))
        ],
      ),
      body: FutureBuilder(
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

          final LevelWords = snap.requireData;
          this.levelWords = LevelWords;
          return ListView.builder(
            itemCount: levelWords.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  onTap: null,
                  title: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          child: IconButton(
                            onPressed: () {
                              tts.speak(levelWords[index].english);
                            },
                            icon: Icon(
                              Icons.volume_up_rounded,
                              size: size.width * 0.055,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
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
                                    levelWords[index].english,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                Container(
                                  height: 35,
                                  child: Text(
                                    levelWords[index].korean,
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: size.width * 0.28,
                          height: size.width * 0.28,
                          child: DottedBorder(
                            radius: Radius.circular(20),
                            color: Colors.grey,
                            child: Center(
                                // child: words[index].imagePath == null
                                //     ? Text(
                                //         '편집 버튼을 눌러 \n사진을 추가해주세요.',
                                //         style: TextStyle(fontSize: 8),
                                //       )
                                //     : Image.network(
                                //         words[index].imagePath!,
                                //         fit: BoxFit.cover,
                                //       )
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(width: 1),
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
