import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/db/note_helper.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NoteListState();
  }
}

class _NoteListState extends State<NoteList> {
  NoteHelper noteHelper = NoteHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateNoteList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          naviagateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: "Add new note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteList() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int pos) {
        return noteItem(context, titleStyle, pos);
      },
    );
  }

  Card noteItem(BuildContext context, titleStyle, int pos) {
    return Card(
      color: Colors.white,
      elevation: 3.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getPriorityColor(this.noteList[pos].priority),
          child: getPriorityIcon(this.noteList[pos].priority),
        ),
        title: Text(
          this.noteList[pos].title,
          style: titleStyle,
        ),
        subtitle: Text(this.noteList[pos].date),
        trailing: GestureDetector(
          onTap: () {
            _delete(context, noteList[pos]);
          },
          child: Icon(
            Icons.delete,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          naviagateToDetail(this.noteList[pos], 'Edit Note');
        },
      ),
    );
  }

  void naviagateToDetail(Note note, String title) async {
    bool res =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (res == true) {
      updateNoteList();
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await noteHelper.removeNote(note.id);
    if (result != 0) {
      _showSnackbar(context, "Succes delete");
      updateNoteList();
    }
  }

  void updateNoteList() {
    final Future<Database> dbUpdate = noteHelper.initializeDb();
    dbUpdate.then((database) {
      Future<List<Note>> noteListUpdate = noteHelper.getNoteList();
      noteListUpdate.then((items) {
        setState(() {
          this.noteList = items;
          this.count = items.length;
        });
      });
    });
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackbar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackbar);
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.arrow_upward);
        break;
      case 2:
        return Icon(Icons.remove);
        break;
      case 3:
        return Icon(Icons.arrow_downward);
        break;
      default:
        return Icon(Icons.arrow_downward);
    }
  }
}
