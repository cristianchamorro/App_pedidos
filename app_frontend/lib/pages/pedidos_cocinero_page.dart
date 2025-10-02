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
        pedidos = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando pedidos: $e")),
      );
    }
  }

  Future<void> _marcarComoListo(int id) async {
    try {
      bool success = await api.marcarListoCocina(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido marcado como listo")),
        );
        _cargarPedidos(); // refrescar lista
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al marcar pedido: $e")),
      );
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
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("Pedido #${pedido["id"]}"),
              subtitle: Text("Mesa: ${pedido["mesa"] ?? '-'}"),
              trailing: ElevatedButton(
                onPressed: () => _marcarComoListo(pedido["id"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text("Marcar listo"),
              ),
            ),
          );
        },
      ),
    );
  }
}
