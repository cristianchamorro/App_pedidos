import 'package:flutter/material.dart';
import '../api_service.dart';

class PagoPage extends StatefulWidget {
  final int pedidoId;
  final double total;
  final int? userId;

  const PagoPage({Key? key, required this.pedidoId, required this.total, this.userId}) : super(key: key);

  @override
  _PagoPageState createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  final ApiService api = ApiService();
  final TextEditingController _efectivoController = TextEditingController();
  double _vuelto = 0.0;
  String _metodoPago = 'Efectivo'; // Default payment method

  void _calcularVuelto(String valor) {
    double efectivo = double.tryParse(valor) ?? 0.0;
    setState(() {
      _vuelto = efectivo - widget.total;
      if (_vuelto < 0) _vuelto = 0.0;
    });
  }

  Future<void> _confirmarPago() async {
    // Validate payment amount for cash payments
    if (_metodoPago == 'Efectivo') {
      double efectivo = double.tryParse(_efectivoController.text) ?? 0.0;
      if (efectivo < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("El monto ingresado es menor al total")),
        );
        return;
      }
    }

    try {
      // 1️⃣ Confirmar pago en backend y actualizar estado a 'pagado'
      bool success = await api.confirmarPago(
        widget.pedidoId, 
        widget.total, // Send total for non-cash payments
        changedBy: widget.userId,
      );
      if (success) {
        // 2️⃣ Mostrar alerta de pago realizado con detalles
        _mostrarRecibo();

        // 3️⃣ Redirigir automáticamente a la pantalla de pedidos pendientes
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context, true);

        // ✅ Aquí ya el backend debe haber actualizado el pedido a 'pagado'
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar el pago: $e")),
      );
    }
  }

  void _mostrarRecibo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              "Pago Exitoso",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildReciboItem("Pedido #", widget.pedidoId.toString()),
                  const Divider(height: 16),
                  _buildReciboItem("Total", "\$${widget.total.toStringAsFixed(2)}"),
                  const Divider(height: 16),
                  _buildReciboItem("Método de Pago", _metodoPago),
                  if (_metodoPago == 'Efectivo') ...[
                    const Divider(height: 16),
                    _buildReciboItem("Efectivo Recibido", "\$${_efectivoController.text}"),
                    const Divider(height: 16),
                    _buildReciboItem("Vuelto", "\$${_vuelto.toStringAsFixed(2)}"),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "El pedido pasó a preparación",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text("Cerrar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciboItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String value, IconData icon, Color color, String description) {
    final isSelected = _metodoPago == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : null,
        borderRadius: isSelected ? BorderRadius.circular(12) : null,
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        value: value,
        groupValue: _metodoPago,
        activeColor: color,
        onChanged: (newValue) {
          setState(() {
            _metodoPago = newValue!;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _efectivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pago del Pedido ${widget.pedidoId}",
          style: const TextStyle(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Card with gradient
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Total a pagar",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Pedido confirmado",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 28,
                        ),
                        Text(
                          "${widget.total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Method Selection
            Row(
              children: const [
                Icon(Icons.payment, color: Colors.deepPurple, size: 24),
                SizedBox(width: 8),
                Text(
                  "Método de Pago",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildPaymentMethodTile(
                    'Efectivo',
                    Icons.attach_money,
                    Colors.green,
                    "Pago en efectivo con cálculo de vuelto",
                  ),
                  const Divider(height: 1),
                  _buildPaymentMethodTile(
                    'Tarjeta Débito',
                    Icons.credit_card,
                    Colors.blue,
                    "Pago con tarjeta de débito",
                  ),
                  const Divider(height: 1),
                  _buildPaymentMethodTile(
                    'Tarjeta Crédito',
                    Icons.credit_card,
                    Colors.orange,
                    "Pago con tarjeta de crédito",
                  ),
                  const Divider(height: 1),
                  _buildPaymentMethodTile(
                    'Transferencia',
                    Icons.qr_code,
                    Colors.purple,
                    "Transferencia bancaria o código QR",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cash input (only for Efectivo)
            if (_metodoPago == 'Efectivo') ...[
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.payments, color: Colors.deepPurple, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Efectivo Recibido",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextField(
                    controller: _efectivoController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Monto en efectivo",
                      hintText: "Ej: ${(widget.total + 10).toStringAsFixed(2)}",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.attach_money, color: Colors.green),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: _calcularVuelto,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Change display
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade400, Colors.teal.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.monetization_on, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "Vuelto",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\$${_vuelto.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Confirm Payment Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _confirmarPago,
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
                  "Confirmar Pago",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
