import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final Map<String, String> note;
  final VoidCallback onArchiveToggle;
  final bool isArchived;
  final Color cardColor;

  const NoteCard({
    super.key,
    required this.note,
    required this.onArchiveToggle,
    required this.isArchived,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    note['content'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  isArchived ? Icons.unarchive : Icons.archive,
                  size: 20,
                ),
                onPressed: onArchiveToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
