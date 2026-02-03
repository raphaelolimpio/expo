import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'editor_models.dart';
import 'dart:convert';
import 'dart:ui' as ui;

enum EditorTool { select, selectArea, addBlockBrush, addRoadBrush, erase }

class EditorState extends ChangeNotifier {
  final List<FloorData> floors = [
    FloorData(id: "f1", name: "Piso 1"),
  ];
  ui.Image? backgroundImage;
double backgroundOpacity = 0.55; // slider depois

Future<void> setBackgroundFromBytes(Uint8List bytes) async {
  currentFloor.backgroundBase64 = base64Encode(bytes);

  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  backgroundImage = frame.image;

  notifyListeners();
}

  int floorIndex = 0;
  EditorTool tool = EditorTool.select;

  /// Grid config
  double cellSize = 28;
  int gridCols = 40;
  int gridRows = 60;

  /// Seleção atual (um bloco/rua)
  BlockEntity? selectedBlock;
  RoadEntity? selectedRoad;

  /// Seleção por área (retângulo)
  Cell? areaStart;
  Cell? areaEnd;

  FloorData get currentFloor => floors[floorIndex];

  void setTool(EditorTool t) {
    tool = t;
    // ao trocar ferramenta, limpa seleção de área
    areaStart = null;
    areaEnd = null;
    notifyListeners();
  }

List<Cell> cellsFromArea(Cell a, Cell b) {
  final minX = a.x < b.x ? a.x : b.x;
  final maxX = a.x > b.x ? a.x : b.x;
  final minY = a.y < b.y ? a.y : b.y;
  final maxY = a.y > b.y ? a.y : b.y;

  final cells = <Cell>[];

  for (int y = minY; y <= maxY; y++) {
    for (int x = minX; x <= maxX; x++) {
      cells.add(Cell(x, y));
    }
  }

  return cells;
}



void createBlockFromSelectedArea() {
  if (areaStart == null || areaEnd == null) return;

  final cells = cellsFromArea(areaStart!, areaEnd!);
  if (cells.isEmpty) return;

  // Evita sobreposição (opcional, mas recomendo)
  for (final c in cells) {
    eraseCell(c);
  }

  final block = BlockEntity(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    cells: cells, // ✅ agora é List<Cell>
    color: Colors.lightBlueAccent,
    name: "Novo local",
    code: "",
    type: "Sala",
    status: BlockStatus.livre,
  );

  currentFloor.blocks.add(block);

  selectedBlock = block;
  selectedRoad = null;

  areaStart = null;
  areaEnd = null;

  notifyListeners();
}




  Future<void> loadBackgroundFromCurrentFloor() async {
  final b64 = currentFloor.backgroundBase64;
  if (b64 == null || b64.isEmpty) {
    backgroundImage = null;
    notifyListeners();
    return;
  }

  final bytes = base64Decode(b64);
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  backgroundImage = frame.image;

  notifyListeners();
}


  void addFloor() {
    floors.add(FloorData(
      id: "f${floors.length + 1}",
      name: "Piso ${floors.length + 1}",
    ));
    floorIndex = floors.length - 1;
    clearSelection();
    backgroundImage = null;
    notifyListeners();
  }

  void selectFloor(int index) {
    floorIndex = index;
    clearSelection();
    loadBackgroundFromCurrentFloor();
  }

  void clearSelection() {
    selectedBlock = null;
    selectedRoad = null;
    areaStart = null;
    areaEnd = null;
  }

  /// Converte ponto (px) em célula (x,y)
  Cell? pointToCell(Offset localPos) {
    final x = (localPos.dx / cellSize).floor();
    final y = (localPos.dy / cellSize).floor();
    if (x < 0 || y < 0 || x >= gridCols || y >= gridRows) return null;
    return Cell(x, y);
  }

  /// Retorna células do retângulo selecionado
  List<Cell> get selectedAreaCells {
    if (areaStart == null || areaEnd == null) return [];
    final minX = min(areaStart!.x, areaEnd!.x);
    final maxX = max(areaStart!.x, areaEnd!.x);
    final minY = min(areaStart!.y, areaEnd!.y);
    final maxY = max(areaStart!.y, areaEnd!.y);

    final cells = <Cell>[];
    for (int x = minX; x <= maxX; x++) {
      for (int y = minY; y <= maxY; y++) {
        cells.add(Cell(x, y));
      }
    }
    return cells;
  }

  bool get hasAreaSelection => selectedAreaCells.isNotEmpty;

  /// Hit-test: encontra bloco/rua que contém a célula
  void selectEntityAt(Cell c) {
    selectedBlock = null;
    selectedRoad = null;

    // bloco tem prioridade
    for (final b in currentFloor.blocks) {
      if (b.cells.any((cc) => cc.x == c.x && cc.y == c.y)) {
        selectedBlock = b;
        notifyListeners();
        return;
      }
    }
    for (final r in currentFloor.roads) {
      if (r.cells.any((cc) => cc.x == c.x && cc.y == c.y)) {
        selectedRoad = r;
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }

  /// Pintar células (brush) - adiciona ao bloco/rua "rascunho" simples
  void paintCellAsBlock(Cell c) {
    // cria um bloco novo por célula (pode ser melhorado depois com merge)
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    currentFloor.blocks.add(BlockEntity(
      id: id,
      cells: [c],
      color: const Color(0xFF7DD3FC),
    ));
    notifyListeners();
  }

  void paintCellAsRoad(Cell c) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    currentFloor.roads.add(RoadEntity(
      id: id,
      cells: [c],
      color: const Color(0xFFE5E7EB),
    ));
    notifyListeners();
  }

  /// Borracha: remove célula de qualquer entidade
  void eraseCell(Cell c) {
    // remove de blocos
    for (final b in List<BlockEntity>.from(currentFloor.blocks)) {
      b.cells.removeWhere((cc) => cc.x == c.x && cc.y == c.y);
      if (b.cells.isEmpty) currentFloor.blocks.remove(b);
    }
    // remove de ruas
    for (final r in List<RoadEntity>.from(currentFloor.roads)) {
      r.cells.removeWhere((cc) => cc.x == c.x && cc.y == c.y);
      if (r.cells.isEmpty) currentFloor.roads.remove(r);
    }
    notifyListeners();
  }

  /// Cria 1 bloco/rua único a partir do retângulo selecionado (agrupado)
  void createBlockFromSelection({
    String name = "",
    String code = "",
    String type = "stand",
    BlockStatus status = BlockStatus.livre,
    Color color = const Color(0xFF7DD3FC),
  }) {
    final cells = selectedAreaCells;
    if (cells.isEmpty) return;

    // limpa células que já estão em outras entidades (evita sobreposição)
    for (final c in cells) {
      eraseCell(c);
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final b = BlockEntity(
      id: id,
      cells: cells,
      name: name,
      code: code,
      type: type,
      status: status,
      color: color,
    );
    currentFloor.blocks.add(b);

    // seleciona ele
    selectedBlock = b;
    selectedRoad = null;

    // limpa seleção de área
    areaStart = null;
    areaEnd = null;

    notifyListeners();
  }

  void createRoadFromSelection({
    String name = "",
    Color color = const Color(0xFFE5E7EB),
  }) {
    final cells = selectedAreaCells;
    if (cells.isEmpty) return;

    for (final c in cells) {
      eraseCell(c);
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final r = RoadEntity(
      id: id,
      cells: cells,
      name: name,
      color: color,
    );
    currentFloor.roads.add(r);

    selectedRoad = r;
    selectedBlock = null;

    areaStart = null;
    areaEnd = null;

    notifyListeners();
  }

  /// Atualiza propriedades do selecionado
  void updateSelectedBlock({
    String? name,
    String? code,
    String? type,
    BlockStatus? status,
    Color? color,
  }) {
    final b = selectedBlock;
    if (b == null) return;
    if (name != null) b.name = name;
    if (code != null) b.code = code;
    if (type != null) b.type = type;
    if (status != null) b.status = status;
    if (color != null) b.color = color;
    notifyListeners();
  }

  void updateSelectedRoad({
    String? name,
    Color? color,
  }) {
    final r = selectedRoad;
    if (r == null) return;
    if (name != null) r.name = name;
    if (color != null) r.color = color;
    notifyListeners();
  }

  String toolLabel() {
    switch (tool) {
      case EditorTool.select:
        return "Selecionar";
      case EditorTool.selectArea:
        return "Selecionar área";
      case EditorTool.addBlockBrush:
        return "Pincel bloco";
      case EditorTool.addRoadBrush:
        return "Pincel rua";
      case EditorTool.erase:
        return "Borracha";
    }
  }
}
