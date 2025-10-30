import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mesa.dart';
import '../theme/app_theme.dart';
import 'pos_terminal_page.dart';

class GestionMesasPage extends StatefulWidget {
  final int? userId;

  const GestionMesasPage({Key? key, this.userId}) : super(key: key);

  @override
  _GestionMesasPageState createState() => _GestionMesasPageState();
}

class _GestionMesasPageState extends State<GestionMesasPage> {
  List<Mesa> _mesas = [];
  String _filtroEstado = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarMesas();
  }

  void _cargarMesas() {
    // Simulación de mesas - En producción esto vendría de la API
    setState(() {
      _mesas = List.generate(
        20,
        (index) {
          final numero = index + 1;
          // Simulamos diferentes estados
          String estado = 'libre';
          double? total;
          int? orderId;
          
          if (numero % 4 == 0) {
            estado = 'ocupada';
            total = (15000 + (numero * 1000)).toDouble();
            orderId = 100 + numero;
          } else if (numero % 7 == 0) {
            estado = 'porpagar';
            total = (25000 + (numero * 500)).toDouble();
            orderId = 200 + numero;
          } else if (numero % 11 == 0) {
            estado = 'reservada';
          }
          
          return Mesa(
            id: numero,
            nombre: 'Mesa $numero',
            capacidad: (numero % 4) + 2, // Capacidad entre 2 y 5
            estado: estado,
            total: total,
            orderId: orderId,
          );
        },
      );
    });
  }

  List<Mesa> _mesasFiltradas() {
    if (_filtroEstado == 'Todas') {
      return _mesas;
    }
    return _mesas.where((m) => m.estado == _filtroEstado.toLowerCase()).toList();
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'libre':
        return Colors.green;
      case 'ocupada':
        return Colors.orange;
      case 'reservada':
        return Colors.blue;
      case 'porpagar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconEstado(String estado) {
    switch (estado) {
      case 'libre':
        return Icons.check_circle;
      case 'ocupada':
        return Icons.people;
      case 'reservada':
        return Icons.event;
      case 'porpagar':
        return Icons.payment;
      default:
        return Icons.table_restaurant;
    }
  }

  void _mostrarDetallesMesa(Mesa mesa) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _getIconEstado(mesa.estado),
                    color: _getColorEstado(mesa.estado),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mesa.nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Capacidad: ${mesa.capacidad} personas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 32),
              
              // Estado
              _buildInfoRow('Estado', mesa.estado.toUpperCase(), _getColorEstado(mesa.estado)),
              
              if (mesa.orderId != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Orden #', mesa.orderId.toString(), Colors.black87),
              ],
              
              if (mesa.total != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Total',
                  '\$${NumberFormat('#,###').format(mesa.total)}',
                  Colors.green,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Acciones
              Row(
                children: [
                  if (mesa.estado == 'libre') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _abrirMesa(mesa);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Abrir Mesa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  
                  if (mesa.estado == 'ocupada') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _verOrden(mesa);
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('Ver Orden'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _solicitarCuenta(mesa);
                        },
                        icon: const Icon(Icons.receipt),
                        label: const Text('Cuenta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  
                  if (mesa.estado == 'porpagar') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _cobrarMesa(mesa);
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Cobrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  
                  if (mesa.estado == 'reservada') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelarReserva(mesa);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _abrirMesa(Mesa mesa) {
    // Aquí se abriría el POS para crear una orden para esta mesa
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => POSTerminalPage(userId: widget.userId),
      ),
    );
  }

  void _verOrden(Mesa mesa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver orden #${mesa.orderId} de ${mesa.nombre}')),
    );
  }

  void _solicitarCuenta(Mesa mesa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Cuenta'),
        content: Text('¿Solicitar cuenta para ${mesa.nombre}?\n\nTotal: \$${NumberFormat('#,###').format(mesa.total)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                mesa.estado = 'porpagar';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${mesa.nombre} lista para cobrar'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _cobrarMesa(Mesa mesa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Procesar Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesa: ${mesa.nombre}'),
            Text('Orden: #${mesa.orderId}'),
            const SizedBox(height: 8),
            Text(
              'Total: \$${NumberFormat('#,###').format(mesa.total)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                mesa.estado = 'libre';
                mesa.orderId = null;
                mesa.total = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Pago procesado - ${mesa.nombre} disponible'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Cobrar'),
          ),
        ],
      ),
    );
  }

  void _cancelarReserva(Mesa mesa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text('¿Cancelar reserva de ${mesa.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                mesa.estado = 'libre';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reserva cancelada - ${mesa.nombre} disponible'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Reserva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mesasFiltradas = _mesasFiltradas();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestión de Mesas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarMesas,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros de estado
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filtrar por estado:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Todas',
                    'libre',
                    'ocupada',
                    'reservada',
                    'porpagar',
                  ].map((estado) {
                    final isSelected = estado == _filtroEstado ||
                        (estado == 'Todas' && _filtroEstado == 'Todas');
                    return FilterChip(
                      label: Text(estado.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _filtroEstado = estado;
                        });
                      },
                      selectedColor: estado == 'Todas'
                          ? AppTheme.primary
                          : _getColorEstado(estado),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Estadísticas rápidas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildEstadoChip(
                  'Libres',
                  _mesas.where((m) => m.estado == 'libre').length,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildEstadoChip(
                  'Ocupadas',
                  _mesas.where((m) => m.estado == 'ocupada').length,
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildEstadoChip(
                  'Por Pagar',
                  _mesas.where((m) => m.estado == 'porpagar').length,
                  Colors.red,
                ),
              ],
            ),
          ),
          
          // Grid de mesas
          Expanded(
            child: mesasFiltradas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.table_restaurant, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No hay mesas con este estado"),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: mesasFiltradas.length,
                    itemBuilder: (context, index) {
                      final mesa = mesasFiltradas[index];
                      return _buildMesaCard(mesa);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
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
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMesaCard(Mesa mesa) {
    final color = _getColorEstado(mesa.estado);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: InkWell(
        onTap: () => _mostrarDetallesMesa(mesa),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconEstado(mesa.estado),
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                mesa.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mesa.estado.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mesa.total != null) ...[
                const SizedBox(height: 4),
                Text(
                  '\$${NumberFormat('#,###').format(mesa.total)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
