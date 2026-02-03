import 'dart:math';
import 'dart:ui';

List<Offset> buildOutline(List<Point<int>> cells, double cellSize) {
  final cellSet = cells.toSet();
  final edges = <Offset>[];

  bool hasCell(int x, int y) {
    return cellSet.contains(Point(x, y));
  }

  for (final cell in cells) {
    final x = cell.x;
    final y = cell.y;

    final left = !hasCell(x - 1, y);
    final right = !hasCell(x + 1, y);
    final top = !hasCell(x, y - 1);
    final bottom = !hasCell(x, y + 1);

    final px = x * cellSize;
    final py = y * cellSize;

    if (top) {
      edges.add(Offset(px, py));
      edges.add(Offset(px + cellSize, py));
    }
    if (right) {
      edges.add(Offset(px + cellSize, py));
      edges.add(Offset(px + cellSize, py + cellSize));
    }
    if (bottom) {
      edges.add(Offset(px + cellSize, py + cellSize));
      edges.add(Offset(px, py + cellSize));
    }
    if (left) {
      edges.add(Offset(px, py + cellSize));
      edges.add(Offset(px, py));
    }
  }

  return edges;
}
