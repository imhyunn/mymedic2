import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/screens/home/test/test_screen.dart';
import 'package:mymedic1/screens/home/test/wordTestHome.dart';
import 'package:mymedic1/screens/home/words/wordFolder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userInfo;

  // User? loggedUser;
  Map<String, dynamic>? wordData;
  bool isLoading = true;
  bool _isRevealed = false;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDailyWord();
    // Future.delayed(Duration(milliseconds: 300), () {
    //   getCurrentUser();
    // });
  }

  double generateDeterministicRandom(String uid, DateTime date) {
    final input = '$uid-${date.year}-${date.month}-${date.day}';
    final hash = input.hashCode;
    final normalized = (hash % 1000000) / 1000000;
    return normalized < 0 ? -normalized : normalized;
  }

  Future<void> _loadDailyWord() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString('lastDate');
    final savedEnglish = prefs.getString('lastEnglish');
    final saveKorean = prefs.getString('lastKorean');

    if (savedDate == today && savedEnglish != null && saveKorean != null) {
      setState(() {
        wordData = {
          'english': savedEnglish,
          'korean': saveKorean,
        };
        isLoading = false;
      });
      return;
    }

    final uid = currentUser?.uid;
    if (uid == null) return;

    final rand = generateDeterministicRandom(uid, DateTime.now());

    QuerySnapshot snap = await _firestore
        .collection('words')
        .where('uid', isEqualTo: uid)
        .where('randomIndex', isGreaterThanOrEqualTo: rand)
        .orderBy('randomIndex')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _firestore
          .collection('words')
          .where('uid', isEqualTo: uid)
          .where('randomIndex', isLessThanOrEqualTo: rand)
          .orderBy('randomIndex')
          .limit(1)
          .get();
    }

    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data() as Map<String, dynamic>;

      await prefs.setString('lastDate', today);
      await prefs.setString('lastEnglish', data['english']);
      await prefs.setString('lastKorean', data['korean']);

      setState(() {
        wordData = {'english': data['english'], 'korean': data['korean']};
        isLoading = false;
      });
    } else {
      await prefs.remove('lastDate');
      await prefs.remove('lastEnglish');
      await prefs.remove('lastKorean');
      setState(() {
        wordData = {'english': '없음', 'korean': '단어가 없습니다'};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'mydedic',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        // backgroundColor: Color(0xEAAACBE1),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(children: [
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
          // SizedBox(
          //   height: size.height * 0.15,
          // ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xff8291a8),
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: Offset(0, 7)),
                ],
                // border: Border.all(
                //   color: Colors.grey,
                //   width: 3
                // ),
                color: Color(0xffd5e5f8)),
            height: size.height * 0.3,
            width: size.width * 0.95,
            child: Stack(children: [
              Padding(
                padding: EdgeInsets.all(14),
                child: Container(
                  // decoration: BoxDecoration(
                  //     color: Color(0xfff8e7e7),
                  //     borderRadius: BorderRadius.circular(4)),
                  padding: EdgeInsets.all(7),
                  child: Text(
                    '오늘의 단어',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 19,
                    ),
                    Text(
                      wordData!['english'],
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: _isRevealed
                          ? SizedBox(
                        height: 45, // 버튼과 동일한 높이 확보
                        child: Center(
                          child: Text(
                            wordData!['korean'],
                            key: const ValueKey('text'),
                            style: const TextStyle(fontSize: 27),
                          ),
                        ),
                      )
                          : SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          key: const ValueKey('button'),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(180, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            backgroundColor:
                            const Color(0xffFFFFFF),
                          ),
                          onPressed: () {
                            setState(() {
                              _isRevealed = true;
                            });
                          },
                          child: const Text(
                            '뜻 보기',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    // if (_isRevealed)
                    //   Text(
                    //     wordData!['korean'],
                    //     style: TextStyle(fontSize: 20),
                    //   )
                    // else
                    //   ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //         fixedSize: Size(180, 10),
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius:
                    //                 BorderRadius.circular(10)),
                    //         backgroundColor: Color(0xffFFFFFF)),
                    //     onPressed: () {
                    //       setState(() {
                    //         _isRevealed = true;
                    //       });
                    //     },
                    //     child: const Text(
                    //       '뜻 보기',
                    //       style: TextStyle(color: Colors.black),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ]),
          ),
          Expanded(
            child: Container(
              width: size.width,
              // height: size.height * 0.5,
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
                          width: size.width * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFF4567BD),
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
                              setState(() {

                              });
                            },
                            child: Text(
                              'word',
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      /*SizedBox(
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
                                  builder: (BuildContext) => WordTestHome(),
                                ),
                              );
                            },
                            child: Text(
                              'test',
                              style: TextStyle(fontSize: 28, color: Colors.black,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),*/
                      /*SizedBox(
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