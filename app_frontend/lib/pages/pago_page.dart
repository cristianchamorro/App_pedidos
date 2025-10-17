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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text("Pago Exitoso"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            _buildReciboItem("Pedido #", widget.pedidoId.toString()),
            _buildReciboItem("Total", "\$${widget.total.toStringAsFixed(2)}"),
            _buildReciboItem("Método de Pago", _metodoPago),
            if (_metodoPago == 'Efectivo') ...[
              _buildReciboItem("Efectivo Recibido", "\$${_efectivoController.text}"),
              _buildReciboItem("Vuelto", "\$${_vuelto.toStringAsFixed(2)}"),
            ],
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "El pedido pasó a preparación",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
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
            // Total Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total a pagar:",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${widget.total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Method Selection
            const Text(
              "Método de Pago",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 2,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Efectivo"),
                      ],
                    ),
                    value: 'Efectivo',
                    groupValue: _metodoPago,
                    onChanged: (value) {
                      setState(() {
                        _metodoPago = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Tarjeta Débito"),
                      ],
                    ),
                    value: 'Tarjeta Débito',
                    groupValue: _metodoPago,
                    onChanged: (value) {
                      setState(() {
                        _metodoPago = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Tarjeta Crédito"),
                      ],
                    ),
                    value: 'Tarjeta Crédito',
                    groupValue: _metodoPago,
                    onChanged: (value) {
                      setState(() {
                        _metodoPago = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.qr_code, color: Colors.purple),
                        SizedBox(width: 8),
                        Text("Transferencia/QR"),
                      ],
                    ),
                    value: 'Transferencia',
                    groupValue: _metodoPago,
                    onChanged: (value) {
                      setState(() {
                        _metodoPago = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cash input (only for Efectivo)
            if (_metodoPago == 'Efectivo') ...[
              const Text(
                "Efectivo Recibido",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _efectivoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Monto recibido",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _calcularVuelto,
              ),
              const SizedBox(height: 16),
              
              // Change display
              Card(
                elevation: 4,
                color: Colors.green[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Vuelto:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${_vuelto.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
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
