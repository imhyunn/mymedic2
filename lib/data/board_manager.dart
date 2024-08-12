// import 'package:sqflite/sqflite.dart';
// import 'package:mymedic1/data/board.dart';
//
// class BoardManager {
//   static const _databaseName = 'boards.db';
//
//   static const _databaseVersion = 1;
//
//   Database? _database;
//
//   Future<void> addBoard(Board board) async {
//     final db = await _getDatabase();
//     await db.insert(Board.tableName, board.toRow());
//   }
//
//   Future<void> deleteBoard(int id) async {
//     final db = await _getDatabase();
//     await db.delete(
//       Board.tableName,
//       where: '${Board.columnId} = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<Board> getBoard(int id) async {
//     final db = await _getDatabase();
//     final rows = await db.query(
//       Board.tableName,
//       where: '${Board.columnId} = ?',
//       whereArgs: [id],
//     );
//     return Board.fromRow(rows.single);
//   }
//
//   Future<List<Board>> listBoards() async {
//     final db = await _getDatabase();
//     final rows = await db.query(Board.tableName);
//     return rows.map((row) => Board.fromRow(row)).toList();
//   }
//
//   Future<void> updateBoard(int id, Board board) async {
//     final db = await _getDatabase();
//     await db.update(
//       Board.tableName,
//       board.toRow(),
//       where: '${Board.columnId} = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<Database> _getDatabase() async {
//     if (_database == null) {
//       _database = await openDatabase(
//         _databaseName,
//         version: _databaseVersion,
//         onCreate: (db, version) {
//           final sql = '''
//       CREATE TABLE ${Board.tableName} (
//         ${Board.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
//         ${Board.columnTitle} TEXT,
//         ${Board.columnBody} TEXT NOT NULL,
//         ${Board.columnCreateAt} DATETIME
//       )
//     ''';
//
//           return db.execute(sql);
//         },
//       );
//     }
//     return _database!;
//   }
// }
