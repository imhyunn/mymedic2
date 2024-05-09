import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/data/board_manager.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/screens/bulletinboard/board_edit.dart';
import 'package:mymedic1/screens/bulletinboard/board_view_screen.dart';

class BoardList extends StatefulWidget {
  static const routeName = '/list';

  @override
  State<BoardList> createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('게시판'),
      ),
      body: FutureBuilder<List<Board>>(
        future: boardManager().listBoards(),
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
        child: Icon(Icons.add, color: Colors.white,),
        tooltip: '글 작성',
        onPressed: () {
          Navigator.pushNamed(context, BoardEditScreen.routeName).then((value) {
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
          arguments: board.id,
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
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  width: 450,
                  child: Text(board.createAt.split(".")[0] ?? "NO", style: TextStyle(fontSize: 11), textAlign: TextAlign.end,),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
