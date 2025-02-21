import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mymedic1/screens/home/test/wordTest.dart';

import '../../../data/folder.dart';

class WordTestHome extends StatefulWidget {
  const WordTestHome({super.key});

  @override
  State<WordTestHome> createState() => _WordTestHomeState();
}

class _WordTestHomeState extends State<WordTestHome> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Folder>> getFolder() async {
    var snapshot = await firestore.collection('folder').get();
    List<Folder> folders = snapshot.docs.map((element) {
      Map<String, dynamic> map = element.data();
      return Folder(map['name'], map['wordCount'], element.id);
    }).toList();
    return folders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: FutureBuilder(
          future: getFolder(),
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

            final folders = snapshot.requireData;

            return Center(
              child: Card(
                child: Container(
                  width: 300,
                  height: 500,
                  child: ListView.builder(
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        onTap: () {Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext) =>
                                WordTest(folder: folders[index]),
                          ),
                        );},
                        title: Container(
                            height: 55,
                            child: Center(
                                child: Text(
                              folders[index].name,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ))),
                      ),
                    ),
                    itemCount: folders.length,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
