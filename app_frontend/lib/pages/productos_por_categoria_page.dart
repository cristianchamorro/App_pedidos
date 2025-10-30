import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:app_pedidos/models/product.dart';
import 'package:app_pedidos/pages/agregar_producto_page.dart';
import 'package:app_pedidos/pages/confirmar_pedido_page.dart';
import 'package:app_pedidos/pages/pedidos_cajero_page.dart';   //
import 'package:app_pedidos/pages/pedidos_cocinero_page.dart'; //
import 'package:app_pedidos/pages/domiciliario_page.dart';
import 'package:app_pedidos/pages/pedidos_listos_page.dart';
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
  String? categoriaSeleccionada; // Para filtro de categorías
  String searchQuery = ''; // Para búsqueda de productos

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

  double get totalCarrito {
    return carrito.fold(0.0, (sum, product) => sum + (product.price * product.cantidad));
  }

  int get totalItemsCarrito {
    return carrito.fold(0, (sum, product) => sum + product.cantidad);
  }

  String? _getCategoryImageUrl(List<Product> productos) {
    if (productos.isEmpty) return null;
    
    // Try to find a product with a valid image
    for (var producto in productos) {
      if (producto.imageUrl != null && producto.imageUrl!.isNotEmpty) {
        return producto.imageUrl;
      }
    }
    
    // No product with valid image found
    return null;
  }

  void mostrarDetalleProducto(Product producto) {
    int cantidadDialog = cantidadesSeleccionadas[producto.id] ?? 1;
    
    showDialog(
      context: context,
      builder: (context) {
        final maxDialogImgHeight = MediaQuery.of(context).size.height * 0.4;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(producto.name),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (producto.imageUrl != null && producto.imageUrl!.isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxDialogImgHeight),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            producto.imageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                alignment: Alignment.center,
                                height: maxDialogImgHeight,
                                child: const CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              height: maxDialogImgHeight,
                              child: const Icon(Icons.broken_image, size: 64),
                            ),
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.image_not_supported, size: 80),
                    const SizedBox(height: 12),
                    Text(
                      producto.description ?? "Sin descripción",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "\$${producto.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: AppTheme.primary),
                          onPressed: () {
                            if (cantidadDialog > 1) {
                              setDialogState(() {
                                cantidadDialog--;
                              });
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$cantidadDialog',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                          onPressed: () {
                            setDialogState(() {
                              cantidadDialog++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      cantidadesSeleccionadas[producto.id] = cantidadDialog;
                    });
                    
                    final indexExistente = carrito.indexWhere((p) => p.id == producto.id);
                    
                    if (indexExistente >= 0) {
                      setState(() {
                        carrito[indexExistente].cantidad = cantidadDialog;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${producto.name} actualizado (x$cantidadDialog)'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() {
                        producto.cantidad = cantidadDialog;
                        carrito.add(producto);
                      });
                      if (widget.onAgregarAlPedido != null) {
                        widget.onAgregarAlPedido!(producto);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('${producto.name} agregado (x$cantidadDialog)'),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Agregar al Carrito"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
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

    // Filtrar productos según la categoría seleccionada y búsqueda
    final Map<String, List<Product>> productosFiltrados = {};
    productosPorCategoria.forEach((categoria, productos) {
      // Filtrar por categoría seleccionada
      if (categoriaSeleccionada != null && categoria != categoriaSeleccionada) {
        return;
      }
      
      // Filtrar por búsqueda
      final productosBuscados = productos.where((producto) {
        return producto.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               (producto.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      }).toList();
      
      if (productosBuscados.isNotEmpty) {
        productosFiltrados[categoria] = productosBuscados;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lista de Productos",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true, // centrar el título
        elevation: 6, // sombra
        backgroundColor: Colors.transparent, // transparente porque usamos flexibleSpace
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
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // iconos blancos
        actions: [
          // Cart badge
          if (carrito.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: abrirConfirmarPedido,
                  tooltip: "Ver Carrito",
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$totalItemsCarrito',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
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
                    builder: (context) => const PedidosCajeroPage(),
                  ),
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
                    builder: (context) => const PedidosCocineroPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delivery_dining),
              tooltip: "Ir a Domiciliario",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DomiciliarioPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: "Pedidos Listos",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PedidosListosPage(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.primary.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // Modern category cards
          if (productosPorCategoria.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // "Todas" category card
                    _buildCategoryCard(
                      context: context,
                      categoryName: 'Todas',
                      count: widget.productos.length,
                      isSelected: categoriaSeleccionada == null,
                      imageUrl: _getCategoryImageUrl(widget.productos),
                      onTap: () {
                        setState(() {
                          categoriaSeleccionada = null;
                        });
                      },
                    ),
                    // Category cards from products
                    ...productosPorCategoria.entries.map((entry) {
                      final categoria = entry.key;
                      final productos = entry.value;
                      final count = productos.length;
                      final isSelected = categoriaSeleccionada == categoria;
                      
                      // Get representative image from this category
                      String? imageUrl = _getCategoryImageUrl(productos);

                      return _buildCategoryCard(
                        context: context,
                        categoryName: categoria,
                        count: count,
                        isSelected: isSelected,
                        imageUrl: imageUrl,
                        onTap: () {
                          setState(() {
                            categoriaSeleccionada = categoria;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

          // Products list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dirección editable
                  Card(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primary),
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

                  // Cart summary
                  if (carrito.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$totalItemsCarrito ${totalItemsCarrito == 1 ? "producto" : "productos"}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Total: \$${totalCarrito.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: abrirConfirmarPedido,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Ver Carrito'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Productos por categoría
                  ...productosFiltrados.entries.map((entry) {
              final categoryName = entry.key;
              final items = entry.value;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  backgroundColor: AppTheme.primary.withOpacity(0.05),
                  collapsedBackgroundColor: AppTheme.primary.withOpacity(0.03),
                  initiallyExpanded: categoriaSeleccionada == categoryName,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: AppTheme.primary),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.primary),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Ajuste responsive de columnas según el ancho disponible
                        // Máximo ancho por ítem ~220px
                        final maxItemWidth = 220.0;
                        final crossAxisCount = (constraints.maxWidth / maxItemWidth)
                            .floor()
                            .clamp(1, 6);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          itemCount: items.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            // childAspectRatio menor => más alto; ajusta según tu UI
                            childAspectRatio: 0.76,
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
                                      color: AppTheme.primary.withOpacity(0.25),
                                      blurRadius: 8,
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
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Imagen con proporción fija para evitar desbordes
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                          child: AspectRatio(
                                            aspectRatio: 1.2,
                                            child: (producto.imageUrl != null &&
                                                producto.imageUrl!.isNotEmpty)
                                                ? Stack(
                                              children: [
                                                Image.network(
                                                  producto.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  loadingBuilder: (context, child, progress) {
                                                    if (progress == null) return child;
                                                    return Container(
                                                      color: Colors.grey.shade200,
                                                      alignment: Alignment.center,
                                                      child: const CircularProgressIndicator(),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stack) =>
                                                      Container(
                                                        color: Colors.grey.shade200,
                                                        alignment: Alignment.center,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: const [
                                                            Icon(Icons.broken_image,
                                                                size: 40, color: Colors.grey),
                                                            SizedBox(height: 4),
                                                            Text('Imagen no disponible',
                                                                style: TextStyle(
                                                                    fontSize: 10, color: Colors.grey)),
                                                          ],
                                                        ),
                                                      ),
                                                ),
                                                // Gradient overlay for better text readability
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black.withOpacity(0.1),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                                : Container(
                                              color: Colors.grey.shade200,
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.fastfood,
                                                      size: 40, color: Colors.grey),
                                                  SizedBox(height: 4),
                                                  Text('Sin imagen',
                                                      style: TextStyle(
                                                          fontSize: 10, color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Price badge on top of image
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade600,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              "\$${producto.price.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Contenido
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              producto.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: AppTheme.primary,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.remove,
                                                          size: 20),
                                                      onPressed: () {
                                                        setState(() {
                                                          final current =
                                                          (cantidadesSeleccionadas[
                                                          producto.id] ??
                                                              1);
                                                          final next = current - 1;
                                                          cantidadesSeleccionadas[
                                                          producto.id] =
                                                          next < 1 ? 1 : next;
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      '$cantidadActual',
                                                      style: const TextStyle(
                                                          fontSize: 16),
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
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      final cantidad =
                                                          cantidadesSeleccionadas[
                                                          producto.id] ??
                                                              1;

                                                      final indexExistente =
                                                      carrito.indexWhere(
                                                              (p) =>
                                                          p.id ==
                                                              producto.id);

                                                      if (indexExistente >= 0) {
                                                        setState(() {
                                                          carrito[indexExistente]
                                                              .cantidad =
                                                              cantidad;
                                                        });
                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                '${producto.name} actualizado (x${carrito[indexExistente].cantidad})'),
                                                            duration: const Duration(seconds: 1),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      } else {
                                                        setState(() {
                                                          producto.cantidad =
                                                              cantidad;
                                                          carrito.add(producto);
                                                        });
                                                        if (widget
                                                            .onAgregarAlPedido !=
                                                            null) {
                                                          widget.onAgregarAlPedido!(
                                                              producto);
                                                        }
                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              children: [
                                                                const Icon(Icons.check_circle, color: Colors.white),
                                                                const SizedBox(width: 8),
                                                                Text('${producto.name} agregado (x$cantidad)'),
                                                              ],
                                                            ),
                                                            duration: const Duration(seconds: 1),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Icon(Icons.add_shopping_cart, size: 16),
                                                        SizedBox(width: 4),
                                                        Text("Agregar", style: TextStyle(fontSize: 13)),
                                                      ],
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppTheme.primary,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      elevation: 4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirConfirmarPedido,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Confirmar Pedido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String categoryName,
    required int count,
    required bool isSelected,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image with overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isSelected
                        ? [AppTheme.primary.withOpacity(0.8), AppTheme.primaryDark]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.category, size: 40, color: Colors.white),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isSelected
                                    ? [
                                        AppTheme.primary.withOpacity(0.6),
                                        AppTheme.primaryDark.withOpacity(0.8),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0.3),
                                        Colors.black.withOpacity(0.6),
                                      ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Icon(Icons.category, size: 50, color: Colors.white),
                      ),
              ),
            ),
            // Text overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: isSelected ? AppTheme.primary : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Selected indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}