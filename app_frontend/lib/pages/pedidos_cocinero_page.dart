import 'package:flutter/material.dart';

class PedidosCocineroPage extends StatefulWidget {
  const PedidosCocineroPage({super.key});

  @override
  State<PedidosCocineroPage> createState() => _PedidosCocineroPageState();
}

class _PedidosCocineroPageState extends State<PedidosCocineroPage> {
  // Ejemplo: lista de pedidos
  List<Map<String, dynamic>> pedidos = [
    {"id": 1, "mesa": "Mesa 1", "estado": "Pendiente"},
    {"id": 2, "mesa": "Mesa 3", "estado": "En preparación"},
    {"id": 3, "mesa": "Mesa 5", "estado": "Listo para entregar"},
  ];

  void marcarComoListo(int id) {
    setState(() {
      final index = pedidos.indexWhere((p) => p["id"] == id);
      if (index != -1) {
        pedidos[index]["estado"] = "Listo para entregar";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos - Cocinero"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("Pedido #${pedido["id"]} - ${pedido["mesa"]}"),
              subtitle: Text("Estado: ${pedido["estado"]}"),
              trailing: pedido["estado"] == "Pendiente"
                  ? ElevatedButton(
                      onPressed: () => marcarComoListo(pedido["id"]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text("Marcar listo"),
                    )
                  : const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
