import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class CajeroDashboardMejoradoPage extends StatefulWidget {
  final int? userId;

  const CajeroDashboardMejoradoPage({Key? key, this.userId}) : super(key: key);

  @override
  _CajeroDashboardMejoradoPageState createState() => _CajeroDashboardMejoradoPageState();
}

class _CajeroDashboardMejoradoPageState extends State<CajeroDashboardMejoradoPage> {
  final ApiService api = ApiService();
  Map<String, dynamic>? _estadisticas;
  Map<String, dynamic>? _ventasDelDia;
  bool _isLoading = true;
  int _selectedPeriodo = 0; // 0: Hoy, 1: Semana, 2: Mes

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar datos: $e")),
        );
      }
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final num = double.tryParse(value.toString()) ?? 0;
    return NumberFormat('#,###').format(num);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard de Ventas",
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
            onPressed: _cargarDatos,
            tooltip: "Actualizar",
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
                  // Selector de período
                  _buildPeriodoSelector(),
                  
                  const SizedBox(height: 20),
                  
                  // Estadísticas principales
                  _buildEstadisticasPrincipales(),
                  
                  const SizedBox(height: 24),
                  
                  // Gráfico de ventas
                  _buildGraficoVentas(),
                  
                  const SizedBox(height: 24),
                  
                  // Gráfico de pedidos por estado
                  _buildGraficoPedidosPorEstado(),
                  
                  const SizedBox(height: 24),
                  
                  // Métricas adicionales
                  _buildMetricasAdicionales(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodoSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPeriodoButton('Hoy', 0, Icons.today),
          _buildPeriodoButton('Semana', 1, Icons.calendar_view_week),
          _buildPeriodoButton('Mes', 2, Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _buildPeriodoButton(String label, int index, IconData icon) {
    final isSelected = _selectedPeriodo == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriodo = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasPrincipales() {
    if (_estadisticas == null) return const SizedBox();
    
    final stats = _estadisticas!['estadisticas'] as Map<String, dynamic>;
    Map<String, dynamic> periodo;
    
    switch (_selectedPeriodo) {
      case 0:
        periodo = stats['hoy'] as Map<String, dynamic>;
        break;
      case 1:
        periodo = stats['semana'] as Map<String, dynamic>;
        break;
      case 2:
        periodo = stats['mes'] as Map<String, dynamic>;
        break;
      default:
        periodo = stats['hoy'] as Map<String, dynamic>;
    }

    final pedidosKey = _selectedPeriodo == 0 
        ? 'pedidos_hoy' 
        : _selectedPeriodo == 1 
            ? 'pedidos_semana' 
            : 'pedidos_mes';
    final totalKey = _selectedPeriodo == 0 
        ? 'total_hoy' 
        : _selectedPeriodo == 1 
            ? 'total_semana' 
            : 'total_mes';

    final pedidos = int.tryParse(periodo[pedidosKey]?.toString() ?? '0') ?? 0;
    final total = double.tryParse(periodo[totalKey]?.toString() ?? '0') ?? 0;
    final promedio = pedidos > 0 ? total / pedidos : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Resumen del Período",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Total Ventas",
                "\$${_formatNumber(total)}",
                Icons.attach_money,
                Colors.green,
                "+12.5%",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                "Pedidos",
                "$pedidos",
                Icons.shopping_cart,
                Colors.blue,
                "+8.3%",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Ticket Promedio",
                "\$${_formatNumber(promedio)}",
                Icons.receipt_long,
                Colors.purple,
                "+5.2%",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                "Pendientes",
                "${stats['pendientes']['pedidos_pendientes']}",
                Icons.pending,
                Colors.orange,
                "",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              if (trend.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoVentas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tendencia de Ventas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20000,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${(value / 1000).toInt()}k',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100000,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 35000),
                      const FlSpot(1, 42000),
                      const FlSpot(2, 38000),
                      const FlSpot(3, 55000),
                      const FlSpot(4, 62000),
                      const FlSpot(5, 72000),
                      const FlSpot(6, 58000),
                    ],
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPedidosPorEstado() {
    if (_ventasDelDia == null) return const SizedBox();
    
    final porEstado = _ventasDelDia!['por_estado'] as List<dynamic>? ?? [];
    
    if (porEstado.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pedidos por Estado",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Gráfico de dona
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: porEstado.map((item) {
                        final status = item['status'] as String;
                        final cantidad = int.tryParse(item['cantidad']?.toString() ?? '0') ?? 0;
                        
                        Color color;
                        switch (status) {
                          case 'pendiente':
                            color = Colors.orange;
                            break;
                          case 'pagado':
                            color = Colors.blue;
                            break;
                          case 'preparando':
                            color = Colors.purple;
                            break;
                          case 'listo':
                            color = Colors.green;
                            break;
                          case 'entregado':
                            color = Colors.teal;
                            break;
                          default:
                            color = Colors.grey;
                        }
                        
                        return PieChartSectionData(
                          color: color,
                          value: cantidad.toDouble(),
                          title: '$cantidad',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              // Leyenda
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: porEstado.map((item) {
                    final status = item['status'] as String;
                    final cantidad = item['cantidad']?.toString() ?? '0';
                    
                    Color color;
                    switch (status) {
                      case 'pendiente':
                        color = Colors.orange;
                        break;
                      case 'pagado':
                        color = Colors.blue;
                        break;
                      case 'preparando':
                        color = Colors.purple;
                        break;
                      case 'listo':
                        color = Colors.green;
                        break;
                      case 'entregado':
                        color = Colors.teal;
                        break;
                      default:
                        color = Colors.grey;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${status[0].toUpperCase()}${status.substring(1)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            cantidad,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasAdicionales() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Métricas Adicionales",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMetricRow("Tiempo Promedio de Atención", "8.5 min", Icons.timer, Colors.blue),
          const Divider(),
          _buildMetricRow("Tasa de Conversión", "87.3%", Icons.trending_up, Colors.green),
          const Divider(),
          _buildMetricRow("Satisfacción del Cliente", "4.6/5.0", Icons.star, Colors.amber),
          const Divider(),
          _buildMetricRow("Productos Más Vendidos", "15 items", Icons.inventory, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
