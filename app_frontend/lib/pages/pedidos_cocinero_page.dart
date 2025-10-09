import 'dart:async'; // 👈 Importante
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
  Timer? _timer; // 👈 Timer para refrescar automáticamente

  @override
  void initState() {
    super.initState();
    _cargarPedidos();

    // Refrescar pedidos cada 5 segundos automáticamente
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _cargarPedidos();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 👈 Cancelar el timer al salir de la pantalla
    super.dispose();
  }

  Future<void> _cargarPedidos() async {
    try {
      final data = await api.obtenerPedidosPorEstado("pagado");
      if (mounted) {
        setState(() {
          pedidos = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _marcarComoListo(int orderId) async {
    try {
      bool success = await api.marcarListoCocina(orderId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido marcado como listo")),
        );
        _cargarPedidos(); // refrescar lista inmediatamente
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
        title: const Text(
          "Pedidos para preparar en cocina",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent, // permite mostrar el gradient
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _marcarComoListo(pedido["order_id"]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text("Marcar como Preparado"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Cliente: ${pedido["cliente_nombre"] ?? '-'}"),
                  Text("Teléfono: ${pedido["cliente_telefono"] ?? '-'}"),
                  Text("Dirección: ${pedido["direccion_entrega"] ?? '-'}"),
                  const SizedBox(height: 10),

                  // Lista de productos en grande
                  if (productos.isNotEmpty) ...[
                    const Text(
                      "Productos a preparar:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...productos.map((prod) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${prod["cantidad"]}x ",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${prod["nombre"]}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
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
