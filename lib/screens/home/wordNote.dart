import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/screens/home/drawing.dart';

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
  TextEditingController _engController = TextEditingController();
  TextEditingController _krController = TextEditingController();
  final List<String> krword = <String>[
    '사과zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz',
    '집'
  ];

  void renew() {
    setState(() {
      wordlist.add(_engController.text);
      krword.add(_krController.text);
      _engController.clear();
      _krController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await _addword(context);
                if (result!) {
                  renew();
                }
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
                title: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: Icon(
                          Icons.volume_up_rounded,
                          size: size.width * 0.055,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 35,
                              child: Text(
                                wordlist[index],
                                style: TextStyle(fontSize: 19),
                              ),
                            ),
                            Container(
                              height: 100,
                              child: Text(
                                krword[index],
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          // PopupMenuButton<String>(
                          //   color: Colors.white,
                          //   onSelected: ,
                          //   itemBuilder: (BuildContext context) {
                          //     return {'카메라', '라이브러리에서 불러오기', '그리기'}.map((String choice) {
                          //       return PopupMenuItem<String>(
                          //         value: choice,
                          //         child: Text(choice),
                          //         onTap: () {
                          //           switch (choice) {
                          //             case "카메라":
                          //               break;
                          //             case "라이브러리에서 불러오기":
                          //               break;
                          //             case "그리기":
                          //               break;
                          //           }
                          //         },
                          //       );
                          //     }).toList();
                          //   },
                          // );

                          // Navigator.push(context, MaterialPageRoute(builder: (context) => DrawingPage()));
                        },
                        child: Container(
                          width: size.width * 0.2,
                          height: size.width * 0.2,
                          child: DottedBorder(
                              radius: Radius.circular(20),
                              color: Colors.grey,
                              child: Center(
                                child: Icon(Icons.add),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          }),
    );
  }
  RelativeRect buttonMenuPosition(BuildContext context) {
    final bool isEnglish = false;
    final RenderBox bar = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    const Offset offset = Offset.zero;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(
            isEnglish
                ? bar.size.centerRight(offset)
                : bar.size.centerLeft(offset),
            ancestor: overlay),
        bar.localToGlobal(
            isEnglish
                ? bar.size.centerRight(offset)
                : bar.size.centerLeft(offset),
            ancestor: overlay),
      ),
      offset & overlay.size,
    );
    return position;
  }
  Future<bool?> _addword(BuildContext context) {
    return showDialog<bool>(
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
                controller: _engController,
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
                controller: _krController,
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
                    Navigator.pop(context, false);
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
                  onPressed: () async {
                    var result = Navigator.pop(context, true);
                  },
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
