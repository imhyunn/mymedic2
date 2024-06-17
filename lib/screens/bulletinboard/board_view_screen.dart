import 'package:flutter/material.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/screens/bulletinboard/board_edit.dart';
import 'package:mymedic1/data/board_manager.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/screens/bulletinboard/board_list.dart';

import '../../config/palette.dart';

class BoardViewScreen extends StatefulWidget {
  static const routeName = '/view';
  final int id;

  BoardViewScreen(this.id);

  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Board>(
      future: boardManager().getBoard(widget.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('오류가 발생했습니다.'),
            ),
          );
        }

        final board = snap.requireData;

        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
                  return {'편집', '삭제'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                      onTap: () {
                        switch (choice) {
                          case "편집":
                            _edit(widget.id);
                            break;
                          case "삭제":
                            _confirmDelete(widget.id);
                            break;
                        }
                      },
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: SizedBox.expand(
            child: Container(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          board.title.isEmpty ? '(제목 없음)' : board.title,
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        )),
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
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(board.body)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _edit(int id) {
    Navigator.pushNamed(
      context,
      BoardEditScreen.routeName,
      arguments: id,
    ).then((_) {
      setState(() {});
    });
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '노트 삭제',
          ),
          content: Text(
            '노트를 삭제할까요?',
          ),
          actions: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '아니오',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    boardManager().deleteBoard(id);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '예',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ],
        );
      },
    );
  }

  void handleClick(String value) {
    switch (value) {
      case '편집':
        break;
      case '삭제':
        break;
    }
  }
}
