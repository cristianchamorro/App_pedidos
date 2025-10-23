import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detalle_pedido_page.dart';
import 'pago_page.dart'; // ⬅️ Importamos la pantalla de pago
import 'cajero_dashboard_page.dart'; // ⬅️ Importamos el dashboard de cajero
import '../theme/app_theme.dart';

class PedidosCajeroPage extends StatefulWidget {
  const PedidosCajeroPage({Key? key}) : super(key: key);

  @override
  _PedidosCajeroPageState createState() => _PedidosCajeroPageState();
}

class _PedidosCajeroPageState extends State<PedidosCajeroPage> {
  final ApiService api = ApiService();
  late Future<List<Map<String, dynamic>>> _pedidosPendientes;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _pedidosPendientes = api.fetchPedidosPendientes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get userId from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('userId')) {
      _userId = args['userId'] as int?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pedidos Pendientes por pagar",
          style: AppTheme.appBarTitleStyle,
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent, // necesario para ver el gradient
        flexibleSpace: Container(
          decoration: AppTheme.appBarDecoration,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botón para acceder al módulo de caja completo
          IconButton(
            icon: const Icon(Icons.dashboard, size: 28),
            tooltip: "Módulo de Caja",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CajeroDashboardPage(userId: _userId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pedidosPendientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No hay pedidos pendientes",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Los pedidos pendientes de pago aparecerán aquí",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final pedidos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _pedidosPendientes = api.fetchPedidosPendientes();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final total = double.tryParse(pedido['total'].toString()) ?? 0.0;
                
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
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
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with order ID and total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: Colors.deepPurple,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pedido #${pedido['order_id']}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.pending, size: 12, color: Colors.orange),
                                            SizedBox(width: 4),
                                            Text(
                                              "Pendiente",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "\$${total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const Divider(height: 20),
                          
                          // Customer information
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pedido['cliente_nombre'] ?? 'Sin nombre',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                pedido['cliente_telefono'] ?? 'Sin teléfono',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pedido['direccion_entrega'] ?? 'Sin dirección',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    // Abrir detalle del pedido
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetallePedidoPage(
                                          pedidoId: pedido['order_id'],
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      setState(() {
                                        _pedidosPendientes = api.fetchPedidosPendientes();
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text("Ver Detalle"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.deepPurple,
                                    side: const BorderSide(color: Colors.deepPurple),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Abrir pantalla de pago
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PagoPage(
                                          pedidoId: pedido['order_id'],
                                          total: total,
                                          userId: _userId,
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
                                  icon: const Icon(Icons.payment, size: 18),
                                  label: const Text("Realizar Pago"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
