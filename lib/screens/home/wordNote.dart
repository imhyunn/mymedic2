import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<String> wordlist = <String>[
    'apple',
    'home',
  ];
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  final List<String> krword = <String>['사과', '집'];

  void renew() {
    setState(() {
      wordlist.add(_engController.text);
      krword.add(_krController.text);
      _engController.clear();
      _krController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
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
      body: ListView.separated(
          itemCount: wordlist.length,
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
                                wordlist[index],
                                style: TextStyle(fontSize: 19),
                              ),
                            ),
                            Container(
                              height: 100,
                              child: Text(
                                krword[index],
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
                          _popUpbutton();
                        },
                        child: Container(
                          width: size.width * 0.2,
                          height: size.width * 0.2,
                          child: DottedBorder(
                            radius: Radius.circular(20),
                            color: Colors.grey,
                            child: Center(
                              child: Icon(Icons.add),
                              // child: Container(
                              //
                              //   // decoration: BoxDecoration(
                              //   //   image: DecorationImage(
                              //   //       image: FileImage(File(_pickedFile!.path)),
                              //   //       fit: BoxFit.cover),
                              //   // ),
                              // ),
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
          }),
    );
  }

  RelativeRect buttonMenuPosition(BuildContext context) {
    final bool isEnglish = false;
    final RenderBox bar = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    const Offset offset = Offset.zero;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(
            isEnglish
                ? bar.size.centerRight(offset)
                : bar.size.centerLeft(offset),
            ancestor: overlay),
        bar.localToGlobal(
            isEnglish
                ? bar.size.centerRight(offset)
                : bar.size.centerLeft(offset),
            ancestor: overlay),
      ),
      offset & overlay.size,
    );
    return position;
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
                    var result = Navigator.pop(context, true);
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

  _getCameraImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  _getPhotoLibraryImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = _pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  _popUpbutton() {
    final position =
    buttonMenuPosition(context);
    showMenu(context: context, position: position, items: [
      PopupMenuItem<Menu>(
        value: Menu.camera,
        onTap: () {
          _getCameraImage();
        },
        child: ListTile(
          leading:
          Icon(Icons.camera_alt_outlined),
          title: Text('사진 찍기'),
        ),
      ),
      PopupMenuItem<Menu>(
        value: Menu.gallery,
        onTap: () {
          _getPhotoLibraryImage();
        },
        child: ListTile(
          leading: Icon(Icons.image),
          title: Text('라이브러리에서 불러오기'),
        ),
      ),
      PopupMenuItem<Menu>(
        value: Menu.drawing,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DrawingPage()));
        },
        child: ListTile(
          leading: Icon(Icons.draw_outlined),
          title: Text('직접 그리기'),
        ),
      ),
    ]);
  }
}
