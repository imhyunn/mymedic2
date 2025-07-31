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
  List<Word> _words = [];
  List<List<String>> _shuffledOptions = [];
  Timer? _timer;
  double _timeLeftRatio = 1.0;
  final int questionDuration = 4;

  void _startTimer() {
    _timer?.cancel();
    _timeLeftRatio = 1.0;
    const tick = Duration(microseconds: 100);
    int ticks = 0;
    int totalTicks = (questionDuration * 1000 ~/ tick.inMilliseconds);

    _timer = Timer.periodic(tick, (timer) {
      setState(() {
        ticks++;
        _timeLeftRatio = 1.0 - (ticks / totalTicks);
      });

      if (ticks >= totalTicks) {
        _nextQuestion();
      }
    });
  }



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
    _generateOptions();
    _startTimer();
    return words;
  }

  void _generateOptions() {
    final allAnswers = _words.map((w) => w.korean).toList();
    _shuffledOptions = _words.map((word) {
      Set<String> options = {word.korean};
      while (options.length < 4) {
        String random = allAnswers[Random().nextInt(allAnswers.length)];
        options.add(random);
      }
      List<String> shuffled = options.toList()..shuffle();
      return shuffled;
    }).toList();
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex;
        _startTimer();
      });
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      print('Rmx');
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

  Widget _NormalUI(int id) {
    final word = _words[id];
    final options = _shuffledOptions[id];

    return Column(
      key: ValueKey(id),
      children: [
        SizedBox(height: 20,),
        LinearProgressIndicator(
          value: _timeLeftRatio,
          backgroundColor: Colors.grey[300],
          color: Colors.blueAccent,
          minHeight: 10,
        ),
        SizedBox(height: 40,),
        Card(
          child: Text(word.english, style: TextStyle(fontSize: 24),),
        )
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWord();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
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
              itemCount: words.length,
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
                  child: _NormalUI(index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
