import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymedic1/screens/myapp.dart';

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
  PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  final random = Random();

  Future<List<Word>> getWord() async {
    var snapshot = await _firestore
        .collection('words')
        .where('folderId', isEqualTo: widget.folder.id)
        .get();
    List<Word> words = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return Word(map['english'], map['korean'], map['time'], map['image'],
          element.id, map['folderId'], map['uid'], map['randomIndex']);
    }).toList();
    return words;
  }

  void _nextQuestion(List<Word> words) {
    if (_currentIndex < words.length - 1) {
      _currentIndex++;

      Future.delayed(const Duration(milliseconds: 500), () {
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        print(_currentIndex);
      });


    }
  }

  Widget _StartUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
            child: Container(
                width: 200,
                height: 300,
                child: Column(
                  children: [Text('test'), Text('<${widget.folder.name}>')],
                ))),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text(
            'start!',
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              minimumSize: Size(200, 50)),
        ),
      ],
    );
  }

  Widget _NormalUI(List<Word> words, int id) {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      _currentIndex++;
    });

    return Container(
      key: ValueKey<int>(id),
      height: 500,
      width: 300,
      child: Column(
        children: [
          Container(
            height: 100,
            width: 300,
            child: Card(
              child: Center(
                child: Text(
                  words[id].english,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => ElevatedButton(
                onPressed: () {
                  if (words[id].korean == words[index].korean){

                    print('o');
                  } else {

                    print('x');
                  }
                  _nextQuestion(words);
                },
                child: Text(
                  words[index].korean,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: getWord(),
        builder: (context, snapshot) {
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

          final words = snapshot.requireData;

          return Center(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: words.length ,
              itemBuilder: (context, index) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: _NormalUI(words, index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
