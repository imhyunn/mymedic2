import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/folder.dart';
import '../../../data/word.dart';

class WordTest extends StatefulWidget {
  const WordTest({super.key, required this.folder});

  final Folder folder;

  @override
  State<WordTest> createState() => _WordTestState();
}


class _WordTestState extends State<WordTest> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Word>> getWord() async {
    var snapshot = await _firestore
        .collection('words')
        .where('folderId', isEqualTo: widget.folder.id)
        .orderBy('time', descending: true)
        .get();
    List<Word> words = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return Word(map['english'], map['korean'], map['time'], map['image'],
          element.id, map['folderId']);
    }).toList();
    return words;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(future: getWord(), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Center(
            child: Text('오류가 발생했습니다.'),
          );
        }
        return Container(

        );
      },),
    );
  }
}

