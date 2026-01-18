import 'package:latlong2/latlong.dart';

class GeoBlock {
  final String id;
  final List<LatLng> coordinates;
  final String status;

  GeoBlock({
    required this.id,
    required this.coordinates,
    required this.status,
  });

  bool containsPoint(LatLng point) {
    return false; 
  }
}