import 'package:notebook/dao/table/ITable.dart';
import 'package:notebook/dao/Note.dart';
import 'package:notebook/dao/table/NoteTable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  static Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'notes.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    var noteBookSql = _getSql(new NoteTable());
    await db.execute(noteBookSql);
  }

  String _getSql(ITable table) {
    var sql = "";
    sql += "CREATE TABLE ${table.name}(";
    for (int i = 0; i < table.keys.length; i++) {
      if (i == 0) {
        sql += "${table.keys[i]} ${table.types[i]} PRIMARY KEY AUTOINCREMENT";
        continue;
      } else {
        sql += ", ${table.keys[i]} ${table.types[i]}";
      }
      if (i == table.keys.length - 1) {
        sql += ")";
      }
    }
    return sql;
  }

  Future<int> saveNote(Note note) async {
    var dbClient = await db;
    var result = await dbClient.insert(NoteTable().name, note.toJson());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');

    return result;
  }

  Future<List> getAllNotes() async {
    var dbClient = await db;
    var result =
        await dbClient.query(NoteTable().name, columns: NoteTable().keys);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote');

    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM ${NoteTable().name}'));
  }

  Future<Note> getNote(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(NoteTable().name,
        columns: NoteTable().keys,
        where: '${NoteTable().keys[0]} = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');

    if (result.length > 0) {
      return Note.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteNote(String id) async {
    var dbClient = await db;
    return await dbClient.delete(NoteTable().name,
        where: '${NoteTable().keys[0]} = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<int> updateNote(Note note) async {
    var dbClient = await db;
    return await dbClient.update(NoteTable().name, note.toJson(),
        where: "${NoteTable().keys[0]} = ?", whereArgs: [note.id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
