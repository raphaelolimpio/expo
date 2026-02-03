import 'package:flutter/material.dart';
import 'editor_state.dart';
import 'map_canvas.dart';
import 'property_sheet.dart';
import 'package:file_picker/file_picker.dart';

class MapEditorScreen extends StatefulWidget {
  const MapEditorScreen({super.key});

  @override
  State<MapEditorScreen> createState() => _MapEditorScreenState();
}

class _MapEditorScreenState extends State<MapEditorScreen> {
  final state = EditorState();

  Future<void> _pickBackgroundImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // ✅ importante no web
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    await state.setBackgroundFromBytes(bytes);
  }

  void _openProperties() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AnimatedBuilder(
        animation: state,
        builder: (_, __) => PropertySheet(state: state),
      ),
    );
  }

  void _openCreateFromSelectionDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          if (!state.hasAreaSelection) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Selecione uma área primeiro (modo Selecionar área).",
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Criar a partir da seleção",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          state.createBlockFromSelection(
                            name: "Novo bloco",
                            code: "",
                            type: "stand",
                          );
                          Navigator.pop(context);
                          _openProperties();
                        },
                        icon: const Icon(Icons.crop_square),
                        label: const Text("Criar bloco"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          state.createRoadFromSelection(name: "Rua");
                          Navigator.pop(context);
                          _openProperties();
                        },
                        icon: const Icon(Icons.alt_route),
                        label: const Text("Criar rua"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text("Células selecionadas: ${state.selectedAreaCells.length}"),
                const SizedBox(height: 6),
                const Text(
                  "Dica: depois você edita nome/cor/status nas Propriedades.",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Editor de Mapa"),
            actions: [
              IconButton(
                onPressed: _pickBackgroundImage,
                icon: const Icon(Icons.image),
                tooltip: "Importar imagem do mapa",
              ),
              IconButton(
                onPressed: () => state.setTool(EditorTool.select),
                icon: const Icon(Icons.touch_app),
                tooltip: "Selecionar entidade",
              ),
              IconButton(
                onPressed: () => state.setTool(EditorTool.selectArea),
                icon: const Icon(Icons.select_all),
                tooltip: "Selecionar área",
              ),
              IconButton(
                onPressed: () => state.setTool(EditorTool.addBlockBrush),
                icon: const Icon(Icons.crop_square),
                tooltip: "Pincel bloco",
              ),
              IconButton(
                onPressed: () => state.setTool(EditorTool.addRoadBrush),
                icon: const Icon(Icons.alt_route),
                tooltip: "Pincel rua",
              ),
              IconButton(
                tooltip: "Criar local da seleção",
                icon: const Icon(Icons.add_business),
                onPressed: () {
                  state.createBlockFromSelectedArea();
                },
              ),

              IconButton(
                onPressed: () => state.setTool(EditorTool.erase),
                icon: const Icon(Icons.auto_fix_high),
                tooltip: "Borracha",
              ),
            ],
          ),
          body: Column(
            children: [
              // Pisos
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(state.floors.length, (i) {
                            final selected = i == state.floorIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(state.floors[i].name),
                                selected: selected,
                                onSelected: (_) => state.selectFloor(i),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: state.addFloor,
                      icon: const Icon(Icons.add),
                      label: const Text("Novo piso"),
                    ),
                  ],
                ),
              ),

              // Barra rápida da seleção
              if (state.tool == EditorTool.selectArea)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Modo: ${state.toolLabel()} • Seleção: ${state.selectedAreaCells.length} células",
                        ),
                      ),
                      FilledButton(
                        onPressed: state.hasAreaSelection
                            ? _openCreateFromSelectionDialog
                            : null,
                        child: const Text("Criar da seleção"),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: MapCanvas(
                  state: state,
                  onOpenProperties: _openProperties,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openProperties,
            label: const Text("Propriedades"),
            icon: const Icon(Icons.tune),
          ),
        );
      },
    );
  }
}
