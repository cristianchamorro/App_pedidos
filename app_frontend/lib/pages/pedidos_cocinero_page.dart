import 'package:flutter/material.dart';
import '../api_service.dart';

class PedidosCocineroPage extends StatefulWidget {
  const PedidosCocineroPage({super.key});

  @override
  State<PedidosCocineroPage> createState() => _PedidosCocineroPageState();
}

class _PedidosCocineroPageState extends State<PedidosCocineroPage> {
  final ApiService api = ApiService();
  List<Map<String, dynamic>> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => isLoading = true);
    try {
      final data = await api.obtenerPedidosPorEstado("pagado");
      setState(() {
        pedidos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error cargando pedidos: $e")),
        );
      }
    }
  }

  Future<void> _marcarComoListo(int orderId) async {
    try {
      bool success = await api.marcarListoCocina(orderId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pedido marcado como listo")),
          );
        }
        _cargarPedidos(); // refrescar lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al marcar pedido: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos - Cocinero"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPedidos,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
          ? const Center(child: Text("No hay pedidos en preparación"))
          : ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];

          final productos = (pedido["productos"] as List?) ?? [];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del pedido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pedido #${pedido["order_id"]}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _marcarComoListo(pedido["order_id"]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text("Marcar listo"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Cliente: ${pedido["cliente_nombre"] ?? '-'}"),
                  Text("Teléfono: ${pedido["cliente_telefono"] ?? '-'}"),
                  Text("Dirección: ${pedido["direccion_entrega"] ?? '-'}"),
                  Text("Total: \$${pedido["total"]}"),
                  const SizedBox(height: 8),

                  // Lista de productos
                  if (productos.isNotEmpty) ...[
                    const Text("Productos:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...productos.map((prod) {
                      return Text(
                          "- ${prod["cantidad"]} x ${prod["nombre"]} (\$${prod["price"]})");
                    }).toList(),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
