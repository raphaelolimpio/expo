import 'package:expo/geo_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;


class InteractiveMap extends StatefulWidget {
  final List<GeoBlock> blocks;
  final Function(String blockId) onBlockTap;

  const InteractiveMap({
    super.key,
    required this.blocks,
    required this.onBlockTap,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final MapController _mapController = MapController();
  void _handleTap(TapPosition tapPosition, LatLng point) {
    for (var block in widget.blocks) {
      if (_isPointInsideBlock(point, block)) {
        widget.onBlockTap(block.id); 
        return;
      }
    }
  }

  bool _isPointInsideBlock(LatLng point, GeoBlock block) {
    if (block.coordinates.isEmpty) return false;
    double minLat = block.coordinates.first.latitude;
    double maxLat = block.coordinates.first.latitude;
    double minLng = block.coordinates.first.longitude;
    double maxLng = block.coordinates.first.longitude;

    for (var coord in block.coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    const margin = 0.00005; 
    return point.latitude >= (minLat - margin) &&
           point.latitude <= (maxLat + margin) &&
           point.longitude >= (minLng - margin) &&
           point.longitude <= (maxLng + margin);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-23.5505, -46.6333),
        initialZoom: 17.5,
        onTap: _handleTap, 
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.expo.app',
        ),
        _BlockLayer(blocks: widget.blocks),
      ],
    );
  }
}

class _BlockLayer extends StatelessWidget {
  final List<GeoBlock> blocks;

  const _BlockLayer({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return CustomPaint(
      painter: _BlockPainter(blocks: blocks, camera: camera),
    );
  }
}

class _BlockPainter extends CustomPainter {
  final List<GeoBlock> blocks;
  final MapCamera camera;

  _BlockPainter({required this.blocks, required this.camera});

  @override
  void paint(Canvas canvas, Size size) {
    final paintOccupied = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    final paintFree = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var block in blocks) {
      if (block.coordinates.isEmpty) continue;

      final path = ui.Path();
      
      final startPoint = camera.latLngToScreenPoint(block.coordinates[0]);
      
      path.moveTo(startPoint.x, startPoint.y);

      for (int i = 1; i < block.coordinates.length; i++) {
        final point = camera.latLngToScreenPoint(block.coordinates[i]);
        path.lineTo(point.x, point.y);
      }
      path.close();

      final isOccupied = block.status == 'ocupado';
      canvas.drawPath(path, isOccupied ? paintOccupied : paintFree);
      canvas.drawPath(path, paintBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _BlockPainter oldDelegate) {
    return true; 
  }
}