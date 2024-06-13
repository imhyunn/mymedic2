import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymedic1/screens/home/test_screen.dart';
import 'package:mymedic1/screens/home/wordNote.dart';

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
   return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'MYMEDIC',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Container(
                    height: 400,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Color(0xFF88CC7B),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: Colors.white,
                          elevation: 0,
                          child: Container(
                            height: 120, width: 283,
                            child: TextButton(
                              onPressed: () {
                               Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext) => WordNote(),
                                  ),
                                );
                              },
                              child: Text('word', style: TextStyle(fontSize: 26, color: Colors.black),),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: Colors.white,
                          elevation: 0,
                          child: Container(
                            height: 120, width: 283,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext) => WordTest(),
                                  ),
                                );
                              },
                              child: Text('test', style: TextStyle(fontSize: 26, color: Colors.black),),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: Colors.white,
                          elevation: 0,
                          child: Container(
                            height: 120, width: 283,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext) => WordTest(),
                                  ),
                                );
                              },
                              child: Text('game', style: TextStyle(fontSize: 26, color: Colors.black),),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (BuildContext) => WordTest(),
                    //           ),
                    //         );
                    //       },
                    //       child: Text('test'),
                    //     ),
                    //     Divider(),
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (BuildContext) => WordTest(),
                    //           ),
                    //         );
                    //       },
                    //       child: Text('test'),
                    //     ),
                    //     Divider(),
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (BuildContext) => WordTest(),
                    //           ),
                    //         );
                    //       },
                    //       child: Text('test'),
                    //     ),
                    //   ],
                    // ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
