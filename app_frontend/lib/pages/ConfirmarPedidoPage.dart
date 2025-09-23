// confirmar_pedido_page.dart
import 'package:flutter/material.dart';
import 'package:app_pedidos/models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


class ConfirmarPedidoPage extends StatefulWidget {
  final List<Product> carrito;
  final String direccionEntrega;
  final Map<String, double> ubicacion; // lat/lng

  const ConfirmarPedidoPage({
    Key? key,
    required this.carrito,
    required this.direccionEntrega,
    required this.ubicacion,
  }) : super(key: key);

  @override
  _ConfirmarPedidoPageState createState() => _ConfirmarPedidoPageState();
}

class _ConfirmarPedidoPageState extends State<ConfirmarPedidoPage> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController(text: widget.direccionEntrega);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  double get totalPedido {
    double total = 0;
    for (var p in widget.carrito) {
      total += (p.price * (p.cantidad ?? 1));
    }
    return total;
  }

  Future<void> confirmarPedido() async {
    if (_nombreController.text.isEmpty || _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y teléfono son obligatorios")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        "nombre": _nombreController.text.trim(),
        "telefono": _telefonoController.text.trim(),
        "direccion_entrega": _direccionController.text.trim(),
        "ubicacion": {
          "lat": widget.ubicacion['lat'],
          "lng": widget.ubicacion['lng'],
        },
        "productos": widget.carrito
            .map((p) => {
                  "id": p.id,
                  "cantidad": p.cantidad ?? 1,
                  "price": p.price,
                })
            .toList(),
      };

      final url = Uri.parse('http://127.0.0.1:3000/pedidos');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido confirmado correctamente")),
        );
        Navigator.pop(context, data); // Devuelve info al carrito si quieres
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al confirmar pedido: ${data['error'] ?? 'Desconocido'}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmar Pedido"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre del receptor",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Teléfono del receptor",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _direccionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Dirección de entrega",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Resumen del pedido",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.carrito.length,
              itemBuilder: (context, index) {
                final p = widget.carrito[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('Cantidad: ${p.cantidad ?? 1}'),
                  trailing: Text("\$${(p.price * (p.cantidad ?? 1)).toStringAsFixed(2)}"),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              "Total: \$${totalPedido.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : confirmarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirmar Pedido", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
