import 'package:flutter/material.dart';
import '../api_service.dart';

class DetallePedidoPage extends StatefulWidget {
  final int pedidoId;

  const DetallePedidoPage({Key? key, required this.pedidoId}) : super(key: key);

  @override
  _DetallePedidoPageState createState() => _DetallePedidoPageState();
}

class _DetallePedidoPageState extends State<DetallePedidoPage> {
  final ApiService api = ApiService();
  late Future<Map<String, dynamic>> _detallePedido;

  @override
  void initState() {
    super.initState();
    _detallePedido = api.fetchDetallePedido(widget.pedidoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Pedido"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detallePedido,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No se encontró el pedido"));
          }

          final pedido = snapshot.data!;
          final productos = List<Map<String, dynamic>>.from(pedido['productos'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧑 Cliente
                Text(
                  "Cliente: ${pedido['cliente_nombre'] ?? 'Sin nombre'}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Teléfono: ${pedido['cliente_telefono'] ?? 'Sin teléfono'}"),
                Text("Dirección: ${pedido['direccion_entrega'] ?? 'Sin dirección'}"),
                const SizedBox(height: 8),

                // 💲 Total
                Text(
                  "Total: \$${pedido['total'] ?? 0}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // 📦 Estado
                Text(
                  "Estado: ${pedido['status'] ?? 'Desconocido'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 20, thickness: 2),

                // 🛒 Lista de productos
                const Text(
                  "Productos:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...productos.map((prod) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(prod['name'] ?? 'Sin nombre'),
                      subtitle: Text("Cantidad: ${prod['cantidad'] ?? 0}"),
                      trailing: Text("\$${prod['price'] ?? 0}"),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
