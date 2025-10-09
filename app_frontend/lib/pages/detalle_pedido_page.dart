import 'package:flutter/material.dart';
import '../api_service.dart';
import 'pago_page.dart';

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
        title: const Text(
          "Detalles del Pedido",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                Text(
                  "Cliente: ${pedido['cliente_nombre'] ?? 'Sin nombre'}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Teléfono: ${pedido['cliente_telefono'] ?? 'Sin teléfono'}"),
                Text("Dirección: ${pedido['direccion_entrega'] ?? 'Sin dirección'}"),
                const SizedBox(height: 8),
                Text(
                  "Total: \$${pedido['total'] ?? 0}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Estado: ${pedido['status'] ?? 'Desconocido'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 20, thickness: 2),
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
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pagoExitoso = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PagoPage(
                            pedidoId: widget.pedidoId,
                            total: double.tryParse(pedido['total'].toString()) ?? 0.0,
                          ),
                        ),
                      );

                      if (pagoExitoso == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pago realizado con éxito")),
                        );

                        // 🔹 Cerramos esta pantalla y devolvemos true a la lista
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      "Realizar Pago",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
