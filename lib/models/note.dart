class Note {
  String title;
  String content;
  bool isArchived;

  Note({
    required this.title,
    required this.content,
    this.isArchived = false,
  });
}
