import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/config/palette.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/data/board_manager.dart';

class BoardEditScreen extends StatefulWidget {
  static const routeName = '/edit';

  final Board board;

  BoardEditScreen(this.board);

  @override
  State<BoardEditScreen> createState() => _BoardEditScreenState();
}

class _BoardEditScreenState extends State<BoardEditScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  String title = '';
  String body = '';



  @override
  void initState() {
    super.initState();
    titleController.text = widget.board.title;
    bodyController.text = widget.board.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  List<String> result = await editData();
                  Navigator.pop(context, result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text('발행', style: TextStyle(color: Colors.white),),
              )
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
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


  Future<List<String>> editData() async {
    await _firestore.collection('boards').doc(widget.board.id).set({
      'title' : titleController.text,
      'body' : bodyController.text,
      'time' : widget.board.createAt,
      'uid' : widget.board.uid,
    });

    List<String> result = [];
    result.add(titleController.text);
    result.add(bodyController.text);
    return result;
  }


}
