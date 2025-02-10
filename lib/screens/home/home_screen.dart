import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymedic1/screens/home/test/test_screen.dart';
import 'package:mymedic1/screens/home/words/wordFolder.dart';
import 'package:mymedic1/screens/home/words/wordNote.dart';
import 'package:mymedic1/screens/home/words/wordNote_edit.dart';
import 'package:mymedic1/data/folder.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          Container(
            height: size.height * 0.43,
            decoration: BoxDecoration(
              color: Color(0xEA69BB7C),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
          ),
          Container(
            child: Text(
              'MYMEDIC',
              style: GoogleFonts.archivoBlack(
                textStyle: TextStyle(
                  fontSize: 32
                ),
              )
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
                            color: Color(0xEA3F8850),
                            width: 2, // 테두리 두께
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
                            style: TextStyle(fontSize: 26, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Colors.white,
                      elevation: 0,
                      child: Container(
                        height: 120,
                        width: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xEA3F8850),
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
                            style: TextStyle(fontSize: 26, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Colors.white,
                      elevation: 0,
                      child: Container(
                        height: 120,
                        width: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xEA3F8850),
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
                            style: TextStyle(fontSize: 26, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
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
