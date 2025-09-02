import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/palette.dart';

class MyPageEdit extends StatefulWidget {
  const MyPageEdit({super.key});

  @override
  State<MyPageEdit> createState() => _MyPageEditState();
}

class _MyPageEditState extends State<MyPageEdit> {
  XFile? _pickedFile;
  ImageProvider? ImageFile;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> appUsers = Map();
  String _username = "";
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  User? loggedUser;
  final currentUser = FirebaseAuth.instance.currentUser;

  String userImagePath = '';

  void _getUserProfile() async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _userData = userData.data()!;
          _username = _userData['userName'];
        });
      }
    }
  }

  Future<void> _getProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userImage =
          await _firestore.collection('user').doc(currentUser.uid).get();
      userImagePath = userImage.data()!['profileImagePath'];
    } else {
      print("User is not logged in.");
    }

    if (userImagePath != 'null') {
      _pickedFile = XFile(userImagePath);
    }
  }

  Future<void> saveImage(XFile image) async {
    var dateTime = DateTime.now().toString().replaceAll(' ', '_');
    var ref = _firebaseStorage.ref().child("images/$dateTime.jpg");
    var putFile = ref.putFile(
        File(image.path), SettableMetadata(contentType: "image/jpeg"));

    var complete = await putFile.whenComplete(() => {});
    var s = await complete.ref.getDownloadURL();
    print(s);

    if (userImagePath != 'null') {
      final oldRef = FirebaseStorage.instance.refFromURL(userImagePath);
      await oldRef.delete();
    }

    await _firestore.collection('user').doc(currentUser!.uid).set({
      'birthDate': _userData['birthDate'],
      'email': _userData['email'],
      'password': _userData['password'],
      'phoneNumber': _userData['phoneNumber'],
      'profileImagePath': await complete.ref.getDownloadURL(),
      'userName': _username
    });

    // _getProfileImage();
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
              backgroundColor: Colors.white,
              title: Text(
                'my page',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
            ),
            body: FutureBuilder(
              future: _getProfileImage(),
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

                return Column(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              children: [
                                SizedBox(
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
                                    child: Center(
                                      child: ClipOval(
                                          child: _pickedFile == null
                                              ? Container(
                                                  width: _imageSize,
                                                  height: _imageSize,
                                                  child: FittedBox(
                                                    child: Icon(
                                                      Icons.account_circle,
                                                      size: _imageSize,
                                                    ),
                                                  ),
                                                )
                                              : Image(
                                                  width: _imageSize,
                                                  height: _imageSize,
                                                  fit: BoxFit.cover,
                                                  image: _pickedFile!.path
                                                          .startsWith('https')
                                                      ? NetworkImage(
                                                          _pickedFile!.path)
                                                      : FileImage(File(
                                                              _pickedFile!
                                                                  .path))
                                                          as ImageProvider,
                                                )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Container(
                                  height: 60,
                                  child: Column(
                                    children: [
                                      TextField(

                                      )
                                      // Text(
                                      //   _username,
                                      //   style: TextStyle(fontSize: 19),
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            )));
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
                      Navigator.of(context).pop();
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
      print(_pickedFile!.path);
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
        _pickedFile = pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }
}
