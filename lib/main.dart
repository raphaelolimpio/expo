import 'package:expo/features/business_catalog/presentation/store_botton_sheet.dart';
import 'package:expo/features/map_engine/presentation/interactive_map.dart';
import 'package:expo/geo_block.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const ExpoSuperApp());
}

class ExpoSuperApp extends StatelessWidget {
  const ExpoSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<GeoBlock> _mapData = [
    GeoBlock(id: "loja-a-101", coordinates: [], status: "ocupado"),
    GeoBlock(id: "stand-b-202", coordinates: [], status: "livre"),
  ];

  void _onMapBlockClicked(String blockId) {
    print("Orquestrador: O mapa reportou clique no bloco $blockId");
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StoreBottomSheet(storeId: blockId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveMap(
        blocks: _mapData,
        onBlockTap: _onMapBlockClicked, 
      ),
    );
  }
}