import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/notes/widgets/note_item.dart';

class notes extends StatefulWidget {
  const notes({super.key});
  static String id = 'note id';
  @override
  State<notes> createState() => _notesState();
}

class _notesState extends State<notes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Constants.getPrimaryColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'نوتس',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            note_item(note_title: 'note_title', date: DateTime.now()),
            note_item(note_title: 'note_title', date: DateTime.now()),
            note_item(note_title: 'note_title', date: DateTime.now()),
            note_item(note_title: 'note_title', date: DateTime.now()),
            note_item(note_title: 'note_title', date: DateTime.now())
          ],
        ),
      ),
    );
  }
}
