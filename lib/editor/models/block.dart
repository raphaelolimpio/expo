import 'dart:ui';

class EditorBlock {
  final String id;
  Rect rect;
  String name;
  Color color;
  String status;

  EditorBlock({
    required this.id,
    required this.rect,
    this.name = 'Bloco',
    this.color = const Color(0xFF4CAF50),
    this.status = 'livre',
  });
}
