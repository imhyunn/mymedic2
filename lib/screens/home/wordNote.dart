import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../config/palette.dart';

class WordNote extends StatefulWidget {
  const WordNote({super.key});
  @override
  State<WordNote> createState() => _WordNoteState();
}

class _WordNoteState extends State<WordNote> {
  final List<String> wordlist = <String>[
    'apple',
    'home',
  ];

  final List<String> krword = <String>['사과', '집'];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
              onPressed: () {
                _addword(context);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: ListView.separated(
          itemCount: wordlist.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                onTap: null,
                title: Row(
                  children: [
                    Container(
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Container(
                          height: 35,
                          child: Text(
                            wordlist[index],
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                        Container(
                          height: 35,
                          child: Text(
                            krword[index],
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: size.width * 0.48,
                    ),
                    Container(
                      width: size.width * 0.2,
                      height: size.height * 0.09,
                      child: DottedBorder(
                        radius: Radius.circular(20),
                        color: Colors.grey,
                        child: Center(child: Icon(Icons.add)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          }),
    );
  }

  Future<void> _addword(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          title: Text(
            '영단어 추가',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '영단어',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              TextField(
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '뜻',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
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
                    '취소',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ],
        );
      },
    );
  }
}
