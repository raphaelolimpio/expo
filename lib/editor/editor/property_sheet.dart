import 'package:flutter/material.dart';
import 'editor_state.dart';
import 'editor_models.dart';

class PropertySheet extends StatefulWidget {
  final EditorState state;

  const PropertySheet({super.key, required this.state});

  @override
  State<PropertySheet> createState() => _PropertySheetState();
}

class _PropertySheetState extends State<PropertySheet> {
  final _name = TextEditingController();
  final _code = TextEditingController();

  // ✅ Tipo como dropdown (não TextField)
  static const _types = <String>[
    "Sala",
    "Auditório",
    "Laboratório",
    "Stand",
    "Banheiro",
    "Outro",
  ];
  String _selectedType = "Sala";

  @override
  void initState() {
    super.initState();
    _syncFromSelection();
  }

  @override
  void didUpdateWidget(covariant PropertySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFromSelection();
  }

  void _syncFromSelection() {
    final b = widget.state.selectedBlock;
    final r = widget.state.selectedRoad;

    if (b != null) {
      _name.text = b.name;
      _code.text = b.code;
      _selectedType = b.type.isNotEmpty ? b.type : "Sala";
      if (!_types.contains(_selectedType)) _selectedType = "Outro";
    } else if (r != null) {
      _name.text = r.name;
      _code.text = "";
      _selectedType = "Sala";
    } else {
      _name.text = "";
      _code.text = "";
      _selectedType = "Sala";
    }

    // força atualizar dropdown quando troca seleção
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.state.selectedBlock;
    final r = widget.state.selectedRoad;

    if (b == null && r == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Selecione um local (bloco) ou rua para editar."),
      );
    }

    final isBlock = b != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBlock ? "Local" : "Rua",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: "Nome"),
            onChanged: (v) {
              if (isBlock) widget.state.updateSelectedBlock(name: v);
              else widget.state.updateSelectedRoad(name: v);
            },
          ),

          if (isBlock) ...[
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: "Tipo"),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedType = v);
                widget.state.updateSelectedBlock(type: v);
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: "Código (ex: A01)"),
              onChanged: (v) => widget.state.updateSelectedBlock(code: v),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Text("Status: "),
                const SizedBox(width: 8),
                DropdownButton<BlockStatus>(
                  value: b!.status,
                  items: const [
                    DropdownMenuItem(
                      value: BlockStatus.livre,
                      child: Text("livre"),
                    ),
                    DropdownMenuItem(
                      value: BlockStatus.reservado,
                      child: Text("reservado"),
                    ),
                    DropdownMenuItem(
                      value: BlockStatus.ocupado,
                      child: Text("ocupado"),
                    ),
                  ],
                  onChanged: (s) {
                    if (s != null) widget.state.updateSelectedBlock(status: s);
                  },
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              const Text("Cor: "),
              const SizedBox(width: 10),
              _ColorDot(
                color: const Color(0xFF7DD3FC),
                onTap: () => isBlock
                    ? widget.state.updateSelectedBlock(
                        color: const Color(0xFF7DD3FC),
                      )
                    : widget.state.updateSelectedRoad(
                        color: const Color(0xFF7DD3FC),
                      ),
              ),
              _ColorDot(
                color: const Color(0xFF86EFAC),
                onTap: () => isBlock
                    ? widget.state.updateSelectedBlock(
                        color: const Color(0xFF86EFAC),
                      )
                    : widget.state.updateSelectedRoad(
                        color: const Color(0xFF86EFAC),
                      ),
              ),
              _ColorDot(
                color: const Color(0xFFFDE68A),
                onTap: () => isBlock
                    ? widget.state.updateSelectedBlock(
                        color: const Color(0xFFFDE68A),
                      )
                    : widget.state.updateSelectedRoad(
                        color: const Color(0xFFFDE68A),
                      ),
              ),
              _ColorDot(
                color: const Color(0xFFE5E7EB),
                onTap: () => isBlock
                    ? widget.state.updateSelectedBlock(
                        color: const Color(0xFFE5E7EB),
                      )
                    : widget.state.updateSelectedRoad(
                        color: const Color(0xFFE5E7EB),
                      ),
              ),
              _ColorDot(
                color: const Color(0xFFFCA5A5),
                onTap: () => isBlock
                    ? widget.state.updateSelectedBlock(
                        color: const Color(0xFFFCA5A5),
                      )
                    : widget.state.updateSelectedRoad(
                        color: const Color(0xFFFCA5A5),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text("Ferramenta atual: ${widget.state.toolLabel()}"),
          const SizedBox(height: 6),
          const Text(
            "Dica: use 'Selecionar área' e depois 'Criar da seleção' para criar um local/rua único.",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
      ),
    );
  }
}
