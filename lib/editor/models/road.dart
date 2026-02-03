import 'package:flutter/material.dart';

class EditorRoad {
  final String id;
  List<Offset> points;
  double width;
  Color color;

  EditorRoad({
    required this.id,
    required this.points,
    this.width = 18.0,
    this.color = const Color(0xFF888888),
  });
}