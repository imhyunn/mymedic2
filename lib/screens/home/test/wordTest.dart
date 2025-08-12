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
  double _timeLeftRatio = 1.0; // 0~1 사이
  final int questionDuration = 4;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    var snapshot = await _firestore
        .collection('words')
        .where('folderId', isEqualTo: widget.folder.id)
        .get();

    setState(() {
      _words = snapshot.docs.map((element) {
        Map<String, dynamic> map = element.data();
        return Word(map['english'], map['korean'], map['time'], map['image'],
            element.id, map['folderId'], map['uid'], map['randomIndex']);
      }).toList();
      _generateOptions();
      _startTimer();
    });
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

  void _startTimer() {
    _timer?.cancel();
    _timeLeftRatio = 1.0;
    const tick = Duration(milliseconds: 100);
    int ticks = 0;
    int totalTicks = tick.inMicroseconds > 0
        ? (questionDuration * 1000 ~/ tick.inMicroseconds)
        : 1;

    _timer = Timer.periodic(tick, (timer) {
      setState(() {
        ticks++;
        if (totalTicks == 0) {
          _timeLeftRatio = 0.0;
        } else {
          _timeLeftRatio = 1.0 - (ticks / totalTicks);
          _timeLeftRatio = _timeLeftRatio.clamp(0.0, 1.0);
        }
      });

      if (ticks >= totalTicks) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _startTimer();
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 테스트 끝
      print('테스트 완료!');
    }
  }

  Widget _buildQuestionCard(int index) {
    final word = _words[index];
    final options = _shuffledOptions[index];

    return Column(
      key: ValueKey(index),
      children: [
        SizedBox(height: 20),
        LinearProgressIndicator(
          value: _timeLeftRatio,
          backgroundColor: Colors.grey[300],
          color: Colors.blueAccent,
          minHeight: 10,
        ),
        SizedBox(height: 40),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(word.english, style: TextStyle(fontSize: 24)),
          ),
        ),
        SizedBox(height: 30),
        ...options.map((opt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ElevatedButton(
                onPressed: () {
                  if (opt == word.korean) {
                    print('정답');
                  } else {
                    print('오답');
                  }
                  _nextQuestion();
                },
                child: Text(opt),
                style: ElevatedButton.styleFrom(minimumSize: Size(250, 50)),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('단어 테스트')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('단어 테스트')),
      body: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _words.length,
        itemBuilder: (context, index) => AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset(0, 0),
            ).animate(animation),
            child: child,
          ),
          child: _buildQuestionCard(index),
        ),
      ),
    );
  }
}
