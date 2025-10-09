import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_pedidos/models/product.dart';
import 'package:app_pedidos/pages/agregar_producto_page.dart';
import 'package:app_pedidos/pages/confirmar_pedido_page.dart';
import 'package:app_pedidos/pages/pedidos_cajero_page.dart';   // 👈 Import cajero
import 'package:app_pedidos/pages/pedidos_cocinero_page.dart'; // 👈 Import cocinero
import 'package:geolocator/geolocator.dart';

class ProductosPorCategoriaPage extends StatefulWidget {
  final List<Product> productos;
  final String direccionEntrega;
  final void Function(Product)? onAgregarAlPedido;
  final String role;

  const ProductosPorCategoriaPage({
    Key? key,
    required this.productos,
    required this.direccionEntrega,
    this.onAgregarAlPedido,
    required this.role,
  }) : super(key: key);

  @override
  _ProductosPorCategoriaPageState createState() =>
      _ProductosPorCategoriaPageState();
}

class _ProductosPorCategoriaPageState extends State<ProductosPorCategoriaPage> {
  late TextEditingController _direccionController;
  List<Product> carrito = [];
  Map<int, int> cantidadesSeleccionadas = {}; // idProducto -> cantidad

  @override
  void initState() {
    super.initState();
    _direccionController = TextEditingController(text: widget.direccionEntrega);
  }

  @override
  void dispose() {
    _direccionController.dispose();
    super.dispose();
  }

  Future<Position> obtenerUbicacion() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) throw 'El GPS está desactivado';

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw 'Permiso de ubicación denegado';
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void abrirConfirmarPedido() async {
    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay productos en el carrito")),
      );
      return;
    }

    Position posicion;
    try {
      posicion = await obtenerUbicacion();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error ubicación: $e')));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmarPedidoPage(
          carrito: carrito,
          direccionEntrega: _direccionController.text,
          ubicacion: {'lat': posicion.latitude, 'lng': posicion.longitude},
        ),
      ),
    );

    if (result != null && result['success'] == true) {
      setState(() {
        carrito.clear();
        cantidadesSeleccionadas.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido confirmado correctamente")),
      );
    }
  }

  void mostrarDetalleProducto(Product producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(producto.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (producto.imageUrl != null)
              Image.network(
                producto.imageUrl!,
                height: 150,
                fit: BoxFit.cover,
              )
            else
              const Icon(Icons.image_not_supported, size: 80),
            const SizedBox(height: 12),
            Text(
              producto.description ?? "Sin descripción",
              textAlign: TextAlign.center,
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Product>> productosPorCategoria = {};
    for (var producto in widget.productos) {
      final catName = producto.categoryName ?? 'Sin categoría';
      productosPorCategoria.putIfAbsent(catName, () => []);
      productosPorCategoria[catName]!.add(producto);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (widget.role == "admin") ...[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Agregar Producto",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgregarProductoPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.point_of_sale),
              tooltip: "Ir a Cajero",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PedidosCajeroPage()), // 👈 Navega Cajero
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.restaurant_menu),
              tooltip: "Ir a Cocinero",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PedidosCocineroPage()), // 👈 Navega Cocinero
                );
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dirección editable
            Card(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Entregar pedido en...",
                        ),
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Productos por categoría
            ...productosPorCategoria.entries.map((entry) {
              final categoryName = entry.key;
              final items = entry.value;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  backgroundColor: Colors.deepPurple.withOpacity(0.05),
                  collapsedBackgroundColor:
                  Colors.deepPurple.withOpacity(0.03),
                  leading: const Icon(Icons.category, color: Colors.deepPurple),
                  trailing: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.deepPurple),
                  title: Text(
                    categoryName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: items.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final producto = items[index];
                        final cantidadActual =
                            cantidadesSeleccionadas[producto.id] ?? 1;

                        return GestureDetector(
                          onTap: () => mostrarDetalleProducto(producto),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color.fromARGB(30, 103, 58, 183)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: producto.imageUrl != null
                                      ? AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      producto.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : const Icon(Icons.image_not_supported,
                                      size: 50),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        producto.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "\$${producto.price.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 20),
                                            onPressed: () {
                                              setState(() {
                                                cantidadesSeleccionadas[
                                                producto.id] =
                                                    (cantidadesSeleccionadas[
                                                    producto.id] ??
                                                        1) -
                                                        1;
                                                if (cantidadesSeleccionadas[
                                                producto.id]! <
                                                    1) {
                                                  cantidadesSeleccionadas[
                                                  producto.id] = 1;
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                            '$cantidadActual',
                                            style:
                                            const TextStyle(fontSize: 16),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 20),
                                            onPressed: () {
                                              setState(() {
                                                cantidadesSeleccionadas[
                                                producto.id] =
                                                    (cantidadesSeleccionadas[
                                                    producto.id] ??
                                                        1) +
                                                        1;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            final cantidad =
                                                cantidadesSeleccionadas[
                                                producto.id] ??
                                                    1;

                                            final indexExistente = carrito
                                                .indexWhere((p) =>
                                            p.id == producto.id);

                                            if (indexExistente >= 0) {
                                              setState(() {
                                                carrito[indexExistente]
                                                    .cantidad =
                                                    cantidad;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Cantidad de ${producto.name} actualizada a x${carrito[indexExistente].cantidad}'),
                                                ),
                                              );
                                            } else {
                                              setState(() {
                                                producto.cantidad = cantidad;
                                                carrito.add(producto);
                                              });
                                              if (widget.onAgregarAlPedido !=
                                                  null) {
                                                widget.onAgregarAlPedido!(
                                                    producto);
                                              }
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${producto.name} agregado al pedido (x$cantidad)'),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons
                                              .add_shopping_cart, color: Colors.white),
                                          label: const Text(
                                            "Agregar Producto",
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirConfirmarPedido,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Confirmar Pedido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
