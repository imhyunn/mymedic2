import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:mymedic1/data/levelWord.dart';
import 'package:mymedic1/data/user.dart';
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
  List<AppUser> appUser = [];
  final _formKey = GlobalKey<FormState>();
  bool _isButtonDisabled = false;

  // Future<List<AppUser>> _getUser() async {
  //   var userInfo = _firebaseAuth.currentUser;
  //   var userData = await FirebaseFirestore.instance
  //       .collection('user')
  //       .get();
  //
  //   List<AppUser> appUsers = userData.docs.map((element) {
  //     Map<String, dynamic> map = element.data();
  //     return AppUser(map['userName'], map['email'], map['password'], map['birthDate'], map['phoneNumber'], element.id);
  //   }).toList();
  //   return appUsers;
  // }

  final userInfo = FirebaseAuth.instance.currentUser;

  Future<List<Folder>> _getFolder() async {
    // final userData = await FirebaseFirestore.instance
    //     .collection('user')
    //     .doc(userInfo!.uid)
    //     .get();

    var snapshot = await _firestore
        .collection('folder')
        .where('userId', isEqualTo: userInfo!.uid)
        .orderBy('time', descending: true)
        .get();
    List<Folder> folders = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return Folder(map['name'], map['wordCount'], element.id, map['time'],
          map['userId']);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                setState(() {
                  _isButtonDisabled = true;
                });

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
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Color(0xfff1f8ff),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: ListTile(
                      // tileColor: Colors.white,
                      leading: Icon(Icons.folder),
                      title: Text(folders[index].name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '단어 수 : ${folders[index].wordCount} • ${_formatYmd(folders[index].time)}',
                          style: TextStyle(fontSize: 15)),
                      trailing: PopupMenuButton<String>(
                        color: Colors.white,
                        onSelected: (choice) {
                          switch (choice) {
                            case '수정':
                              _edit(folders[index]);
                              break;
                            case '삭제':
                              _folderDelete(folders[index].id);
                              break;
                          }
                        },
                        itemBuilder: (choice) => [
                          PopupMenuItem(value: '수정', child: Text('수정')),
                          PopupMenuItem(value: '삭제', child: Text('삭제')),
                        ],
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
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 1, color: Color(0x14000000))),
                );
              },
              itemCount: folders.length,
              // separatorBuilder: (context, index) {
              //   return Divider(height: 0.9);
              // }
            );
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLength: 40,
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
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '폴더명을 입력해주세요'
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _firestore.collection('folder').add({
                        'name': _folderController.text,
                        'time': DateTime.now().toString(),
                        'userId': userInfo!.uid,
                        'wordCount': 0,
                      });
                      setState(() {});
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
                maxLength: 40,
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
                      'time': folder.time,
                      'userId': userInfo!.uid,
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

  Future<void> _folderDelete(String id) async {
    final wordSnap = await _firestore
        .collection('words')
        .where('folderId', isEqualTo: id)
        .get();
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
                    print('wordSnap length: ${wordSnap.docs.length}');
                    for (final doc in wordSnap.docs) {
                      await doc.reference.delete();
                    }

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

  DateTime? _toDateTime(dynamic t) {
    if (t == null) return null;
    if (t is Timestamp) return t.toDate();
    if (t is DateTime) return t;
    if (t is String) return DateTime.tryParse(t);
    return null;
  }

  String _formatYmd(dynamic t) {
    final dt = _toDateTime(t);
    if (dt == null) return '-';
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }
}
