import 'package:flutter/material.dart';

class StoreBottomSheet extends StatelessWidget {
  final String storeId;

  const StoreBottomSheet({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final isLojaRoupa = storeId.contains("loja-1");
    
    final storeName = isLojaRoupa ? "Zara Fashion" : "Tech Stand";
    final category = isLojaRoupa ? "Moda & Vestuário" : "Tecnologia";
    final description = isLojaRoupa 
        ? "A melhor moda outono/inverno você encontra aqui. Descontos de até 50%."
        : "Venha conhecer o novo Drone X1000. Demonstrações ao vivo.";
    final imageUrl = isLojaRoupa 
        ? "https://images.unsplash.com/photo-1441986300917-64674bd600d8" 
        : "https://images.unsplash.com/photo-1518770660439-4636190af475";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(storeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(category, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Text("Sobre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.black87, height: 1.4)),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                print("Navegando para página completa da loja $storeId");
                Navigator.pop(context); 
              },
              child: const Text("Ver Página Completa", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}