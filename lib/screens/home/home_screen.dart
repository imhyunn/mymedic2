import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymedic1/config/palette.dart';
import 'package:mymedic1/data/user_provider.dart';
import 'package:mymedic1/screens/home/test/test_screen.dart';
import 'package:mymedic1/screens/home/words/wordFolder.dart';
import 'package:mymedic1/screens/home/words/wordNote.dart';
import 'package:mymedic1/screens/home/words/wordNote_edit.dart';
import 'package:mymedic1/data/folder.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userInfo;
  // User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // Future.delayed(Duration(milliseconds: 300), () {
    //   getCurrentUser();
    // });

  }

  Future<DocumentSnapshot?> getRondomWord() async {
    final random = Random();
    final double randomKey = random.nextDouble();


    var querySnap = await _firestore.collection('words').where('randomKey', isGreaterThanOrEqualTo: randomKey).orderBy('randomKey').limit(1).get();

    if (querySnap.docs.isNotEmpty) {
      return querySnap.docs.first;
    }

    querySnap = await _firestore.collection('words').where('randomKey', isLessThanOrEqualTo: randomKey).orderBy('randomKey', descending: true).limit(1).get();

    if (querySnap.docs.isNotEmpty) {
      return querySnap.docs.first;
    }

    return null;
  }

  void showRandomWord() async {
    final word = await getRondomWord();
    if (word != null) {
      final data = word.data() as Map<String, dynamic>;
      print('“${data['text']}” — ${data['author']}');
    } else {
      print('단어를 찾을 수 없습니다');
    }
  }

  // Future<void> getCurrentUser() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     await userProvider.fetchUserData(user.uid);
  //   }


    // final userdata = await _firestore.collection('user').doc(user.uid).get();
    //
    // if (userdata.exists) {
    //   final data = userdata.data();
    //
    //   userInfo?['userEmail'] = data?['email'] ?? '';
    //   userInfo?['userPassword'] = data?['password'] ?? '';
    // }

    // try {
    //
    //   if (user != null) {
    //     print("현재 로그인 유저 이메일: ${user.email}");
    //   } else {
    //     print("로그인된 유저가 없습니다.");
    //   }
    // }catch (e) {
    //   print("유저 정보 불러오기 실패: $e");
    //   // if (user != null) {
    //   //   loggedUser = user;
    //   //   print(loggedUser!.email);
    //   // }


  // }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('mydedic',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),),
        // backgroundColor: Color(0xEAAACBE1),
        body: Stack(children: [
          /*Container(
            height: size.height * 0.43,
            decoration: BoxDecoration(
              color: Color(0xEA72A9D2),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
          ),*/
          Container(
            child: Column(
              children: [
              ],
            ),
          ),
          Container(
            width: size.width,
            height: size.height * 0.82,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      elevation: 0,
                      child: Container(
                        height: 120,
                        width: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Palette.buttonColor,
                            width: 3, // 테두리 두께
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext) => WordFolder(),
                              ),
                            );
                          },
                          child: Text(
                            'word',
                            style: TextStyle(fontSize: 28, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    /*Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      elevation: 0,
                      child: Container(
                        height: 120,
                        width: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xEA5180A2),
                            width: 2, // 테두리 두께
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext) => TestScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'test',
                            style: TextStyle(fontSize: 28, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      elevation: 0,
                      child: Container(
                        height: 120,
                        width: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xEA5180A2),
                            width: 2, // 테두리 두께
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext) => TestScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'game',
                            style: TextStyle(fontSize: 28, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),*/
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
