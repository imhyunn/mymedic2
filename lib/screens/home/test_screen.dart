import 'package:flutter/material.dart';

class WordTest extends StatefulWidget {
  const WordTest({super.key});

  @override
  State<WordTest> createState() => _WordTestState();
}

class _WordTestState extends State<WordTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
    );
  }
}
