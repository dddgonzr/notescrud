import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {

await Firebase.initializeApp(
  options: const FirebaseOptions(
   apiKey: 'AIzaSyAmGEMDioiAH1ZKLS0YCdS3pzqmbe6MrVQ',
    appId: '1:15003641341:web:c77f1ca69683e3aad52594',
    messagingSenderId: '15003641341',
    projectId: 'notescrud-e1531',
    authDomain: 'notescrud-e1531.firebaseapp.com',
    storageBucket: 'notescrud-e1531.appspot.com',
    ),
  );


  runApp( NotesApp());
}


class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Notes App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final TextEditingController _noteController = TextEditingController();

  
  Future<void> _createNote() async {
    if (_noteController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notes').add({
        'content': _noteController.text,
        'createdAt': Timestamp.now(),
      });
      _noteController.clear();
    }
  }

  
  Stream<QuerySnapshot> _readNotes() {
    return FirebaseFirestore.instance.collection('notes').orderBy('createdAt', descending: true).snapshots();
  }

 
  Future<void> _updateNote(String id, String newContent) async {
    await FirebaseFirestore.instance.collection('notes').doc(id).update({
      'content': newContent,
    });
  }

 
  Future<void> _deleteNote(String id) async {
    await FirebaseFirestore.instance.collection('notes').doc(id).delete();
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Note'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(hintText: 'Enter your note here'),
          ),
          actions: [
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _createNote();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateNoteDialog(String id, String currentContent) {
    TextEditingController _updateController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Note'),
          content: TextField(
            controller: _updateController,
            decoration: InputDecoration(hintText: 'Update your note here'),
          ),
          actions: [
            TextButton(
              child: Text('Update'),
              onPressed: () {
                _updateNote(id, _updateController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _readNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aún no tienes notas'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['content']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        _showUpdateNoteDialog(doc.id, doc['content']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}