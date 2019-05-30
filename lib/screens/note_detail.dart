import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:notekeeper/db/note_helper.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/components/input_text.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return _NoteDetailState(this.note, this.appBarTitle);
  }
}

class _NoteDetailState extends State<NoteDetail> {
  NoteHelper noteHelper = NoteHelper();

  String appBarTitle;
  Note note;
  _NoteDetailState(this.note, this.appBarTitle);
  var _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  var _listPriority = ['High', 'Medium', 'Low'];
  var _curPriority;

  @override
  void initState() {
    super.initState();
    _curPriority = _listPriority[0];
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    if (note.id != null) {
      titleController.text = note.title;
      descController.text = note.description;
    }
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              goback();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: noteForm(textStyle),
        ),
      ),
      onWillPop: () {
        goback();
      },
    );
  }

  Form noteForm(TextStyle textStyle) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          dropdownList(_listPriority, _curPriority, textStyle),
          InputText(
            controller: titleController,
            hint: 'Your Note Title',
            type: 'Title',
          ),
          InputText(
            controller: descController,
            hint: 'Your Note Description',
            type: 'Description',
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: buttonAction('Save'),
              ),
              Expanded(
                child: buttonAction('Delete'),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget dropdownList(_items, _curItem, TextStyle _textStyle) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
      child: DropdownButton<String>(
        items: _items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            child: Text(value),
            value: value,
          );
        }).toList(),
        value: priorityName(note.priority),
        style: _textStyle,
        onChanged: (String selectedValue) {
          _onSelectedDropdown(selectedValue);
          priorityId(selectedValue);
        },
      ),
    );
  }

  Widget inputText(String type, String hint, controller) {
    return Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
        child: TextFormField(
          controller: controller,
          validator: (String value) {
            return _validateInput(value);
          },
          decoration: InputDecoration(
              labelText: type,
              hintText: hint,
              errorStyle: TextStyle(
                color: Colors.redAccent,
                fontSize: 15.0,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        ));
  }

  Widget buttonAction(String type) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: RaisedButton(
        color: Colors.purple,
        textColor: Colors.white,
        child: Text(
          type,
          textScaleFactor: 1.5,
        ),
        onPressed: () {
          if (type == "Save") {
            if (_formKey.currentState.validate()) {
              _saveNote();
            }
          } else {
            _deleteNote();
          }
        },
      ),
    );
  }

  void _onSelectedDropdown(String newValue) {
    setState(() {
      this._curPriority = newValue;
    });
  }

  String _validateInput(String value) {
    if (value.isEmpty) {
      return 'Your input is empty';
    } else {
      return null;
    }
  }

  void priorityId(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Medium':
        note.priority = 2;
        break;
      case 'Low':
        note.priority = 3;
        break;
      default:
        break;
    }
  }

  String priorityName(int value) {
    switch (value) {
      case 1:
        return _listPriority[0];
        break;
      case 2:
        return _listPriority[1];
        break;
      case 3:
        return _listPriority[2];
        break;
      default:
        return _curPriority;
        break;
    }
  }

  void _saveNote() async {
    note.title = titleController.text;
    note.description = descController.text;
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int res;
    if (note.id != null) {
      res = await noteHelper.editNote(note);
    } else {
      res = await noteHelper.addNote(note);
    }

    if (res != 0) {
      goback();
      _showAlertDialog("Succes", "Succes Save Note");
    } else {
      _showAlertDialog("Failure", "Failed Save Note");
    }
  }

  void _deleteNote() async {
    if (note.id == null) {
      _showAlertDialog("Status", "No noted was deleted");
      return;
    }
    int res = await noteHelper.removeNote(note.id);

    if (res != 0) {
      goback();
      _showAlertDialog("Succes", "Succes Delete Note");
    } else {
      _showAlertDialog("Failure", "Failed Delete Note");
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void goback() {
    Navigator.pop(context, true);
  }
}
