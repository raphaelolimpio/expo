import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/editor_controller.dart';

class EditorCanvas extends StatefulWidget {
  const EditorCanvas({super.key});

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  Offset? _lastDrag;

  // NOVO: seleção por área
  Offset? _selectStart;
  Offset? _selectEnd;

  static const double cellSize = 40.0;
  static const double gap = 0.0; // <- sem espaços. Se quiser divisória, use 2.0

  @override
  Widget build(BuildContext context) {
    final c = context.watch<EditorController>();

    return GestureDetector(
      onTapDown: (d) {
        final p = d.localPosition;

        if (c.mode == ToolMode.addBlock) {
          c.createBlockAt(p);
          c.setMode(ToolMode.select);
          return;
        }

        if (c.mode == ToolMode.select) {
          c.selectAt(p);
          return;
        }
      },

      onPanStart: (d) {
        final p = d.localPosition;
        _lastDrag = p;

        if (c.mode == ToolMode.drawRoad) {
          c.startRoad(p);
          return;
        }

        // NOVO: começar seleção por área (drag)
        if (c.mode == ToolMode.select) {
          setState(() {
            _selectStart = p;
            _selectEnd = p;
          });
        }
      },

      onPanUpdate: (d) {
        final p = d.localPosition;

        if (c.mode == ToolMode.drawRoad) {
          c.addRoadPoint(p);
          return;
        }

        // NOVO: atualizar seleção por área
        if (c.mode == ToolMode.select && _selectStart != null) {
          setState(() {
            _selectEnd = p;
          });
          return;
        }

        // mover bloco (como você já tinha)
        final last = _lastDrag;
        if (last == null) return;
        final delta = p - last;
        _lastDrag = p;

        if (c.mode == ToolMode.select && c.selectedBlock != null) {
          c.moveSelectedBlock(delta);
        }
      },

      onPanEnd: (_) {
        _lastDrag = null;

        if (c.mode == ToolMode.select &&
            _selectStart != null &&
            _selectEnd != null) {
          final rect = _rectFromDrag(_selectStart!, _selectEnd!);
          final snapped = _snapRectToGrid(rect);

          c.mergeSelectionIntoSingleBlock(snapped);

          setState(() {
            _selectStart = null;
            _selectEnd = null;
          });
        }
      },

      child: CustomPaint(
        painter: _EditorPainter(controller: c, selectionRect: _selectionRect()),
        size: Size.infinite,
      ),
    );
  }

  Rect? _selectionRect() {
    if (_selectStart == null || _selectEnd == null) return null;
    return _rectFromDrag(_selectStart!, _selectEnd!);
  }

  Rect _rectFromDrag(Offset a, Offset b) {
    final left = a.dx < b.dx ? a.dx : b.dx;
    final right = a.dx > b.dx ? a.dx : b.dx;
    final top = a.dy < b.dy ? a.dy : b.dy;
    final bottom = a.dy > b.dy ? a.dy : b.dy;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _snapRectToGrid(Rect rect) {
    // converte pixels -> índices de célula (row/col)
    final minCol = (rect.left ~/ (cellSize + gap));
    final maxCol = (rect.right ~/ (cellSize + gap));
    final minRow = (rect.top ~/ (cellSize + gap));
    final maxRow = (rect.bottom ~/ (cellSize + gap));

    final left = minCol * (cellSize + gap);
    final top = minRow * (cellSize + gap);

    // largura e altura em células (inclui última célula)
    final cols = (maxCol - minCol).clamp(0, 999) + 1;
    final rows = (maxRow - minRow).clamp(0, 999) + 1;

    final width = cols * cellSize + (cols - 1) * gap;
    final height = rows * cellSize + (rows - 1) * gap;

    return Rect.fromLTWH(left, top, width, height);
  }
}

class _EditorPainter extends CustomPainter {
  final EditorController controller;
  final Rect? selectionRect;
  _EditorPainter({required this.controller, this.selectionRect});

  @override
  void paint(Canvas canvas, Size size) {
    // fundo
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF6F7F9),
    );

    _drawGrid(canvas, size);

    if (selectionRect != null) {
      final fill = Paint()
        ..color = Colors.blue.withOpacity(0.12)
        ..style = PaintingStyle.fill;

      final border = Paint()
        ..color = Colors.blue.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(selectionRect!, fill);
      canvas.drawRect(selectionRect!, border);
    }

    final floor = controller.activeFloor;

    for (final r in floor.roads) {
      final p = Paint()
        ..color = r.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(r.points.first.dx, r.points.first.dy);
      for (final pt in r.points.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, p);
    }

    if (controller.isDrawingRoad && controller.currentRoadPoints.length >= 2) {
      final p = Paint()
        ..color = const Color(0xFF90A4AE).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;

      final pts = controller.currentRoadPoints;
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final pt in pts.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, p);
    }

    for (final b in floor.blocks) {
      final fill = Paint()
        ..color = b.color.withOpacity(0.85)
        ..style = PaintingStyle.fill;

      final border = Paint()
        ..color = b.color.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(b.rect, const Radius.circular(8)),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(b.rect, const Radius.circular(8)),
        border,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: b.name,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: "...",
      )..layout(maxWidth: b.rect.width - 10);

      tp.paint(canvas, b.rect.topLeft + const Offset(6, 6));
    }

    final sel = controller.selectedBlock;
    if (sel != null) {
      final p = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(sel.rect.inflate(3), const Radius.circular(10)),
        p,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final step = 40.0;
    final p = Paint()
      ..color = const Color(0xFFE3E7EF)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _EditorPainter oldDelegate) => true;
}
