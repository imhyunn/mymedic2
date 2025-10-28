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
import 'package:mymedic1/screens/mypage_edit.dart';
import 'package:mymedic1/screens/sign/login_screen.dart';
import 'package:mymedic1/screens/sign/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String userImagePath = ''; // ✅ CHANGED: 'null' 문자열 대신 빈 문자열 기본값으로

  int _cacheBuster = 0; // ✅ ADDED: 이미지 캐시 무효화를 위한 쿼리 파라미터 값

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
          userImagePath = _userData['profileImagePath'] ??
              ''; // ✅ ADDED: 기존 URL 보관(이전 파일 삭제용)
        });
      }
    }
  }

  Future<void> saveImage(XFile image) async {
    var dateTime = DateTime.now().toString().replaceAll(' ', '_');
    var ref = _firebaseStorage.ref().child("images/$dateTime.jpg");
    // 해결했다 ^^... 2024-08-30 20:51 - 원인은 라이브러리 버전... App Check token 뭐시기 그거는 에러가 아니래..
    var putFile = ref.putFile(
        File(image.path), SettableMetadata(contentType: "image/jpeg"));

    var complete = await putFile.whenComplete(() => {});
    var s = await complete.ref.getDownloadURL();
    print(s);

    setState(() {
      _pickedFile = XFile(s);
      _cacheBuster = DateTime.now().millisecondsSinceEpoch;
    });

    if (userImagePath.isNotEmpty) {
      try {
        final oldRef = FirebaseStorage.instance.refFromURL(userImagePath);
        await oldRef.delete();
      } catch (e) {
        if (kDebugMode) print('old image delete skip: $e');
      }
    }

    await _firestore.collection('user').doc(currentUser!.uid).update({
      'profileImagePath': s,
    });

    userImagePath = s;
  }

  @override
  void initState() {
    _getUserProfile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    final Size size = MediaQuery.of(context).size;
    final _imageSize = MediaQuery.of(context).size.width / 4;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'my page',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
        ),
        // ✅ CHANGED: FutureBuilder → Firestore StreamBuilder 로 실시간 반영
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream:
              _firestore.collection('user').doc(currentUser!.uid).snapshots(),
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

            final data = snapshot.data?.data() ?? {};
            final liveUrl = (data['profileImagePath'] ?? '') as String;
            final liveName = (data['userName'] ?? _username) as String;

            return Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  margin: EdgeInsets.all(5),
                  height: size.height * 0.17,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xfff1f8ff)),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 25,
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
                                    ? (liveUrl.isNotEmpty
                                        ? Image.network(
                                            '$liveUrl?v=$_cacheBuster',
                                            key: ValueKey(liveUrl),
                                            width: _imageSize,
                                            height: _imageSize,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: _imageSize,
                                            height: _imageSize,
                                            child: FittedBox(
                                              child: Icon(
                                                Icons.account_circle,
                                                size: _imageSize,
                                              ),
                                            ),
                                          ))
                                    : Image(
                                        width: _imageSize,
                                        height: _imageSize,
                                        fit: BoxFit.cover,
                                        image: _pickedFile!.path
                                                .startsWith('https')
                                            ? NetworkImage(_pickedFile!.path)
                                            : FileImage(File(_pickedFile!.path))
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
                            Text(
                              liveName,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            // Text('${_userData['userLevel']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 10,),
              // ListTile(
              //   leading: Padding(
              //       padding: EdgeInsets.only(left: 10),
              //       child: Icon(
              //         Icons.edit,
              //       )),
              //   title: Text(
              //     '회원정보 수정',
              //   ),
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (BuildContext) => MyPageEdit(),
              //       ),
              //     );
              //   },
              // ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: size.height * 0.085,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox.expand(
                    child: Card(
                      color: Color(0xe5f1f8ff),
                      child: Center(
                        child: ListTile(
                          leading: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.logout,
                              )),
                          title: Text(
                            '로그아웃',
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                title: Text(
                                  '로그아웃하시겠습니까?',
                                  style: TextStyle(fontSize: 18),
                                ),
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
                                          Navigator.of(context).pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen()),
                                              (route) => false);
                                        }
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.remove('lastDate');
                                        await prefs.remove('lastEnglish');
                                        await prefs.remove('lastKorean');
                                      } catch (e) {
                                        print('로그아웃 실패: $e');
                                      }

                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
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
                        ),
                      ),

                    ),
                  ),
                ),
              ),
              SizedBox(height: 3,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: size.height * 0.085,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox.expand(
                    child: Card(
                      color: Color(0xe5f1f8ff),
                      child: Center(
                        child: ListTile(
                          title: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              '회원 탈퇴',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                title: Text(
                                  '탈퇴하시겠습니까?',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
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
                                      final uid = currentUser?.uid;
                                      if (uid == null) return;

                                      await currentUser?.delete();
                                      await _firestore
                                          .collection('user')
                                          .doc(uid)
                                          .delete();

                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const LoginScreen()),
                                          (route) => false);
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Future<void> _showBottomSheet() {
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
                      setState(() {
                        _pickedFile = image;
                      });
                      print(_pickedFile!.path);
                      Navigator.of(context).pop();
                      await saveImage(image); // 스토리지에 위에서 가져온 이미지를 저장하는 코드
                    }
                    // 스토리지에 위에서 가져온 이미지를 저장하는 코드
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      fixedSize: Size(150, 22)),
                  child: const Text(
                    '사진찍기',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 2,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // ✅ CHANGED: 갤러리도 선택 후 저장까지 이어서 처리
                    final image = await _getPhotoLibraryImage();
                    if (image != null) {
                      Navigator.of(context).pop();
                      await saveImage(image);
                    }
                  },
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

  // ✅ CHANGED: 반환형을 XFile? 로 통일해서 saveImage에서 공통 처리
  Future<XFile?> _getPhotoLibraryImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      return pickedFile; // ✅ ADDED
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
      return null; // ✅ ADDED
    }
  }
}
