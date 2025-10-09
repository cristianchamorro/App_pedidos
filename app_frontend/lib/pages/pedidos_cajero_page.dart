import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detalle_pedido_page.dart';
import 'pago_page.dart'; // ⬅️ Importamos la pantalla de pago

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pedidos Pendientes por pagar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent, // necesario para ver el gradient
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
                    onPressed: () async {
                      // Abrir pantalla de pago
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PagoPage(
                            pedidoId: pedido['order_id'],
                            total: double.tryParse(pedido['total'].toString()) ?? 0.0,
                          ),
                        ),
                      );

                      // Si el pago fue confirmado, refrescar lista
                      if (result == true) {
                        setState(() {
                          _pedidosPendientes = api.fetchPedidosPendientes();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Realizar Pago"),
                  ),
                  onTap: () async {
                    // Abrir detalle del pedido y esperar si se realiza pago
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallePedidoPage(
                          pedidoId: pedido['order_id'],
                        ),
                      ),
                    );

                    // 🔹 Si desde detalle se realizó el pago, refrescar la lista automáticamente
                    if (result == true) {
                      setState(() {
                        _pedidosPendientes = api.fetchPedidosPendientes();
                      });
                    }
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
