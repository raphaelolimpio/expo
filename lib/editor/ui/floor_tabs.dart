import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/editor_controller.dart';

class FloorTabs extends StatelessWidget {
  const FloorTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<EditorController>();

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: c.floors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = c.floors[i];
                final active = i == c.activeFloorIndex;
                return ChoiceChip(
                  label: Text(f.name),
                  selected: active,
                  onSelected: (_) => c.setActiveFloor(i),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: c.addFloor,
            icon: const Icon(Icons.add),
            label: const Text("Novo piso"),
          ),
        ],
      ),
    );
  }
}
