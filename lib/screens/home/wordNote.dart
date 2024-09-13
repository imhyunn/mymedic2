import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/data/word.dart';
import 'package:mymedic1/screens/home/drawing.dart';

import '../../config/palette.dart';

enum Menu { camera, gallery, drawing }

class WordNote extends StatefulWidget {
  const WordNote({super.key});

  @override
  State<WordNote> createState() => _WordNoteState();
}

class _WordNoteState extends State<WordNote> {
  XFile? _pickedFile;
  List<ImageProvider?> _pickedFiles = [];
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  late Offset _tapPosition;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void renew() {
    setState(() {
      _pickedFiles.add(null);
      _engController.clear();
      _krController.clear();
    });
  }

  Future<List<Word>> _getWord() async {
    var snapshot = await _firestore
        .collection('words')
        .orderBy('time', descending: true)
        .get();
    List<Word> words = snapshot.docs
        .map((element) => Word(
            element.data()['english'],
            element.data()['korean'],
            element.data()['time'],
            element.data()['image'],
            element.id))
        .toList();
    return words;
  }

  @override
  void initState() {
    // for (int i = 0; i < wordlist.length; ++i) {
    //   _pickedFiles.add(null);
    // }
    _getWord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await _addword(context);
                if (result!) {
                  renew();
                }
              },
              icon: Icon(Icons.add))
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

          final words = snap.requireData;

          return ListView.separated(
              itemCount: words.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    onTap: null,
                    title: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.volume_up_rounded,
                              size: size.width * 0.055,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 35,
                                  child: Text(
                                    words[index].english,
                                    style: TextStyle(fontSize: 19),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  child: Text(
                                    words[index].korean,
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => DrawingPage()));
                              _popUpbutton(index);
                            },
                            onTapDown: (details) {
                              _tapPosition = details.globalPosition;
                            },
                            child: Container(
                              width: size.width * 0.2,
                              height: size.width * 0.2,
                              child: DottedBorder(
                                radius: Radius.circular(20),
                                color: Colors.grey,
                                child: Center(
                                  child: _pickedFiles[index] == null
                                      ? Icon(Icons.add)
                                      : Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: _pickedFiles[index]!,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              });
        },
      ),
    );
  }

  RelativeRect buttonMenuPosition(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    return RelativeRect.fromRect(
        _tapPosition & Size(40, 40), Offset.zero & overlay.size);
  }

  Future<bool?> _addword(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '영단어 추가',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 20,
                controller: _engController,
                decoration: InputDecoration(
                  hintText: '영단어',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              TextField(
                maxLength: 20,
                controller: _krController,
                decoration: InputDecoration(
                  hintText: '뜻',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    var add = await _firestore.collection('words').add({
                      'english': _engController.text,
                      'korean': _krController.text,
                      'time': DateTime.now().toString(),
                      'image': null
                    });

                    var future = await add.get();
                    print(future.data().toString());
                    // doc().set({
                    //   'english': _engController.text,
                    //   'korean': _krController.text,
                    //   'image': null
                    // });
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ],
        );
      },
    );
  }

  _getCameraImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFiles[index] = FileImage(File(pickedFile.path));
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  _getPhotoLibraryImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFiles[index] = FileImage(File(pickedFile.path));
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  _popUpbutton(int index) {
    final position = buttonMenuPosition(context);
    showMenu(context: context, position: position, items: [
      PopupMenuItem<Menu>(
        value: Menu.camera,
        onTap: () {
          _getCameraImage(index);
        },
        child: ListTile(
          leading: Icon(Icons.camera_alt_outlined),
          title: Text('사진 찍기'),
        ),
      ),
      PopupMenuItem<Menu>(
        value: Menu.gallery,
        onTap: () {
          _getPhotoLibraryImage(index);
        },
        child: ListTile(
          leading: Icon(Icons.image),
          title: Text('라이브러리에서 불러오기'),
        ),
      ),
      PopupMenuItem<Menu>(
        value: Menu.drawing,
        onTap: () async {
          var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DrawingPage()))
              as MemoryImage?;

          if (result != null) {
            setState(() {
              _pickedFiles[index] = result;
            });
          }
        },
        child: ListTile(
          leading: Icon(Icons.draw_outlined),
          title: Text('직접 그리기'),
        ),
      ),
    ]);
  }
}
