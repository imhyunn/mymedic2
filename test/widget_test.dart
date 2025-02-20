import 'package:flutter/material.dart';

void main() {
  runApp(MyAppp());
}

class MyAppp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _questions = [
    "문제 1: Flutter란?",
    "문제 2: Dart란?",
    "문제 3: StatefulWidget과 StatelessWidget의 차이?",
  ];

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("단어 퀴즈")),
      body: Center(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset(0, 0),
                  ).animate(animation),
                  child: child,
                );
              },
              child: Container(
                key: ValueKey<int>(index),
                padding: EdgeInsets.all(16),
                color: Colors.blueAccent,
                child: Center(
                  child: Text(
                    _questions[index],
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextQuestion,
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
