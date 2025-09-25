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
    final uid = currentUser?.uid;
    if (uid == null) return;

    String? savedDate = prefs.getString('lastDate');
    String? savedEnglish = prefs.getString('lastEnglish');
    String? saveKorean = prefs.getString('lastKorean');

    if (savedDate == today && savedEnglish != null && saveKorean != null) {
      final checkSnap = await _firestore
          .collection('words')
          .where('uid', isEqualTo: uid)
          .where('english', isEqualTo: savedEnglish)
          .get();

      if (checkSnap.docs.isNotEmpty) {
        setState(() {
          wordData = {
            'english': savedEnglish,
            'korean': saveKorean,
          };
          isLoading = false;
        });
        return;
      } else {
        await prefs.remove('lastDate');
        await prefs.remove('lastEnglish');
        await prefs.remove('lastKorean');
      }
    }

    final snapshot =
        await _firestore.collection('words').where('uid', isEqualTo: uid).get();

    if (snapshot.docs.isNotEmpty) {
      final randIndex = Random().nextInt(snapshot.docs.length);
      final data = snapshot.docs[randIndex].data() as Map<String, dynamic>;

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
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'mydedic',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 오늘의 단어 카드
                    Container(
                      height: size.height * 0.25,
                      width: size.width * 0.95,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Color(0xffe8f1fb),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 28, horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                '📘 오늘의 단어',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                wordData!['english'],
                                style: TextStyle(
                                  fontSize: wordData!['english'].length > 17
                                      ? 31
                                      : 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2b4c7e),
                                ),
                              ),
                              SizedBox(height: 18),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                child: _isRevealed
                                    ? SizedBox(
                                        height: 45, // 버튼과 동일한 높이 확보
                                        child: Center(
                                          child: Text(
                                            wordData!['korean'],
                                            key: ValueKey('text'),
                                            style: TextStyle(fontSize: 27),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 45,
                                        child: ElevatedButton(
                                          key: ValueKey('button'),
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(180, 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            backgroundColor: Color(0xffFFFFFF),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isRevealed = true;
                                            });
                                          },
                                          child: Text(
                                            '뜻 보기',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // 버튼 카드들
                    Column(
                      children: [
                        _menuButton(
                          icon: Icons.folder_open,
                          label: '단어 폴더',
                          onPressed: () async {
                            final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => WordFolder()));
                            if (result == true) {
                              await _handleWordListChanged();
                            }
                          },
                        ),
                        // 아래 필요시 주석 해제
                        // _menuButton(
                        //   icon: Icons.quiz_outlined,
                        //   label: '단어 테스트',
                        //   onPressed: () {
                        //     Navigator.push(context,
                        //         MaterialPageRoute(builder: (_) => WordTestHome()));
                        //   },
                        // ),
                        // _menuButton(
                        //   icon: Icons.videogame_asset,
                        //   label: '게임 모드',
                        //   onPressed: () {
                        //     Navigator.push(context,
                        //         MaterialPageRoute(builder: (_) => TestScreen()));
                        //   },
                        // ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _handleWordListChanged() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastDate');
    await prefs.remove('lastEnglish');
    await prefs.remove('lastKorean');

    setState(() {
      isLoading = true;
      _isRevealed = false;
    });

    await _loadDailyWord();
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blueAccent, size: 32),
          title: Text(
            label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded),
          onTap: onPressed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
