import 'package:flutter/material.dart';

class Board {
  static const tableName = 'boards';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnBody = 'body';
  static const columnCreateAt = 'createAt';

  final String title;
  final String body;
  final String? id;
   String uid;
  final String createAt;

  Board(this.title, this.body, this.id, this.uid, this.createAt);

// Board.fromRow(Map<String, dynamic> row)
  //     : this(
  //         row[columnBody],
  //         row[columnCreateAt],
  //         id: row[columnId],
  //         title: row[columnTitle],
  //       );
  //
  // Map<String, dynamic> toRow() {
  //   return {
  //     columnTitle: title,
  //     columnBody: body,
  //     columnCreateAt: DateTime.now().toString()
  //   };
  // }
}
