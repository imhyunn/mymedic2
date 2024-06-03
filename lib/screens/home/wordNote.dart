import 'package:flutter/material.dart';

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
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        itemCount: wordlist.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 20, right: 30),
                  horizontalTitleGap: 10,
                  isThreeLine: true,
                  leading: Icon(
                    Icons.volume_up_rounded,
                    size: 20,
                  ),
                  title: Text(
                    '${wordlist[index]}',
                    style: TextStyle(fontSize: 24),
                  ),
                  subtitle: Text(
                    '${krword[index]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: SizedBox(
                    height: 100,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Icon(Icons.add),
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                    ),
                  ),
                  // trailing: Container(
                  //     width: 100,
                  //     height: 100,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(width: 2, color: Colors.grey),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: IconButton(
                  //       icon: Icon(Icons.add),
                  //       onPressed: () {},
                  //     ))
                  // titleAlignment: ListTileTitleAlignment.top,
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }
}
