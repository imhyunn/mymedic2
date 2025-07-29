import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:mymedic1/data/word.dart';
import 'package:mymedic1/screens/home/drawing.dart';

import 'package:mymedic1/config/palette.dart';

import '../../../data/AdHelper.dart';

enum Menu { camera, gallery, drawing }

class WordInfo {
  bool isChecked;
  ImageProvider? pickedFile;
  Word word;
  bool isModifiedImage;

  WordInfo(this.isChecked, this.pickedFile, this.word, this.isModifiedImage);
}

class WordNoteEdit extends StatefulWidget {
  const WordNoteEdit(this.words, {super.key, required this.folder});

  final Folder folder;
  final List<Word> words;

  @override
  State<WordNoteEdit> createState() => _WordNoteEditState();
}

class _WordNoteEditState extends State<WordNoteEdit> {
  // List<ImageProvider?> _pickedFiles = [];
  // List<bool> _isModifiedImage = [];
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  late Offset _tapPosition;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isButtonDisabled = false;

  // List<bool> _isChecked = [];
  List<WordInfo> wordInfos = [];

  void renew() {
    setState(() {
      _engController.clear();
      _krController.clear();
    });
  }

  @override
  void initState() {
    // for (int i = 0; i < widget.words.length; ++i) {
    //   if (widget.words[i].imagePath == null) {
    //     _pickedFiles.add(null);
    //   } else if (widget.words[i].imagePath != null) {
    //     _pickedFiles.add(NetworkImage(widget.words[i].imagePath!));
    //   }
    // }
    //
    // for (int i = 0; i < widget.words.length; ++i) {
    //   _isModifiedImage.add(false);
    //   _isChecked.add(false);
    // }

    for (int i = 0; i < widget.words.length; ++i) {
      WordInfo wordinfo = new WordInfo(
          false,
          widget.words[i].imagePath == null
              ? null
              : NetworkImage(widget.words[i].imagePath!),
          widget.words[i],
          false);
      wordInfos.add(wordinfo);
    }

    super.initState();
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

                  if (wordInfos.every((wordInfo) => !wordInfo.isChecked)) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                        content: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('선택된 단어가 없습니다.', style: TextStyle(fontSize: 17),)),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 다이얼로그 닫기
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.buttonColor2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            child: Text(
                              '확인',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    var result = await getFolder();
                    moveWord(result);
                  }
                  setState(() {
                    _isButtonDisabled = false;
                  });
                },
                icon: Icon(Icons.drive_file_move_outline)),
            IconButton(
                onPressed: () async {
                  if (_isButtonDisabled) return;

                  setState(() {
                    _isButtonDisabled = true;
                  });
                  var result = await _addword(context);
                  if (result == true) {
                    renew();
                  }
                  setState(() {
                    _isButtonDisabled = false;
                  });
                },
                icon: Icon(Icons.add)),
            IconButton(
                onPressed: () async {
                  if (_isButtonDisabled) return;

                  setState(() {
                    _isButtonDisabled = true;
                  });
                  await uploadImages();
                  await updateWords();

                  Navigator.pop(context);
                  setState(() {
                    _isButtonDisabled = false;
                  });
                },
                icon: Icon(Icons.check))
          ],
        ),
        body: ListView.builder(
          itemCount: wordInfos.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.white,
              child: ListTile(
                horizontalTitleGap: 0,
                contentPadding: EdgeInsets.only(left: 0, right: 0),
                trailing: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return ['수정', '삭제'].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                        onTap: () {
                          switch (choice) {
                            case "수정":
                              _edit(wordInfos[index].word);
                              break;
                            case "삭제":
                              _confirmDelete(wordInfos[index].word, index);
                              break;
                          }
                        },
                      );
                    }).toList();
                  },
                ),
                onTap: null,
                title: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                          // alignment: Alignment.topCenter,
                          child: Checkbox(
                              value: wordInfos[index].isChecked,
                              activeColor: Color(0xff2a5fa9),
                              onChanged: (value) {
                                setState(() {
                                  wordInfos[index].isChecked = value!;
                                });
                              })),
                      SizedBox(
                        width: 2,
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
                          width: size.width * 0.255,
                          height: size.width * 0.255,
                          child: DottedBorder(
                            radius: Radius.circular(20),
                            color: Colors.grey,
                            child: Center(
                              child: wordInfos[index].pickedFile == null
                                  ? Icon(Icons.add)
                                  : Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: wordInfos[index].pickedFile!,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                            ),
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
                                  wordInfos[index].word.english,
                                  style: TextStyle(
                                    fontSize:
                                        wordInfos[index].word.english.length >
                                                17
                                            ? 17
                                            : 20,
                                  ),
                                ),
                              ),
                              Container(
                                height: 35,
                                child: Text(
                                  wordInfos[index].word.korean,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          // separatorBuilder: (context, index) {
          //   return Divider();
          // },
        ));
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
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
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '영단어를 입력해주세요'
                      : null,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
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
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '뜻을 입력해주세요'
                      : null,
                ),
              ],
            ),
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
                  onPressed: () {
                    // _isChecked.add(false);
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        wordInfos.add(WordInfo(
                            false,
                            null,
                            Word(
                              _engController.text,
                              _krController.text,
                              DateTime.now().toString(),
                              null,
                              null,
                              widget.folder.id,
                              widget.folder.userId,
                              Random().nextDouble(),
                            ),
                            false));

                        // widget.words.add(Word(
                        //     _engController.text,
                        //     _krController.text,
                        //     DateTime.now().toString(),
                        //     null,
                        //     null,
                        //     widget.folder.id));
                        // _pickedFiles.add(null);
                      });
                      Navigator.pop(context, true);
                    }
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
        wordInfos[index].pickedFile = FileImage(File(pickedFile.path));
        wordInfos[index].isModifiedImage = true;
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
        wordInfos[index].pickedFile = FileImage(File(pickedFile.path));
        wordInfos[index].isModifiedImage = true;
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
              wordInfos[index].pickedFile = result; // 새로운 값
              wordInfos[index].isModifiedImage = true;
              print('hi');
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

  void _edit(Word word) {
    _engController.text = word.english;
    _krController.text = word.korean;

    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '영단어 수정',
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
                  onPressed: () {
                    setState(() {
                      word.english = _engController.text;
                      word.korean = _krController.text;
                    });
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
    // Navigator.pushNamed(
    //   context,
    //   arguments: widget.board,
    // ).then((result) {
    //   if (result != null) {
    //     var res = result as List<String>;
    //     setState(() {
    //       widget.words.k = res[0];
    //       widget.board.body = res[1];
    //     });
    //   }
    // });
  }

  Future<void> updateWords() async {
    for (int i = 0; i < wordInfos.length; i++) {
      if (wordInfos[i].word.id == null) {
        await _firestore.collection('words').doc().set({
          'english': wordInfos[i].word.english,
          'image': wordInfos[i].word.imagePath,
          'korean': wordInfos[i].word.korean,
          'time': DateTime.now().toString(),
          'folderId': widget.folder.id,
          'uid': widget.folder.userId,
          'randomIndex': Random().nextDouble()
        });
      } else if (wordInfos[i].word.id != null) {
        await _firestore.collection('words').doc(wordInfos[i].word.id).set({
          'english': wordInfos[i].word.english,
          'image': wordInfos[i].word.imagePath,
          'korean': wordInfos[i].word.korean,
          'time': wordInfos[i].word.time,
          'folderId': widget.folder.id,
          'uid': widget.folder.userId,
          'randomIndex': wordInfos[i].word.randomIndex
        });
      }
    }
    await _firestore.collection('folder').doc(widget.folder.id).set({
      'name': widget.folder.name,
      'time': widget.folder.time,
      'userId': widget.folder.userId,
      'wordCount': wordInfos.length,
    });
  }

  Future<void> uploadImages() async {
    for (int i = 0; i < wordInfos.length; i++) {
      // var imagePath = wordInfos[i].word.imagePath;

      if (wordInfos[i].pickedFile != null && wordInfos[i].isModifiedImage) {
        var dateTime = DateTime.now().toString().replaceAll(' ', '_');
        var ref = _firebaseStorage.ref().child("wordImages/$dateTime.jpg");

        if (wordInfos[i].pickedFile is FileImage) {
          var image = wordInfos[i].pickedFile as FileImage;
          var putFile = ref.putFile(File(image.file.path),
              SettableMetadata(contentType: "image/jpeg"));
          var complete = await putFile.whenComplete(() => {});
          var url = await complete.ref.getDownloadURL();

          // if (imagePath != url){
          //   final oldRef = FirebaseStorage.instance.refFromURL(imagePath!);
          //   await oldRef.delete();
          // }

          wordInfos[i].word.imagePath = url;
        } else if (wordInfos[i].pickedFile is MemoryImage) {
          var image = wordInfos[i].pickedFile as MemoryImage;
          var putFile = ref.putData(
              image.bytes, SettableMetadata(contentType: "image/jpeg"));
          var complete = await putFile.whenComplete(() => {});
          var url = await complete.ref.getDownloadURL();

          wordInfos[i].word.imagePath = url;
        }
      }
    }
  }

  //
  // Future<void> deleteOldImage(int index) async {
  //   if (wordInfos[index].pickedFile != )
  // }

  void _confirmDelete(Word word, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '단어 삭제',
          ),
          content: Text(
            '단어를 삭제할까요?',
          ),
          actions: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '아니오',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _firestore.collection('words').doc(word.id).delete();
                    wordInfos.removeAt(index);
                    setState(() {
                      wordInfos.remove(word);
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '예',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<List<Folder>> getFolder() async {
    var snapshot = await _firestore
        .collection('folder')
        .where('userId', isEqualTo: widget.folder.userId)
        .orderBy('time', descending: true)
        // .where('name', isNotEqualTo: widget.folder.name)
        .get();

    return snapshot.docs.map((element) {
      var data = element.data();
      return Folder(data['name'], data['wordCount'], element.id, data['time'],
          data['userId']);
    }).toList();
  }

  moveWord(List<Folder> folder) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '다른 폴더로 이동',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: folder.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(folder[index].name)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0)),
                          title: Text('단어 이동'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.buttonColor2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: const Text(
                                '아니오',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                List<Word> moveWords = [];
                                for (int i = 0; i < wordInfos.length; i++) {
                                  if (wordInfos[i].isChecked == true) {
                                    await _firestore
                                        .collection('words')
                                        .doc(wordInfos[i].word.id)
                                        .set({
                                      'english': wordInfos[i].word.english,
                                      'folderId': folder[index].id,
                                      'image': wordInfos[i].word.imagePath,
                                      'korean': wordInfos[i].word.korean,
                                      'time': wordInfos[i].word.time,
                                      'uid': widget.folder.userId,
                                      'randomIndex':
                                          wordInfos[i].word.randomIndex
                                    });

                                    moveWords.add(wordInfos[i].word);
                                  }
                                }

                                await _firestore
                                    .collection('folder')
                                    .doc(folder[index].id)
                                    .set({
                                  'name': folder[index].name,
                                  'time': widget.folder.time,
                                  'userId': widget.folder.userId,
                                  'wordCount':
                                      folder[index].wordCount + moveWords.length
                                });
                                await _firestore
                                    .collection('folder')
                                    .doc(widget.folder.id)
                                    .set({
                                  'name': widget.folder.name,
                                  'time': widget.folder.time,
                                  'userId': widget.folder.userId,
                                  'wordCount':
                                      widget.folder.wordCount - moveWords.length
                                });

                                while (moveWords.isNotEmpty) {
                                  wordInfos.removeWhere(
                                      (e) => e.word == moveWords[0]);
                                  // ??Where: 특정 조건에 맞는 ??을 실행하게끔 하는 것
                                  // 리스트가 대상이기에 그 리스트들을 순회하면서 그 조건에 맞는 것을 ?? 해주겠다.
                                  moveWords.removeAt(0);
                                }
                                setState(() {});

                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.buttonColor2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: const Text(
                                '예',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                          content:
                              Text('단어를 ${folder[index].name} 폴더로 이동시킬까요?'),
                        ),
                      );
                    },
                  ),
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(thickness: 1);
                  },
                ),
              )
            ]),
          );
        });
  }

  void handleClick(String value) {
    switch (value) {
      case '수정':
        break;
      case '삭제':
        break;
    }
  }
}
