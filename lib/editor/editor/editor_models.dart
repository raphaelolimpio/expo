import 'dart:ui';

enum TileKind { block, road }

class FloorData {
  final String id;
  String name;

  // ✅ NOVO: imagem de fundo persistida (base64)
  String? backgroundBase64;

  /// Entidades (de verdade)
  final List<BlockEntity> blocks;
  final List<RoadEntity> roads;

  FloorData({
    required this.id,
    required this.name,
    this.backgroundBase64, // ✅ NOVO
    List<BlockEntity>? blocks,
    List<RoadEntity>? roads,
  })  : blocks = blocks ?? [],
        roads = roads ?? [];
}


class Cell {
  final int x;
  final int y;
  const Cell(this.x, this.y);

  @override
  String toString() => "$x:$y";
}

enum BlockStatus { livre, reservado, ocupado }

class BlockEntity {
  final String id;
  String name;
  String code;
  String type; 
  String description;
  BlockStatus status;
  Color color;
  final List<Cell> cells;

  BlockEntity({
    this.description = "",
    required this.id,
    required this.cells,
    this.name = "",
    this.code = "",
    this.type = "stand",
    this.status = BlockStatus.livre,
    this.color = const Color(0xFF7DD3FC),
  });
}

class RoadEntity {
  final String id;
  String name;
  Color color;
  final List<Cell> cells;

  RoadEntity({
    required this.id,
    required this.cells,
    this.name = "",
    this.color = const Color(0xFFE5E7EB),
  });
}
