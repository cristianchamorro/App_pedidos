import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';

class CajeroDashboardPage extends StatefulWidget {
  final int? userId;

  const CajeroDashboardPage({Key? key, this.userId}) : super(key: key);

  @override
  _CajeroDashboardPageState createState() => _CajeroDashboardPageState();
}

class _CajeroDashboardPageState extends State<CajeroDashboardPage> {
  final ApiService api = ApiService();
  Map<String, dynamic>? _estadisticas;
  Map<String, dynamic>? _ventasDelDia;
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final estadisticas = await api.obtenerEstadisticasCaja();
      final ventasDelDia = await api.obtenerVentasDelDia();
      
      setState(() {
        _estadisticas = estadisticas;
        _ventasDelDia = ventasDelDia;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar datos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Módulo de Caja",
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas Generales
                  _buildEstadisticasGenerales(),
                  
                  const SizedBox(height: 24),
                  
                  // Tabs para diferentes vistas
                  _buildTabs(),
                  
                  const SizedBox(height: 16),
                  
                  // Contenido según tab seleccionado
                  _buildTabContent(),
                ],
              ),
            ),
    );
  }

  Widget _buildEstadisticasGenerales() {
    if (_estadisticas == null) return const SizedBox();
    
    final stats = _estadisticas!['estadisticas'] as Map<String, dynamic>;
    final hoy = stats['hoy'] as Map<String, dynamic>;
    final semana = stats['semana'] as Map<String, dynamic>;
    final mes = stats['mes'] as Map<String, dynamic>;
    final pendientes = stats['pendientes'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Resumen General",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              "Hoy",
              "\$${_formatNumber(hoy['total_hoy'])}",
              "${hoy['pedidos_hoy']} pedidos",
              Colors.green,
              Icons.today,
            ),
            _buildStatCard(
              "Semana",
              "\$${_formatNumber(semana['total_semana'])}",
              "${semana['pedidos_semana']} pedidos",
              Colors.blue,
              Icons.calendar_view_week,
            ),
            _buildStatCard(
              "Mes",
              "\$${_formatNumber(mes['total_mes'])}",
              "${mes['pedidos_mes']} pedidos",
              Colors.purple,
              Icons.calendar_month,
            ),
            _buildStatCard(
              "Pendientes",
              "\$${_formatNumber(pendientes['total_pendiente'])}",
              "${pendientes['pedidos_pendientes']} pedidos",
              Colors.orange,
              Icons.pending,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: Colors.white70, size: 24),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton("Ventas del Día", 0, Icons.receipt),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabButton("Historial", 1, Icons.history),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabButton("Reportes", 2, Icons.assessment),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return ElevatedButton.icon(
      onPressed: () => setState(() => _selectedTabIndex = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildVentasDelDia();
      case 1:
        return _buildHistorial();
      case 2:
        return _buildReportes();
      default:
        return const SizedBox();
    }
  }

  Widget _buildVentasDelDia() {
    if (_ventasDelDia == null) return const SizedBox();
    
    final resumen = _ventasDelDia!['resumen'] as Map<String, dynamic>;
    final porEstado = _ventasDelDia!['por_estado'] as List<dynamic>;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ventas de Hoy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow("Total de Pedidos:", "${resumen['total_pedidos'] ?? 0}"),
            _buildInfoRow("Total Vendido:", "\$${_formatNumber(resumen['total_ventas'])}"),
            _buildInfoRow("Promedio por Venta:", "\$${_formatNumber(resumen['promedio_venta'])}"),
            
            const SizedBox(height: 16),
            const Text(
              "Por Estado:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ...porEstado.map((estado) {
              final e = estado as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _getEstadoIcon(e['status']),
                        const SizedBox(width: 8),
                        Text(
                          "${e['status']}:",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      "${e['cantidad']} (\$${_formatNumber(e['total'])})",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorial() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Historial de Pagos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _mostrarHistorialCompleto(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              icon: const Icon(Icons.list),
              label: const Text("Ver Historial Completo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportes() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Generar Reportes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text("Reporte Semanal"),
              subtitle: const Text("Últimos 7 días"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _generarReporteSemanal(),
            ),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.green),
              title: const Text("Reporte Mensual"),
              subtitle: const Text("Mes actual"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _generarReporteMensual(),
            ),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.orange),
              title: const Text("Reporte Personalizado"),
              subtitle: const Text("Seleccionar rango de fechas"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _generarReportePersonalizado(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Icon _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Icon(Icons.pending, color: Colors.orange, size: 18);
      case 'pagado':
        return const Icon(Icons.payment, color: Colors.green, size: 18);
      case 'preparando':
        return const Icon(Icons.restaurant, color: Colors.blue, size: 18);
      case 'listo':
        return const Icon(Icons.check_circle, color: Colors.teal, size: 18);
      case 'entregado':
        return const Icon(Icons.delivery_dining, color: Colors.purple, size: 18);
      case 'cancelado':
        return const Icon(Icons.cancel, color: Colors.red, size: 18);
      default:
        return const Icon(Icons.info, color: Colors.grey, size: 18);
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return "0.00";
    final num = double.tryParse(value.toString()) ?? 0.0;
    return num.toStringAsFixed(2);
  }

  Future<void> _mostrarHistorialCompleto() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final historial = await api.obtenerHistorialPagos(limit: 100);
      Navigator.pop(context); // Close loading dialog

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final pagos = historial['pagos'] as List<dynamic>;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Historial de Pagos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: pagos.length,
                    itemBuilder: (context, index) {
                      final pago = pagos[index] as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            "#${pago['pedido_id']}",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(pago['cliente'] ?? 'Sin nombre'),
                        subtitle: Text(
                          "Tel: ${pago['telefono']}\nFecha: ${_formatDate(pago['fecha_pago'])}",
                        ),
                        trailing: Text(
                          "\$${_formatNumber(pago['total'])}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar historial: $e")),
      );
    }
  }

  Future<void> _generarReporteSemanal() async {
    final fechaFin = DateTime.now();
    final fechaInicio = fechaFin.subtract(const Duration(days: 7));
    await _mostrarReporte(fechaInicio, fechaFin, "Reporte Semanal");
  }

  Future<void> _generarReporteMensual() async {
    final fechaFin = DateTime.now();
    final fechaInicio = DateTime(fechaFin.year, fechaFin.month, 1);
    await _mostrarReporte(fechaInicio, fechaFin, "Reporte Mensual");
  }

  Future<void> _generarReportePersonalizado() async {
    DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      await _mostrarReporte(dateRange.start, dateRange.end, "Reporte Personalizado");
    }
  }

  Future<void> _mostrarReporte(DateTime fechaInicio, DateTime fechaFin, String titulo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final formatoFecha = DateFormat('yyyy-MM-dd');
      final reporte = await api.obtenerReporteVentas(
        formatoFecha.format(fechaInicio),
        formatoFecha.format(fechaFin),
      );
      
      Navigator.pop(context); // Close loading dialog

      if (!mounted) return;

      _mostrarDialogoReporte(reporte, titulo);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al generar reporte: $e")),
      );
    }
  }

  void _mostrarDialogoReporte(Map<String, dynamic> reporte, String titulo) {
    final resumen = reporte['resumen'] as Map<String, dynamic>;
    final ventasPorDia = reporte['ventas_por_dia'] as List<dynamic>;
    final productosTop = reporte['productos_mas_vendidos'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Período: ${reporte['periodo']['fecha_inicio']} al ${reporte['periodo']['fecha_fin']}",
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const Divider(),
              
              const Text("Resumen:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInfoRow("Total Pedidos:", "${resumen['total_pedidos'] ?? 0}"),
              _buildInfoRow("Total Ventas:", "\$${_formatNumber(resumen['total_ventas'])}"),
              _buildInfoRow("Promedio:", "\$${_formatNumber(resumen['promedio_venta'])}"),
              _buildInfoRow("Venta Mínima:", "\$${_formatNumber(resumen['venta_minima'])}"),
              _buildInfoRow("Venta Máxima:", "\$${_formatNumber(resumen['venta_maxima'])}"),
              
              const SizedBox(height: 16),
              const Text("Productos Más Vendidos:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              ...productosTop.take(5).map((prod) {
                final p = prod as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${p['name']}",
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${p['cantidad_vendida']} unidades",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }
}
