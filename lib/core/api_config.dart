import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Se estiver no Android Emulator, usa 10.0.2.2, senão usa localhost
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://localhost:8000";
  }
  
  // Substitua pelo ID real do mapa que você criou no backend (via Swagger ou Postman)
  static const String mapId = "582a3098-b310-45fa-a9c5-54275e547777"; 
}