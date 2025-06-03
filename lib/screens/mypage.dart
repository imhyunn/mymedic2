import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/screens/home/home_screen.dart';
import 'package:mymedic1/screens/myapp.dart';
import 'package:mymedic1/screens/sign/login_screen.dart';
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
  ImageProvider? ImageFile;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> appUsers = Map();
  String _username = "";
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  User? loggedUser;
  final currentUser = FirebaseAuth.instance.currentUser;

  // AppUser? _appUser;
  // AppUser? get appUser => _appUser;
  String userImagePath = '';

  void _getUserProfile() async {
    final user = _firebaseAuth.currentUser;

    if(user != null) {
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

    // appUsers['birthDate'] = _userData['birthDate'];
    // appUsers['email'] = _userData['email'];
    // appUsers['password'] = _userData['password'];
    // appUsers['phoneNumber'] = _userData['phoneNumber'];
    // appUsers['profileImage'] = _userData['profileImage'];
    // appUsers['userName'] = _username;
    // print(_userData);
    // print('ss');
  }

  void _getProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userImage =
      await _firestore.collection('user').doc(currentUser.uid).get();
      userImagePath = userImage.data()!['profileImagePath'];

    } else {
      // 로그인되지 않은 상태 처리
      print("User is not logged in.");
    }

    // var userImage =
    //     await _firestore.collection('user').doc(currentUser!.uid).get();
    // userImagePath = userImage.data()!['profileImagePath'];


    if (userImagePath != 'null') {
      _pickedFile = XFile(userImagePath);


    }




  }

  //
  // Future<void> _getAppUser() async {
  //   var snap = await _firestore.collection('user').doc(currentUser!.uid).get();
  //
  //   if (snap.exists) {
  //     _appUser = AppUser(
  //       snap['userName'],
  //       snap['email'],
  //       snap['password'],
  //       snap['birthDate'],
  //       snap['phoneNumber'],
  //       snap.id,
  //       snap['profileImagePath'],
  //     );// UI 업데이트
  //   }
  //
  //
  //
  //   // List<AppUser> appUser = querySnapshot.docs.map((e) {
  //   //   return AppUser(e.data()['userName'], e.data()['email'], e.data()['password'], e.data()['birthDate'], e.data()['phoneNumber'], e.id, e.data()['profileImage']);
  //   // },).toList();
  //   //
  //   // return appUser;
  //
  //
  //
  // }

  Future<void> saveImage(XFile image) async {
    // final userProvider = context.read<UserProvider>();

    var dateTime = DateTime.now().toString().replaceAll(' ', '_');
    var ref = _firebaseStorage.ref().child("images/$dateTime.jpg");
    // 해결했다 ^^... 2024-08-30 20:51 - 원인은 라이브러리 버전... App Check token 뭐시기 그거는 에러가 아니래..
    var putFile = ref.putFile(
        File(image.path), SettableMetadata(contentType: "image/jpeg"));

    var complete = await putFile.whenComplete(() => {});
    var s = await complete.ref.getDownloadURL();
    print(s);

    await _firestore.collection('user').doc(currentUser!.uid).set({
      'birthDate' : _userData['birthDate'],
      'email' : _userData['email'],
      'password' : _userData['password'],
      'phoneNumber' : _userData['phoneNumber'],
      'profileImagePath' : await complete.ref.getDownloadURL(),
      'userName' : _username
    });

    _getProfileImage();
  }

  @override
  void initState() {
    _getUserProfile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    final _imageSize = MediaQuery.of(context).size.width / 4;
    _getProfileImage();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('my page'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 13,
            ),
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
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                image: DecorationImage(
                                  image: _pickedFile!.path.startsWith('https') ? NetworkImage(_pickedFile!.path) : FileImage(File(_pickedFile!.path)) as ImageProvider,
                                    // image: NetworkImage(_pickedFile!.path),
                                    // image: FileImage(File(_pickedFile!.path)),
                                    fit: BoxFit.cover),
                              ),
                              // child: Image.network(userProvider.appUser!.profileImagePath, fit: BoxFit.cover,),
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
                      Text(
                        _username,
                        style: TextStyle(fontSize: 19),
                      ),
                      // Text('${_userData['userLevel']}'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('logout'),
              onTap: () {

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0)),
                    title: Text('로그아웃하시겠습니까?'),
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
                          await _firebaseAuth.signOut();

                          try {
                            await FirebaseAuth.instance.signOut();
                            print('signout');

                            // 로그아웃이 성공적으로 되었는지 확인
                            if (FirebaseAuth.instance.currentUser == null) {
                              // 로그인 화면으로 이동 (예: '/login')
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                  builder: (context) => const LoginScreen()), (route) => false);
                            }
                          } catch (e) {
                            print('로그아웃 실패: $e');
                          }

                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (BuildContext) => LoginScreen(),
                          //   ),
                          // );
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
                    // content:
                    // Text('단어를 ${folder[index].name} 폴더로 이동시킬까요?'),
                  ),
                );


              },
            )
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
