import 'package:flutter/material.dart';
import '../api_service.dart';

class PagoPage extends StatefulWidget {
  final int pedidoId;
  final double total;

  const PagoPage({Key? key, required this.pedidoId, required this.total}) : super(key: key);

  @override
  _PagoPageState createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  final ApiService api = ApiService();
  final TextEditingController _efectivoController = TextEditingController();
  double _vuelto = 0.0;

  void _calcularVuelto(String valor) {
    double efectivo = double.tryParse(valor) ?? 0.0;
    setState(() {
      _vuelto = efectivo - widget.total;
      if (_vuelto < 0) _vuelto = 0.0;
    });
  }

  Future<void> _confirmarPago() async {
    double efectivo = double.tryParse(_efectivoController.text) ?? 0.0;
    if (efectivo < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El monto ingresado es menor al total")),
      );
      return;
    }

    try {
      // 1️⃣ Confirmar pago en backend y actualizar estado a 'preparando'
      bool success = await api.confirmarPago(widget.pedidoId, efectivo);
      if (success) {
        // 2️⃣ Mostrar alerta de pago realizado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pago realizado. Pedido en preparación")),
        );

        // 3️⃣ Redirigir automáticamente a la pantalla de pedidos pendientes
        Navigator.pop(context, true); // Se puede usar el .then en PedidosCajeroPage para refrescar

        // ✅ Aquí ya el backend debe haber actualizado el pedido a 'preparando'
        // Cuando tengas la pantalla de cocina, podrá leer los pedidos con estado 'preparando'
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar el pago: $e")),
      );
    }
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
        title: Text("Pago del Pedido ${widget.pedidoId}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total a pagar: \$${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _efectivoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Efectivo recibido",
                border: OutlineInputBorder(),
              ),
              onChanged: _calcularVuelto,
            ),
            const SizedBox(height: 16),
            Text("Vuelto: \$${_vuelto.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmarPago,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Confirmar Pago"),
            ),
          ],
        ),
      ),
    );
  }
}
