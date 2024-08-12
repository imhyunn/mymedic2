import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/config/palette.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/data/board_manager.dart';

class BoardEditScreen extends StatefulWidget {
  static const routeName = '/edit';

  final int? id;

  BoardEditScreen(this.id);

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
    final boardId = widget.id;
    // if (boardId != null) {
    //   boardManager().getBoard(boardId).then((board) {
    //     titleController.text = board.title;
    //     bodyController.text = board.body;
    //   });
    // }
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
                  await _firestore.collection('boards').doc()
                      .set({
                    'title' : titleController.text,
                    'body' : bodyController.text,
                    'time' : DateTime.now().toString(),
                    'uid' : FirebaseAuth.instance.currentUser!.uid,
                  });
                  Navigator.pop(context, titleController.text);
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

  // void _saveBoard() {
  //   if (bodyController.text.isNotEmpty) {
  //     final board = Board(
  //       titleController.text,
  //       bodyController.text,
  //       DateTime.now().toString(),
  //     );
  //
  //     final boardId = widget.id;
  //     if (boardId != null) {
  //       boardManager().updateBoard(boardId, board);
  //     } else {
  //       boardManager().addBoard(board);
  //     }
  //
  //     Navigator.pop(context);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('내용을 입력하세요'),
  //       behavior: SnackBarBehavior.floating,
  //     ));
  //   }
  // }
}
