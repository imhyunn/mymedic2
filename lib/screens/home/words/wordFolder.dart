import 'package:flutter/material.dart';

class WordFolder extends StatefulWidget {
  const WordFolder({super.key});

  @override
  State<WordFolder> createState() => _WordFolderState();
}

class _WordFolderState extends State<WordFolder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.check))
        ],
      ),
    );
  }
}
