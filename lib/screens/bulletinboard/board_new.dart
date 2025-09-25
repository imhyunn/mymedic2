import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/config/palette.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/data/board_manager.dart';

class BoardNewScreen extends StatefulWidget {
  static const routeName = '/new';

  @override
  State<BoardNewScreen> createState() => _BoardNewScreenState();
}

class _BoardNewScreenState extends State<BoardNewScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  String title = '';
  String body = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0)),
                            contentPadding: EdgeInsets.zero,
                            content: Padding(
                                padding: EdgeInsets.only(top: 18, left: 18),
                                child: Text(
                                  '제목을 입력해주세요.',
                                  style: TextStyle(fontSize: 16),
                                )),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Palette.buttonColor2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: const Text(
                                  '확인',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ]);
                      },
                    );
                  }
                  if (bodyController.text.isEmpty) {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0)),
                            contentPadding: EdgeInsets.zero,
                            content: Padding(
                                padding: EdgeInsets.only(top: 18, left: 18),
                                child: Text(
                                  '내용을 입력해주세요.',
                                  style: TextStyle(fontSize: 16),
                                )),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Palette.buttonColor2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: const Text(
                                  '확인',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ]);
                      },
                    );
                  }

                  await _firestore.collection('boards').doc().set({
                    'title': titleController.text,
                    'body': bodyController.text,
                    'time': DateTime.now().toString(),
                    'uid': FirebaseAuth.instance.currentUser!.uid,
                  });
                  Navigator.pop(context, titleController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  '발행',
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '제목',
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              maxLines: 1,
              style: TextStyle(fontSize: 20.0),
              controller: titleController,
            ),
            SizedBox(height: 5.0),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '내용을 입력하세요!',
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              maxLines: null,
              style: TextStyle(fontSize: 14.5),
              keyboardType: TextInputType.multiline,
              controller: bodyController,
            ),
          ],
        ),
      ),
    );
  }
}
