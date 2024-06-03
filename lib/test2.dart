import 'package:flutter/material.dart';

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  int a = 5;
  @override
  Widget build(BuildContext context) {
    List<int> list = [];

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('앱바'),
      ),
      body: Column(
        children: [
          Container(
            width: size.width * 0.3,
            height: size.height * 0.5,
            child: Text("Hello"),
            alignment: Alignment.center,
            // margin: EdgeInsets.only(top: 30),
            // padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(width: 10, color: Colors.indigoAccent),
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.green, Colors.blue],
                )),
          ),
          Container(
            width: size.width * 0.95,
            height: size.height * 0.2,
            decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(width: 5, color: Colors.orange)),
                    ),
                    Container(
                      child: Text('hhhhhiiii'),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'abbaaabbbbaaaaa',
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                'abbaaabbbb',
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                'abbaaa',
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                'home',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          Expanded(child: Container(child: Icon(Icons.more_horiz,), alignment: Alignment.centerRight,)),
                        ],
                      ),
                      Container(
                        width: size.width * 0.7,
                        height: size.height * 0.08,
                        decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            border: Border.all(width: 4, color: Colors.green),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              color: Colors.white,
                            ),
                            Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              color: Colors.white,
                            ),
                            Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
