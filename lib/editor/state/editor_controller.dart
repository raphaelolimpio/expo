import 'dart:math';

import 'package:expo/editor/models/block.dart';
import 'package:expo/editor/models/floor.dart';
import 'package:expo/editor/models/road.dart';
import 'package:flutter/material.dart';

enum ToolMode { select, addBlock, drawRoad }

class EditorController extends ChangeNotifier {
  final List<EditorFloor> floors = [EditorFloor(index: 0, name: 'Piso 1')];

  int activeFloorIndex = 0;
  ToolMode mode = ToolMode.select;

  EditorBlock? selectedBlock;
  EditorRoad? selectedRoad;

  bool isDrawingRoad = false;
  List<Offset> currentRoadPoints = [];

  EditorFloor get activeFloor => floors[activeFloorIndex];

  void setMode(ToolMode m) {
    mode = m;
    selectedBlock = null;
    selectedRoad = null;
    notifyListeners();
  }

  void addFloor() {
    floors.add(
      EditorFloor(index: floors.length, name: 'Piso ${floors.length + 1}'),
    );
    activeFloorIndex = floors.length - 1;
    selectedBlock = null;
    selectedRoad = null;
    notifyListeners();
  }

  void setActiveFloor(int i) {
    activeFloorIndex = i;
    selectedBlock = null;
    selectedRoad = null;
    notifyListeners();
  }

Rect rectFromSelection(
  Set<Offset> selected,
  double cellSize,
  double gap,
) {
  final rows = selected.map((o) => (o.dy ~/ (cellSize + gap)));
  final cols = selected.map((o) => (o.dx ~/ (cellSize + gap)));

  final minRow = rows.reduce((a, b) => a < b ? a : b);
  final maxRow = rows.reduce((a, b) => a > b ? a : b);
  final minCol = cols.reduce((a, b) => a < b ? a : b);
  final maxCol = cols.reduce((a, b) => a > b ? a : b);

  final left = minCol * (cellSize + gap);
  final top = minRow * (cellSize + gap);

  final width =
      (maxCol - minCol + 1) * cellSize + (maxCol - minCol) * gap;
  final height =
      (maxRow - minRow + 1) * cellSize + (maxRow - minRow) * gap;

  const inset = 2.0;

  return Rect.fromLTWH(
    left + inset,
    top + inset,
    width - inset * 2,
    height - inset * 2,
  );
}


  void createBlockAt(Offset center) {
    final id = _id();
    final rect = Rect.fromCenter(center: center, width: 90, height: 60);
    final block = EditorBlock(
      id: id,
      rect: rect,
      name: "Bloco ${activeFloor.blocks.length + 1}",
    );
    activeFloor.blocks.add(block);
    selectedBlock = block;
    selectedRoad = null;
    notifyListeners();
  }

  void selectAt(Offset p) {
    for (final b in activeFloor.blocks.reversed) {
      if (b.rect.contains(p)) {
        selectedBlock = b;
        selectedRoad = null;
        notifyListeners();
        return;
      }
    }
    selectedBlock = null;
    selectedRoad = null;
    notifyListeners();
  }
  void mergeSelectionIntoSingleBlock(Rect selectionRect) {
  final f = activeFloor;

  // 1) remove todos os blocos que estão 100% dentro da seleção
  f.blocks.removeWhere((b) => selectionRect.contains(b.rect.topLeft) &&
                              selectionRect.contains(b.rect.bottomRight));

  // 2) cria um bloco único grande
  final block = EditorBlock(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: "Loja",
    status: "livre",
    color: const Color(0xFF64B5F6),
    rect: selectionRect,
  );

  f.blocks.add(block);
  selectedBlock = block;
  notifyListeners();
}


  void moveSelectedBlock(Offset delta) {
    final b = selectedBlock;
    if (b == null) return;
    b.rect = b.rect.shift(delta);
    notifyListeners();
  }

  void resizeSelectedBlock(double w, double h) {
    final b = selectedBlock;
    if (b == null) return;
    b.rect = Rect.fromCenter(center: b.rect.center, width: w, height: h);
    notifyListeners();
  }

  void updateSelectedBlock({String? name, Color? color, String? status}) {
    final b = selectedBlock;
    if (b == null) return;
    if (name != null) b.name = name;
    if (color != null) b.color = color;
    if (status != null) b.status = status;
    notifyListeners();
  }

  void startRoad(Offset p) {
    isDrawingRoad = true;
    currentRoadPoints = [p];
    notifyListeners();
  }

  void addRoadPoint(Offset p) {
    if (!isDrawingRoad) return;
    currentRoadPoints.add(p);
    notifyListeners();
  }

  void finishRoad() {
    if (!isDrawingRoad) return;
    isDrawingRoad = false;

    if (currentRoadPoints.length >= 2) {
      activeFloor.roads.add(
        EditorRoad(id: _id(), points: List.of(currentRoadPoints)),
      );
    }
    currentRoadPoints = [];
    notifyListeners();
  }

  void cancelRoad() {
    isDrawingRoad = false;
    currentRoadPoints = [];
    notifyListeners();
  }
  void createBlockFromRect(Rect rect) {
  final f = activeFloor;

  final block = EditorBlock(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: "Loja",
    status: "livre",
    color: const Color(0xFF64B5F6),
    rect: rect,
  );

  f.blocks.add(block);
  selectedBlock = block;
  notifyListeners();
}


  String _id() =>
      "${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(999)}";
}
