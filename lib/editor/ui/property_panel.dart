import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/editor_controller.dart';

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<EditorController>();
    final b = c.selectedBlock;

    if (b == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Selecione um bloco para editar.\n\nDica: toque em 'Adicionar bloco' e clique no canvas."),
        ),
      );
    }

    _nameCtrl.text = b.name;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text("Propriedades do Bloco", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: "Nome"),
            onChanged: (v) => c.updateSelectedBlock(name: v),
          ),

          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: b.status,
            items: const [
              DropdownMenuItem(value: "livre", child: Text("Livre")),
              DropdownMenuItem(value: "ocupado", child: Text("Ocupado")),
              DropdownMenuItem(value: "reservado", child: Text("Reservado")),
            ],
            onChanged: (v) => c.updateSelectedBlock(status: v),
            decoration: const InputDecoration(labelText: "Status"),
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _colorDot(context, const Color(0xFF4CAF50)),
              _colorDot(context, const Color(0xFF2196F3)),
              _colorDot(context, const Color(0xFFFFC107)),
              _colorDot(context, const Color(0xFFF44336)),
              _colorDot(context, const Color(0xFF9C27B0)),
              _colorDot(context, const Color(0xFF607D8B)),
            ],
          ),

          const SizedBox(height: 24),
          const Text("Tamanho (simples)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: b.rect.width.toStringAsFixed(0),
                  decoration: const InputDecoration(labelText: "Largura"),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) {
                    final w = double.tryParse(v);
                    if (w != null) c.resizeSelectedBlock(w, b.rect.height);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: b.rect.height.toStringAsFixed(0),
                  decoration: const InputDecoration(labelText: "Altura"),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) {
                    final h = double.tryParse(v);
                    if (h != null) c.resizeSelectedBlock(b.rect.width, h);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorDot(BuildContext context, Color color) {
    final c = context.read<EditorController>();
    return InkWell(
      onTap: () => c.updateSelectedBlock(color: color),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
