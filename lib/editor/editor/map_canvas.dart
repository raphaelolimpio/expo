import 'package:flutter/material.dart';
import 'editor_state.dart';
import 'map_painter.dart';

class MapCanvas extends StatefulWidget {
  final EditorState state;
  final VoidCallback onOpenProperties;

  const MapCanvas({
    super.key,
    required this.state,
    required this.onOpenProperties,
  });

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  bool _dragging = false;

  Size get worldSize => Size(
    widget.state.gridCols * widget.state.cellSize,
    widget.state.gridRows * widget.state.cellSize,
  );

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      boundaryMargin: const EdgeInsets.all(200),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // TAP
        onTapDown: (d) {
          final cell = widget.state.pointToCell(d.localPosition);
          if (cell == null) return;

          switch (widget.state.tool) {
            case EditorTool.select:
              widget.state.selectEntityAt(cell);
              widget.onOpenProperties();
              return;

            case EditorTool.addBlockBrush:
              widget.state.paintCellAsBlock(cell);
              return;

            case EditorTool.addRoadBrush:
              widget.state.paintCellAsRoad(cell);
              return;

            case EditorTool.erase:
              widget.state.eraseCell(cell);
              return;

            case EditorTool.selectArea:
              // um toque define início e fim iguais (um quadrado)
              widget.state.areaStart = cell;
              widget.state.areaEnd = cell;
              widget.state.notifyListeners();
              return;
          }
        },

        // DRAG
        onPanStart: (d) {
          _dragging = true;
          final cell = widget.state.pointToCell(d.localPosition);
          if (cell == null) return;

          if (widget.state.tool == EditorTool.selectArea) {
            widget.state.areaStart = cell;
            widget.state.areaEnd = cell;
            widget.state.notifyListeners();
          }
        },
        onPanEnd: (_) => _dragging = false,
        onPanUpdate: (d) {
          if (!_dragging) return;
          final cell = widget.state.pointToCell(d.localPosition);
          if (cell == null) return;

          switch (widget.state.tool) {
            case EditorTool.addBlockBrush:
              widget.state.paintCellAsBlock(cell);
              return;
            case EditorTool.addRoadBrush:
              widget.state.paintCellAsRoad(cell);
              return;
            case EditorTool.erase:
              widget.state.eraseCell(cell);
              return;
            case EditorTool.selectArea:
              widget.state.areaEnd = cell;
              widget.state.notifyListeners();
              return;
            case EditorTool.select:
              return;
          }
        },

        child: Container(
          width: worldSize.width,
          height: worldSize.height,
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent, // <- interior “inteiro”
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
          child: ClipRect(
            child: CustomPaint(
              size: worldSize,
              painter: MapPainter(widget.state),
            ),
          ),
        ),
      ),
    );
  }
}
