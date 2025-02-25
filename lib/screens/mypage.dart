import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/screens/sign/signup_screen.dart';

import '../config/palette.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class User {
  String email;
  String level;
  String password;
  String userName;
  String id;

  User(this.email, this.level, this.password, this.userName, this.id);
}

class _MyPageState extends State<MyPage> {
  XFile? _pickedFile;
  Map<String, dynamic> _userData = {};
  String _username = "";
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    if (userData.exists) {
      setState(() {
        _userData = userData.data()!;
        _username = _userData['userName'];
        print(_username);
      });
    }
    print(_userData);


  }

  Future<List<User>> _getUser() async {
    var snapshot = await _firestore.collection('user').get();
    List<User> user = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return User(map['email'], map['level'], map['password'], map['userName'], element.id);
    }).toList();
    return user;
  }



  Future<void> saveImage(XFile image) async {
    var dateTime = DateTime.now().toString().replaceAll(' ', '_');
     var ref = _firebaseStorage.ref().child("images/$dateTime.jpg");
     // 해결했다 ^^... 2024-08-30 20:51 - 원인은 라이브러리 버전... App Check token 뭐시기 그거는 에러가 아니래..
    var putFile = ref.putFile(File(image.path), SettableMetadata(contentType: "image/jpeg"));

    var complete = await putFile.whenComplete(() => {});
    var s = await complete.ref.getDownloadURL();
    print(s);
  }

  @override
  void initState() {
    _getUserProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _imageSize = MediaQuery.of(context).size.width / 4;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('my page'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                Container(
                  constraints: BoxConstraints(
                    minHeight: _imageSize,
                    minWidth: _imageSize,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _showBottomSheet();
                    },
                    child: _pickedFile == null
                        ? Center(
                            child: Icon(
                              Icons.account_circle,
                              size: _imageSize,
                            ),
                          )
                        : Center(
                            child: Container(
                              width: _imageSize,
                              height: _imageSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                image: DecorationImage(
                                    image: FileImage(File(_pickedFile!.path)),
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(_username, style: TextStyle(fontSize: 19),),
                    Text('초등학교3학년'),
                  ],),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  level() {

  }

  _showBottomSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    var image = await _getCameraImage();
                    if (image != null) {
                      await saveImage(image);
                    }
                    // 스토리지에 위에서 가져온 이미지를 저장하는 코드
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '사진찍기',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _getPhotoLibraryImage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '라이브러리에서 불러오기',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  Future<XFile?> _getCameraImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      return pickedFile;
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
      return null;
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
}
