import 'package:flutter/material.dart';

class NoteEditor extends StatefulWidget {
  final Map? existingNote;
  const NoteEditor({super.key, this.existingNote});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingNote?['title'] ?? '');
    _contentController =
        TextEditingController(text: widget.existingNote?['content'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('Edit Note',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, {
                'title': _titleController.text,
                'content': _contentController.text,
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: const InputDecoration(
                  hintText: 'Title', border: InputBorder.none),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                    hintText: 'Content', border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
