import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedic1/providers.dart';
import 'package:mymedic1/screens/bulletinboard/board_edit.dart';
import 'package:mymedic1/data/board_manager.dart';
import 'package:mymedic1/data/board.dart';
import 'package:mymedic1/screens/bulletinboard/board_list.dart';

import '../../config/palette.dart';

class BoardViewScreen extends StatefulWidget {
  static const routeName = '/view';
  final Board board;
  BoardViewScreen(this.board);

  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  XFile? _pickedFile;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _imageSize = MediaQuery.of(context).size.width / 10 ;
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
                            _edit(widget.board.id!);
                            break;
                          case "삭제":
                            _confirmDelete(widget.board.id!);
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
                          widget.board.title.isEmpty ? '(제목 없음)' : widget.board.title,
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        )),
                    SizedBox(height: 8,),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          Container(
                            child: _pickedFile == null
                                ? Center(
                              child: Icon(
                                Icons.account_circle,
                                size: _imageSize,
                              ),
                            )
                                : Center(
                              child: Container(
                                width: _imageSize,
                                height: _imageSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2,
                                      color: Colors.white),
                                  image: DecorationImage(
                                      image: FileImage(File(_pickedFile!.path)),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(widget.board.username!, style: TextStyle(
                                    fontSize: 15
                                ),),
                              ),
                              Container(
                                child: Text(
                                  widget.board.createAt.split(".")[0] ?? "NO",
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
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
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(widget.board.body, style: TextStyle(
                            fontSize: 18
                        ),)),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  void _edit(String id) {
    Navigator.pushNamed(
      context,
      BoardEditScreen.routeName,
      arguments: widget.board,
    ).then((result) {
      if (result != null) {
        var res = result as List<String>;
        setState(() {
          widget.board.title = res[0];
          widget.board.body = res[1];
        });
      }
    });
  }

  void _confirmDelete(String id) {
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
                  onPressed: () async {
                    // boardManager().deleteBoard(id);
                    await deleteData();
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

  Future<void> deleteData() async {
    await _firestore.collection('boards').doc(widget.board.id).delete();
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
