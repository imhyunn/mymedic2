import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:mymedic1/data/word.dart';
import 'package:mymedic1/screens/home/drawing.dart';

import 'package:mymedic1/config/palette.dart';

enum Menu { camera, gallery, drawing }

class WordInfo {
  bool isChecked;
  ImageProvider? pickedFile;
  Word word;

  WordInfo(this.isChecked, this.pickedFile, this.word);
}

class WordNoteEdit extends StatefulWidget {
  const WordNoteEdit(this.words, {super.key, required this.folder});

  final Folder folder;
  final List<Word> words;

  @override
  State<WordNoteEdit> createState() => _WordNoteEditState();
}

class _WordNoteEditState extends State<WordNoteEdit> {
  List<ImageProvider?> _pickedFiles = [];
  List<bool> _isModifiedImage = [];
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  late Offset _tapPosition;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List<bool> _isChecked = [];
  List<WordInfo> wordInfo = [];

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

    for (int i = 0; i< widget.words.length; ++i){
      if (widget.words[i].imagePath == null) {
        wordInfo[i].pickedFile = null;
      }
      else if (widget.words[i].imagePath != null) {
        wordInfo[i].pickedFile = NetworkImage(widget.words[i].imagePath!);
      }


      _isModifiedImage.add(false);
      wordInfo[i].isChecked = false;
    }



    super.initState();
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
                  var result = await getFolder();
                  moveWord(result);
                },
                icon: Icon(Icons.drive_file_move_outline)),
            IconButton(
                onPressed: () async {
                  var result = await _addword(context);
                  if (result!) {
                    renew();
                  }
                },
                icon: Icon(Icons.add)),
            IconButton(
                onPressed: () async {
                  await uploadImages();
                  await updateWords();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.check))
          ],
        ),
        body: ListView.separated(
            itemCount: widget.words.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
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
                                _edit(widget.words[index]);
                                break;
                              case "삭제":
                                _confirmDelete(widget.words[index], index);
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
                                value: _isChecked[index],
                                activeColor: Color(0xff2a5fa9),
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked[index] = value!;
                                  });
                                })),
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
                                    widget.words[index].english,
                                    style: TextStyle(fontSize: 19),
                                  ),
                                ),
                                Container(
                                  height: 35,
                                  child: Text(
                                    widget.words[index].korean,
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
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
                            width: size.width * 0.28,
                            height: size.width * 0.28,
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
                                              fit: BoxFit.contain),
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
            }));
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
                  onPressed: () {
                    _isChecked.add(false);
                    setState(() {
                      widget.words.add(Word(
                          _engController.text,
                          _krController.text,
                          DateTime.now().toString(),
                          null,
                          null,
                          widget.folder.id));
                      _pickedFiles.add(null);
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
  }

  _getCameraImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFiles[index] = FileImage(File(pickedFile.path));
        _isModifiedImage[index] = true;
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
        _isModifiedImage[index] = true;
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
              _pickedFiles[index] = result; // 새로운 값
              _isModifiedImage[index] = true;
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
    for (int i = 0; i < widget.words.length; i++) {
      if (widget.words[i].id == null) {
        await _firestore.collection('words').doc().set({
          'english': widget.words[i].english,
          'image': null,
          'korean': widget.words[i].korean,
          'time': DateTime.now().toString(),
          'folderId': widget.folder.id
        });
      } else if (widget.words[i].id != null) {
        await _firestore.collection('words').doc(widget.words[i].id).set({
          'english': widget.words[i].english,
          'image': widget.words[i].imagePath,
          'korean': widget.words[i].korean,
          'time': widget.words[i].time,
          'folderId': widget.folder.id
        });
      }
    }
    await _firestore
        .collection('folder')
        .doc(widget.folder.id)
        .set({'name': widget.folder.name, 'wordCount': widget.words.length});
  }

  Future<void> uploadImages() async {
    for (int i = 0; i < _pickedFiles.length; i++) {
      if (_pickedFiles[i] != null && _isModifiedImage[i]) {
        var dateTime = DateTime.now().toString().replaceAll(' ', '_');
        var ref = _firebaseStorage.ref().child("wordImages/$dateTime.jpg");

        if (_pickedFiles[i] is FileImage) {
          var image = _pickedFiles[i] as FileImage;
          var putFile = ref.putFile(File(image.file.path),
              SettableMetadata(contentType: "image/jpeg"));
          var complete = await putFile.whenComplete(() => {});
          var url = await complete.ref.getDownloadURL();

          widget.words[i].imagePath = url;
        } else if (_pickedFiles[i] is MemoryImage) {
          var image = _pickedFiles[i] as MemoryImage;
          var putFile = ref.putData(
              image.bytes, SettableMetadata(contentType: "image/jpeg"));
          var complete = await putFile.whenComplete(() => {});
          var url = await complete.ref.getDownloadURL();

          widget.words[i].imagePath = url;
        }
      }
    }
  }

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
                    _isChecked.removeAt(index);
                    _pickedFiles.removeAt(index);
                    setState(() {
                      widget.words.remove(word);
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
        .where('name', isNotEqualTo: widget.folder.name)
        .get();

    return snapshot.docs.map((element) {
      var data = element.data();
      return Folder(data['name'], data['wordCount'], element.id);
    }).toList();
  }

  moveWord(List<Folder> folder) {
    showModalBottomSheet(
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
                                for (int i = 0; i < _isChecked.length; i++) {
                                  if (_isChecked[i] == true) {
                                    await _firestore
                                        .collection('words')
                                        .doc(widget.words[i].id)
                                        .set({
                                      'english': widget.words[i].english,
                                      'folderId': folder[index].id,
                                      'image': widget.words[i].imagePath,
                                      'korean': widget.words[i].korean,
                                      'time': widget.words[i].time
                                    });

                                    moveWords.add(widget.words[i]);
                                  }
                                }

                                while (moveWords.isNotEmpty) {
                                  widget.words.remove(moveWords[0]);
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
