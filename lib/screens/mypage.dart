import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/screens/myapp.dart';
import 'package:mymedic1/screens/sign/signup_screen.dart';
import 'package:provider/provider.dart';

import '../config/palette.dart';
import '../data/user.dart';
import '../data/user_provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}


class _MyPageState extends State<MyPage> {
  XFile? _pickedFile;
  Map<String, dynamic> _userData = {};
  String _username = "";
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  User? loggedUser;
  final currentUser = FirebaseAuth.instance.currentUser;

  //
  // void _getUserProfile() async {
  //   final userData = await FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(currentUser!.uid)
  //       .get();
  //   if (userData.exists) {
  //     setState(() {
  //       _userData = userData.data()!;
  //       _username = _userData['userName'];
  //     });
  //   }
  //   print(_userData);
  //
  //
  // }


  // Future<AppUser> _getAppUser() async {
  //   var querySnapshot = await _firestore.collection('user').get();
  //
  //   List<AppUser> appUsers = querySnapshot.docs.map((e) {
  //     return AppUser(e.data()['userName'], e.data()['email'], e.data()['password'], e.data()['birthDate'], e.data()['phoneNumber'], e.id, e.data()['profileImage']);
  //   },).toList();
  //
  //
  //   var snap = await _firestore.collection('user').doc(currentUser!.uid).get();
  //
  //   AppUser appUser =  AppUser(snap['userName'], snap['email'], snap['password'], snap['birthDate'], snap['phoneNumber'], snap.id, snap['profileImagePath']);
  //
  //
  //   return appUser;
  // }


  Future<void> saveImage(XFile image) async {
    final userProvider = context.read<UserProvider>();

    var dateTime = DateTime.now().toString().replaceAll(' ', '_');
    var ref = _firebaseStorage.ref().child("images/$dateTime.jpg");
     // 해결했다 ^^... 2024-08-30 20:51 - 원인은 라이브러리 버전... App Check token 뭐시기 그거는 에러가 아니래..
    var putFile = ref.putFile(File(image.path), SettableMetadata(contentType: "image/jpeg"));


    var complete = await putFile.whenComplete(() => {});


    await _firestore.collection('user').doc(currentUser!.uid).set({
      'birthDate' : userProvider.appUser!.birthDate,
      'email' : userProvider.appUser!.email,
      'password' : userProvider.appUser!.password,
      'phoneNumber' : userProvider.appUser!.phoneNumber,
      'profileImagePath' : await complete.ref.getDownloadURL(),
      'userName' : userProvider.appUser!.userName
    });

  }

  @override
  void initState() {
    // _getUserProfile();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final _imageSize = MediaQuery.of(context).size.width / 4;

    return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text('my page'),
            ),
            body: Column(
              children: [
                SizedBox(height: 13,),
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
                                  width: 1,
                                  color:
                                  Colors.grey),
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
                          Text(userProvider.appUser!.userName, style: TextStyle(fontSize: 19),),
                          // Text('${_userData['userLevel']}'),
                        ],),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

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
