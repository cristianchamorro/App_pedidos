import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detalle_pedido_page.dart'; // ⬅️ Importamos la nueva pantalla

class PedidosCajeroPage extends StatefulWidget {
  const PedidosCajeroPage({Key? key}) : super(key: key);

  @override
  _PedidosCajeroPageState createState() => _PedidosCajeroPageState();
}

class _PedidosCajeroPageState extends State<PedidosCajeroPage> {
  final ApiService api = ApiService();
  late Future<List<Map<String, dynamic>>> _pedidosPendientes;

  @override
  void initState() {
    super.initState();
    _pedidosPendientes = api.fetchPedidosPendientes();
  }

  Future<void> _procesarPedido(int orderId) async {
    try {
      final success = await api.procesarPedido(orderId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido procesado correctamente")),
        );
        setState(() {
          _pedidosPendientes = api.fetchPedidosPendientes();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar pedido: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos Pendientes - Cajero"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pedidosPendientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay pedidos pendientes"));
          }

          final pedidos = snapshot.data!;
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${pedido['cliente_nombre']} - \$${pedido['total']}"),
                  subtitle: Text(
                    "Tel: ${pedido['cliente_telefono']}\nDirección: ${pedido['direccion_entrega']}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _procesarPedido(pedido['order_id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Procesar"),
                  ),
                  onTap: () {
                    // ⬅️ Nuevo: al tocar el pedido abrimos detalle
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallePedidoPage(
                          pedidoId: pedido['order_id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
