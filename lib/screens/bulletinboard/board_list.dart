import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/data/board_manager.dart';
import 'package:mymedic1/data/user.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/screens/bulletinboard/board_edit.dart';
import 'package:mymedic1/screens/bulletinboard/board_view_screen.dart';

import 'board_new.dart';

class BoardList extends StatefulWidget {
  static const routeName = '/list';

  @override
  State<BoardList> createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  String _username = '';
  Map<String, dynamic> _userData = {};
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AppUser> appUser = [];


  void _getUserProfile() async {



    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _userData = userData.data()!;
          _username = _userData['userName'];
          print(_username);
        });
      }
      print(_userData);
    } else {
      // 로그인되어 있지 않음
      print("❗ 유저가 로그인되어 있지 않습니다.");
    }


  }


  Future<List<Board>> _getBoards() async {
    var snapshot = await _firestore
        .collection("boards")
        .orderBy("time", descending: true)
        .get();

    List<Board> boards = snapshot.docs
        .map((element) {
          return Board(element.data()['title'], element.data()['body'], element.id, element.data()['uid'], element.data()['time']);
    }).toList();




    for (int i = 0; i < boards.length; ++i) {
      var userdata = await _firestore.collection('user').doc(boards[i].uid).get();
      boards[i].username = userdata.data()!['userName'];



      // var userData = await FirebaseFirestore.instance
      //     .collection('user')
      //     .doc(boards[i].uid)
      //     .get();
      // _userData = userData.data()!;
      // boards[i].username = _userData['userName'];
      // print(boards[i].username);
      //
      // // if (userData.exists) {
      //   setState(() {
      //     _userData = userData.data()!;
      //     boards[i].username = _userData['userName'];
      //     print(_username);
      //   });
      // }
      // print(_userData);
    }

    return boards;
  }

  @override
  void initState() {
    _getUserProfile();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('게시판'),
      ),
      body: FutureBuilder<List<Board>>(
        future: _getBoards(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snap.hasError) {
            print(snap.error.toString());
            return Center(
              child: Text('오류가 발생했습니다.'),
            );
          }


          final boards = snap.requireData;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 16.0),
            itemCount: boards.length,
            itemBuilder: (context, index) => _buildCard(boards[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        tooltip: '글 작성',
        onPressed: () {
          Navigator.pushNamed(context, BoardNewScreen.routeName).then((value) {
            setState(() {});
          });
        },
      ),
    );
  }

  Widget _buildCard(Board board) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          BoardViewScreen.routeName,
          arguments: board,
        ).then((value) {
          setState(() {});
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: 450,
            height: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  board.title.isEmpty ? '(제목 없음)' : board.title,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Container(
                      child: Text(
                        board.username!,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Divider(
                      thickness: 10,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      child: Text(
                        board.createAt.split(".")[0] ?? "NO",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
