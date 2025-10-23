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
  int? _userId;
  String _sortBy = 'reciente'; // reciente, antiguo
  String _filterBy = 'todos'; // todos, urgente, normal

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get userId from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('userId')) {
      _userId = args['userId'] as int?;
    }
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
          pedidos = _aplicarFiltrosYOrden(data);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _aplicarFiltrosYOrden(List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> resultado = List.from(data);

    // Aplicar filtro
    if (_filterBy == 'urgente') {
      // Pedidos con más de 15 minutos se consideran urgentes
      final ahora = DateTime.now();
      resultado = resultado.where((pedido) {
        try {
          final fechaCreacion = DateTime.parse(pedido['created_at'] ?? '');
          final diferencia = ahora.difference(fechaCreacion).inMinutes;
          return diferencia >= 15;
        } catch (e) {
          return false;
        }
      }).toList();
    } else if (_filterBy == 'normal') {
      // Pedidos con menos de 15 minutos
      final ahora = DateTime.now();
      resultado = resultado.where((pedido) {
        try {
          final fechaCreacion = DateTime.parse(pedido['created_at'] ?? '');
          final diferencia = ahora.difference(fechaCreacion).inMinutes;
          return diferencia < 15;
        } catch (e) {
          return true;
        }
      }).toList();
    }

    // Aplicar orden
    if (_sortBy == 'reciente') {
      resultado.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA); // Más reciente primero
      });
    } else if (_sortBy == 'antiguo') {
      resultado.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        return dateA.compareTo(dateB); // Más antiguo primero
      });
    }

    return resultado;
  }

  int _calcularTiempoEspera(String? createdAt) {
    if (createdAt == null) return 0;
    try {
      final fechaCreacion = DateTime.parse(createdAt);
      final ahora = DateTime.now();
      return ahora.difference(fechaCreacion).inMinutes;
    } catch (e) {
      return 0;
    }
  }

  Color _getColorPrioridad(int minutos) {
    if (minutos >= 30) return Colors.red;
    if (minutos >= 15) return Colors.orange;
    return Colors.green;
  }

  String _getPrioridadTexto(int minutos) {
    if (minutos >= 30) return 'MUY URGENTE';
    if (minutos >= 15) return 'URGENTE';
    return 'NORMAL';
  }

  Future<void> _marcarComoListo(int orderId) async {
    try {
      bool success = await api.marcarListoCocina(orderId, changedBy: _userId);
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
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text(
          "Cocina - Pedidos en preparación",
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
        actions: [
          // Filtro dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _filterBy = value;
                pedidos = _aplicarFiltrosYOrden(pedidos);
              });
              _cargarPedidos();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todos',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 8),
                    Text('Todos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'urgente',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Urgentes (>15 min)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'normal',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Normales (<15 min)'),
                  ],
                ),
              ),
            ],
          ),
          // Ordenar dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                pedidos = _aplicarFiltrosYOrden(pedidos);
              });
              _cargarPedidos();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reciente',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 8),
                    Text('Más reciente'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'antiguo',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: 8),
                    Text('Más antiguo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de estadísticas
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  icon: Icons.restaurant_menu,
                  label: 'Total',
                  value: pedidos.length.toString(),
                  color: Colors.deepPurple,
                ),
                _buildStatCard(
                  icon: Icons.warning,
                  label: 'Urgentes',
                  value: pedidos.where((p) {
                    final minutos = _calcularTiempoEspera(p['created_at']);
                    return minutos >= 15;
                  }).length.toString(),
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: Icons.schedule,
                  label: 'Normales',
                  value: pedidos.where((p) {
                    final minutos = _calcularTiempoEspera(p['created_at']);
                    return minutos < 15;
                  }).length.toString(),
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Lista de pedidos
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pedidos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "¡Todo listo! No hay pedidos en preparación",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];
                          final productos = (pedido["productos"] as List?) ?? [];
                          final tiempoEspera = _calcularTiempoEspera(pedido['created_at']);
                          final colorPrioridad = _getColorPrioridad(tiempoEspera);
                          final prioridadTexto = _getPrioridadTexto(tiempoEspera);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: colorPrioridad.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    colorPrioridad.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Encabezado del pedido con prioridad
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  Text(
                                                    "Pedido #${pedido["order_id"]}",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Badge de prioridad
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorPrioridad,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      tiempoEspera >= 15
                                                          ? Icons.warning
                                                          : Icons.schedule,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$prioridadTexto - $tiempoEspera min',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const Divider(height: 24, thickness: 1),

                                    // Información del cliente
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "${pedido["cliente_nombre"] ?? '-'}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${pedido["cliente_telefono"] ?? '-'}",
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "${pedido["direccion_entrega"] ?? '-'}",
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Lista de productos en grande
                                    if (productos.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.amber.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.restaurant,
                                                  color: Colors.orange,
                                                  size: 22,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Productos a preparar:",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            ...productos.map((prod) {
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.deepPurple,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        "${prod["cantidad"]}x",
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        "${prod["nombre"]}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.check_box_outline_blank,
                                                      color: Colors.grey,
                                                      size: 28,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 16),

                                    // Botón de marcar como listo
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _marcarComoListo(pedido["order_id"]),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        icon: const Icon(Icons.check_circle, size: 28),
                                        label: const Text(
                                          "Marcar como Preparado",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
