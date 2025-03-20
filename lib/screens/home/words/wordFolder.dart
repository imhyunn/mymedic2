import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:mymedic1/data/levelWord.dart';
import 'package:mymedic1/screens/home/words/recWordNote.dart';
import 'package:mymedic1/screens/home/words/wordNote.dart';

import '../../../config/palette.dart';

class WordFolder extends StatefulWidget {
  const WordFolder({super.key});

  @override
  State<WordFolder> createState() => _WordFolderState();
}

class _WordFolderState extends State<WordFolder> {
  TextEditingController _folderController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? loggedUser;

  Future<void> _getUser() async {
    final userInfo = _firebaseAuth.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(userInfo!.uid)
        .get();
  }

  Future<List<Folder>> _getFolder() async {
    final userInfo = _firebaseAuth.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(userInfo!.uid)
        .get();

    var snapshot = await _firestore
        .collection('folder')
        .where('userId', isEqualTo: userData.id)
        .orderBy('time', descending: true)
        .get();
    List<Folder> folders = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return Folder(map['name'], map['wordCount'], element.id, map['time'], map['userId']);
    }).toList();
    return folders;
  }

  @override
  void initState() {
    // TODO: implement initState
    // _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                _folderController.clear();
                await _addFolder(context);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
          future: _getFolder(), // 데이터 불러오는 future 함수,,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Center(
                child: Text('오류가 발생했습니다.'),
              );
            }

            final folders = snapshot.requireData;
            // 스냅샷 -> 현재 불러온 날것의 데이터
            // 스냅샷의 상태에 따라 화면을 그려주는 부분
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(left: 20, top: 14, bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                folders[index].name,
                                style: TextStyle(fontSize: 23),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: Text(
                                '단어 수 : ${folders[index].wordCount}',
                                style: TextStyle(fontSize: 15),
                              ),
                            )
                          ],
                        ),
                      ),
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
                                    _edit(folders[index]);
                                    break;
                                  case "삭제":
                                    _folderDelete(folders[index].id);
                                    break;
                                }
                              },
                            );
                          }).toList();
                        },
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext) =>
                                WordNote(folder: folders[index]),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(width: 1)),
                  );
                },
                itemCount: folders.length,
                separatorBuilder: (context, index) {
                  return Divider(height: 0.9);
                });
          }),
    );
  }

  Future<bool?> _addFolder(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '폴더 추가',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 20,
                controller: _folderController,
                decoration: InputDecoration(
                  hintText: '폴더 이름',
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
                    await _firestore.collection('folder').add({
                      'name': _folderController.text,
                      'wordCount': 0,
                    });
                    setState(() {});
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

  void _edit(Folder folder) {
    _folderController.text = folder.name;

    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '폴더 수정',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 20,
                controller: _folderController,
                decoration: InputDecoration(
                  hintText: '폴더 이름',
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
                    await _firestore.collection('folder').doc(folder.id).set({
                      'name': _folderController.text,
                      'time': DateTime.now().toString(),
                      // 'userId': userData.id,
                      'wordCount': folder.wordCount,
                    });
                    setState(() {});
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

  void _folderDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '폴더 삭제',
          ),
          content: Text(
            '폴더를 삭제할까요?',
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
                    await _firestore.collection('folder').doc(id).delete();
                    setState(() {});
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

  void handleClick(String value) {
    switch (value) {
      case '수정':
        break;
      case '삭제':
        break;
    }
  }
}
