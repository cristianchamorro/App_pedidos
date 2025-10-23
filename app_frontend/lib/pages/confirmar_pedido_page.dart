import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:app_pedidos/models/product.dart';
import '../theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class ConfirmarPedidoPage extends StatefulWidget {
  final List<Product> carrito;
  final String direccionEntrega;
  final Map<String, double> ubicacion;

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
  bool _pedidoConfirmado = false;

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
    for (var producto in widget.carrito) {
      total += producto.price * (producto.cantidad ?? 1);
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
          "nombre": p.name,
          "cantidad": p.cantidad ?? 1,
          "price": p.price,
          "vendedor": p.vendorName ?? 'N/A',
          "driver": p.driverName ?? 'N/A',
        })
            .toList(),
      };

      final url = Uri.parse('http://192.168.101.6:3000/pedidos');
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

        setState(() {
          _pedidoConfirmado = true;

          // Limpiar cantidades, carrito y formularios
          for (var p in widget.carrito) {
            p.resetCantidad();
          }
          widget.carrito.clear();
          _nombreController.clear();
          _telefonoController.clear();
          _direccionController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Error al confirmar pedido: ${data['error'] ?? 'Desconocido'}"),
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

  Future<void> enviarWhatsApp() async {
    if (!_pedidoConfirmado) return;

    String mensaje = "📦 *Nuevo pedido*\n";
    mensaje += "Nombre: ${_nombreController.text}\n";
    mensaje += "Teléfono: ${_telefonoController.text}\n";
    mensaje += "Dirección: ${_direccionController.text}\n";
    mensaje +=
    "Ubicación: lat ${widget.ubicacion['lat']}, lng ${widget.ubicacion['lng']}\n\n";
    mensaje += "*Productos:*\n";

    for (var p in widget.carrito) {
      mensaje +=
      "- ${p.name} (Cantidad: ${p.cantidad ?? 1})\n  Vendedor: ${p.vendorName ?? 'N/A'}\n  Driver: ${p.driverName ?? 'N/A'}\n  Precio unit: \$${p.price.toStringAsFixed(2)}\n";
    }

    mensaje += "\n*Total: \$${totalPedido.toStringAsFixed(2)}*";

    String telefonoWhatsApp = "573106812608"; // Cambia tu número
    final Uri url = Uri.parse(
        "https://wa.me/$telefonoWhatsApp?text=${Uri.encodeComponent(mensaje)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir WhatsApp")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirmar Pedido",
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
              colors: [AppTheme.primary, AppTheme.primaryLight],
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
              )
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre del cliente",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Teléfono del cliente",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _direccionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Dirección de entrega, solo para Domicilios",
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
                final producto = widget.carrito[index];
                return ListTile(
                  leading: producto.imageUrl != null
                      ? Image.network(producto.imageUrl!,
                      width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.shopping_bag, color: AppTheme.primary),
                  title: Text(producto.name),
                  subtitle: Text(
                    'Cantidad: ${producto.cantidad} | Vendedor: ${producto.vendorName ?? 'N/A'} | Driver: ${producto.driverName ?? 'N/A'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "\$${(producto.price * producto.cantidad).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.carrito.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              "Total: \$${totalPedido.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),

            // Botón Confirmar Pedido
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : confirmarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Confirmar Pedido",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón Enviar a WhatsApp
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pedidoConfirmado ? enviarWhatsApp : null,
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                label: const Text(
                  "Enviar pedido a WhatsApp",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
