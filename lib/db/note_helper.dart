import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:notekeeper/models/note.dart';

class NoteHelper {
  static NoteHelper _noteHelper; //singleton helper
  static Database _database;

  String tableName = 'tbl_note';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  NoteHelper._createInstance(); //constuctor name to create instance

  factory NoteHelper() {
    if (_noteHelper == null) {
      _noteHelper = NoteHelper._createInstance(); //execute 1 time
    }
    return _noteHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDb();
    }
    return _database;
  }

  Future<Database> initializeDb() async {
    //get dirodtory path
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'notes.db';
    //open/create db
    var noteDb = openDatabase(path, version: 1, onCreate: _createDb);
    return noteDb;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

  //FETCH
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database _db = await this.database;

    //select using raw query
    // var res = await _db
    // .rawQuery('SELECT * FROM $tableName ORDER BY $colPriority ASC');
    //select using query
    var res = await _db.query(tableName, orderBy: '$colPriority ASC');
    return res;
  }

  //INSERT
  Future<int> addNote(Note note) async {
    Database _db = await this.database;
    var res = await _db.insert(tableName, note.toMap());
    return res;
  }

  //UPDATE
  Future<int> editNote(Note note) async {
    Database _db = await this.database;
    var res = await _db.update(tableName, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return res;
  }

  //DELETE
  Future<int> removeNote(int id) async {
    Database _db = await this.database;
    var res = await _db.delete(tableName, where: '$colId = ?', whereArgs: [id]);
    return res;
  }

  //GET COUNT
  Future<int> countNote() async {
    Database _db = await this.database;
    List<Map<String, dynamic>> x =
        await _db.rawQuery('SELECT COUNT (*) FROM $tableName');
    int res = Sqflite.firstIntValue(x);
    return res;
  }

  //CONVERT MAPLIST TO NOTE LIST
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    List<Note> noteList = List<Note>();
    for (int i = 0; i < noteMapList.length; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
