import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          title: Text(
            'mydedic',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        // backgroundColor: Color(0xEAAACBE1),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(children: [
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
                  height: size.height * 0.17,
                  width: size.width,
                  child: Column(
                    children: [
                      Text('', style: TextStyle(fontSize: 20),),
                      Text(wordData!['english'], style: TextStyle(fontSize: 20),),
                      SizedBox(
                        height: 16,
                      ),
                      if (_isRevealed)
                        Text(wordData!['korean'], )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isRevealed = true;
                            });
                          },
                          child: const Text('뜻 보기'),
                        ),
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
