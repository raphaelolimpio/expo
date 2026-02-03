import 'dart:math';
import 'package:flutter/material.dart';
import 'editor_state.dart';
import 'editor_models.dart';

class MapPainter extends CustomPainter {
  final EditorState state;

  MapPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final gridW = state.gridCols * state.cellSize;
    final gridH = state.gridRows * state.cellSize;

    // fundo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gridW, gridH),
      Paint()..color = Colors.white,
    );
    // ✅ background image (se existir)
final bg = state.backgroundImage;
if (bg != null) {
  // desenha encaixado no grid todo (0..gridW, 0..gridH)
  paintImage(
    canvas: canvas,
    rect: Rect.fromLTWH(0, 0, gridW, gridH),
    image: bg,
    fit: BoxFit.cover,
    opacity: state.backgroundOpacity, // controla transparência
    filterQuality: FilterQuality.low,
  );
}


    // grid
    final paintGrid = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    for (int x = 0; x <= state.gridCols; x++) {
      final dx = x * state.cellSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, gridH), paintGrid);
    }
    for (int y = 0; y <= state.gridRows; y++) {
      final dy = y * state.cellSize;
      canvas.drawLine(Offset(0, dy), Offset(gridW, dy), paintGrid);
    }

    // desenhar ruas primeiro
    for (final road in state.currentFloor.roads) {
      for (final c in road.cells) {
        final rect = Rect.fromLTWH(
          c.x * state.cellSize,
          c.y * state.cellSize,
          state.cellSize,
          state.cellSize,
        );
        canvas.drawRect(rect.deflate(1), Paint()..color = road.color);
      }
    }
for (final block in state.currentFloor.blocks) {
  final fillPaint = Paint()..color = block.color;

  final cellsSet = <String>{};
  for (final c in block.cells) {
    cellsSet.add("${c.x}:${c.y}");
  }

  for (final c in block.cells) {
    final rect = Rect.fromLTWH(
      c.x * state.cellSize,
      c.y * state.cellSize,
      state.cellSize,
      state.cellSize,
    );
    canvas.drawRect(rect, fillPaint);
  }

  final outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.blueAccent;

  for (final c in block.cells) {
    final x = c.x;
    final y = c.y;

    final left = x * state.cellSize;
    final top = y * state.cellSize;
    final right = left + state.cellSize;
    final bottom = top + state.cellSize;

    if (!cellsSet.contains("${x - 1}:${y}")) {
      canvas.drawLine(Offset(left, top), Offset(left, bottom), outlinePaint);
    }
    if (!cellsSet.contains("${x + 1}:${y}")) {
      canvas.drawLine(Offset(right, top), Offset(right, bottom), outlinePaint);
    }
    if (!cellsSet.contains("${x}:${y - 1}")) {
      canvas.drawLine(Offset(left, top), Offset(right, top), outlinePaint);
    }
    if (!cellsSet.contains("${x}:${y + 1}")) {
      canvas.drawLine(Offset(left, bottom), Offset(right, bottom), outlinePaint);
    }
  }
}


    if (state.selectedBlock != null) {
      for (final c in state.selectedBlock!.cells) {
        final rect = Rect.fromLTWH(
          c.x * state.cellSize,
          c.y * state.cellSize,
          state.cellSize,
          state.cellSize,
        );
        canvas.drawRect(
          rect.deflate(1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.deepPurple,
        );
      }
    }
    if (state.selectedRoad != null) {
      for (final c in state.selectedRoad!.cells) {
        final rect = Rect.fromLTWH(
          c.x * state.cellSize,
          c.y * state.cellSize,
          state.cellSize,
          state.cellSize,
        );
        canvas.drawRect(
          rect.deflate(1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.deepPurple,
        );
      }
    }

    if (state.areaStart != null && state.areaEnd != null) {
      final minX = min(state.areaStart!.x, state.areaEnd!.x);
      final maxX = max(state.areaStart!.x, state.areaEnd!.x);
      final minY = min(state.areaStart!.y, state.areaEnd!.y);
      final maxY = max(state.areaStart!.y, state.areaEnd!.y);

      final rect = Rect.fromLTWH(
        minX * state.cellSize,
        minY * state.cellSize,
        (maxX - minX + 1) * state.cellSize,
        (maxY - minY + 1) * state.cellSize,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.deepPurple.withOpacity(0.9),
      );

      canvas.drawRect(
        rect,
        Paint()..color = Colors.deepPurple.withOpacity(0.10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}
