import 'package:expo/editor/models/block.dart';
import 'package:expo/editor/models/road.dart';

class EditorFloor {
  final int index;
  final String name;
  final List<EditorBlock> blocks;
  final List<EditorRoad> roads;
  String? backgroundBase64;

  EditorFloor({
    required this.index,
    required this.name,
    List<EditorBlock>? blocks,
    List<EditorRoad>? roads,
  }) : blocks = blocks ?? [],
       roads = roads ?? [];
}
