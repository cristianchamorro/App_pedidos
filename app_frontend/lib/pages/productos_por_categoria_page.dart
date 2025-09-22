import 'package:flutter/material.dart';
import 'package:app_pedidos/models/product.dart';
import 'agregar_producto_page.dart';

class ProductosPorCategoriaPage extends StatefulWidget {
  final List<Product> productos;
  final String direccionEntrega;
  final void Function(Product)? onAgregarAlPedido;

  const ProductosPorCategoriaPage({
    Key? key,
    required this.productos,
    required this.direccionEntrega,
    this.onAgregarAlPedido,
  }) : super(key: key);

  @override
  _ProductosPorCategoriaPageState createState() =>
      _ProductosPorCategoriaPageState();
}

class _ProductosPorCategoriaPageState extends State<ProductosPorCategoriaPage> {
  late TextEditingController _direccionController;

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

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Product>> productosPorCategoria = {};
    for (var producto in widget.productos) {
      final catName = producto.categoryName ?? 'Sin categoría';
      if (!productosPorCategoria.containsKey(catName)) {
        productosPorCategoria[catName] = [];
      }
      productosPorCategoria[catName]!.add(producto);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecciona tu producto por categoría"),
        backgroundColor: Colors.deepPurple,
        actions: [
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

            // Categorías y productos
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
                  leading:
                      const Icon(Icons.category, color: Colors.deepPurple),
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
                        childAspectRatio: 0.85, // ?? más compacto
                      ),
                      itemBuilder: (context, index) {
                        final producto = items[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(
                                  producto.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (producto.imageUrl != null)
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          producto.imageUrl!,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    if (producto.description != null)
                                      Text(
                                        producto.description!,
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Cerrar"),
                                    onPressed: () =>
                                        Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          },
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
                              mainAxisSize: MainAxisSize.min, // ?? evita estirarse
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                  child: producto.imageUrl != null
                                      ? AspectRatio(
                                          aspectRatio:
                                              16 / 9, // ?? imagen compacta
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
                                      if (producto.description != null)
                                        Text(
                                          producto.description!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "\$${producto.price.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: widget
                                                      .onAgregarAlPedido !=
                                                  null
                                              ? () => widget
                                                  .onAgregarAlPedido!(
                                                      producto)
                                              : null,
                                          icon: const Icon(
                                              Icons.add_shopping_cart),
                                          label: const Text("Agregar"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.deepPurple,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
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
    );
  }
}
