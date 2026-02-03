import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/editor_controller.dart';
import 'editor_canvas.dart';
import 'property_panel.dart';
import 'floor_tabs.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 700;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<EditorController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor de Mapa"),
        actions: [
          IconButton(
            tooltip: "Selecionar",
            onPressed: () => c.setMode(ToolMode.select),
            icon: Icon(
              Icons.near_me,
              color: c.mode == ToolMode.select ? Colors.white : Colors.white70,
            ),
          ),
          IconButton(
            tooltip: "Adicionar bloco",
            onPressed: () => c.setMode(ToolMode.addBlock),
            icon: Icon(
              Icons.crop_square,
              color: c.mode == ToolMode.addBlock
                  ? Colors.white
                  : Colors.white70,
            ),
          ),
          IconButton(
            tooltip: "Desenhar rua",
            onPressed: () => c.setMode(ToolMode.drawRoad),
            icon: Icon(
              Icons.alt_route,
              color: c.mode == ToolMode.drawRoad
                  ? Colors.white
                  : Colors.white70,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const FloorTabs(),
          Expanded(
            child: isMobile(context)
                ? Stack(
                    children: [
                      const EditorCanvas(),

                      // botão flutuante para propriedades
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          child: const Icon(Icons.tune),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => const SizedBox(
                                height: 420,
                                child: PropertyPanel(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(child: EditorCanvas()),
                      SizedBox(
                        width: 320,
                        child: Container(
                          color: const Color(0xFFFAFBFC),
                          child: const PropertyPanel(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
