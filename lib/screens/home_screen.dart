import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/screens/note_editor.dart';

class HomeScreen extends StatefulWidget {
  final String currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box notesBox;
  bool showTrash = false;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box('notes');
  }

  List _userNotes() {
    final allNotes = notesBox.values.map((n) {
      if (n is Map) return Map<String, dynamic>.from(n);
      return <String, dynamic>{};
    }).toList();

    if (showTrash) {
      return allNotes
          .where(
            (n) =>
                (n['user'] ?? widget.currentUser) == widget.currentUser &&
                (n['deleted'] ?? false),
          )
          .toList();
    } else {
      return allNotes
          .where(
            (n) =>
                (n['user'] ?? widget.currentUser) == widget.currentUser &&
                !(n['deleted'] ?? false),
          )
          .toList();
    }
  }

  void _addNote() async {
    if (showTrash) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditor()),
    );

    if (result != null) {
      final newNote = <String, dynamic>{
        'title': result['title']?.trim() ?? '',
        'content': result['content']?.trim() ?? '',
        'user': widget.currentUser,
        'deleted': false,
      };
      notesBox.add(newNote);
      setState(() {});
    }
  }

  void _editNote(int index, Map note) async {
    if (showTrash) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditor(existingNote: note)),
    );

    if (result != null) {
      final updatedNote = <String, dynamic>{
        'title': result['title']?.trim() ?? '',
        'content': result['content']?.trim() ?? '',
        'user': widget.currentUser,
        'deleted': false,
      };
      notesBox.putAt(index, updatedNote);
      setState(() {});
    }
  }

  void _deleteNote(int index) {
    final note = Map<String, dynamic>.from(notesBox.getAt(index));
    if (showTrash) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Permanent Delete"),
          content: const Text(
            "Are you sure you want to permanently delete this note?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                notesBox.deleteAt(index);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      note['deleted'] = true;
      notesBox.putAt(index, note);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = _userNotes();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text(
          'Scribbler',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: notes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final note = notes[index];
            return GestureDetector(
              onTap: () => _editNote(index, note),
              child: NoteCard(note: note, onDelete: () => _deleteNote(index)),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.yellow[700],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showTrash = false;
                  });
                },
                child: Icon(
                  Icons.menu_book,
                  size: 28,
                  color: showTrash ? Colors.black54 : Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showTrash = true;
                  });
                },
                child: Icon(
                  Icons.delete,
                  size: 28,
                  color: showTrash ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: showTrash
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.yellow[700],
              onPressed: _addNote,
              child: const Icon(Icons.add, color: Colors.black),
            ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Map note;
  final VoidCallback onDelete;

  const NoteCard({super.key, required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['title'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note['content'] ?? '',
                style: const TextStyle(fontSize: 15, height: 1.3),
                overflow: TextOverflow.fade,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
