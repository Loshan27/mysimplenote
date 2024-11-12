import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Simple Note',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await _dbHelper.queryAll();
    setState(() {
      _notes = data.map((item) => Note.fromMap(item)).toList();
    });
  }

  void _addOrEditNote({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
    if (result == true) {
      _refreshNotes();
    }
  }

  void _deleteNote(int id) async {
    await _dbHelper.delete(id);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Simple Note'),
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () => _addOrEditNote(note: note),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNote(note.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  NoteDetailScreen({this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title;
      _content = widget.note!.content;
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final note = Note(
        id: widget.note?.id,
        title: _title,
        content: _content,
      );
      if (widget.note == null) {
        await DatabaseHelper().insert(note.toMap());
      } else {
        await DatabaseHelper().update(note.toMap());
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(labelText: 'Content'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
                onSaved: (value) => _content = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}