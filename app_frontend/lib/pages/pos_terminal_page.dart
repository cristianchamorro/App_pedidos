import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class POSTerminalPage extends StatefulWidget {
  final int? userId;

  const POSTerminalPage({Key? key, this.userId}) : super(key: key);

  @override
  _POSTerminalPageState createState() => _POSTerminalPageState();
}

class _POSTerminalPageState extends State<POSTerminalPage> {
  final ApiService api = ApiService();
  List<Product> _todosProductos = [];
  List<Product> _productosFiltrados = [];
  Map<int, int> _carrito = {}; // productId -> cantidad
  String _filtroCategoria = 'Todos';
  Set<String> _categorias = {'Todos'};
  String _busqueda = '';
  
  // Payment
  String _metodoPago = 'efectivo'; // efectivo, tarjeta, qr
  double _montoPagado = 0.0;
  bool _mostrarTeclado = false;
  String _inputTeclado = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await api.fetchProducts();
      setState(() {
        _todosProductos = productos;
        _productosFiltrados = productos;
        
        // Extraer categorías únicas
        _categorias = {'Todos'};
        for (var p in productos) {
          if (p.categoryName != null) {
            _categorias.add(p.categoryName!);
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar productos: $e")),
      );
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _productosFiltrados = _todosProductos.where((p) {
        bool coincideCategoria = _filtroCategoria == 'Todos' ||
            p.categoryName == _filtroCategoria;
        bool coincideBusqueda = _busqueda.isEmpty ||
            p.name.toLowerCase().contains(_busqueda.toLowerCase());
        return coincideCategoria && coincideBusqueda;
      }).toList();
    });
  }

  void _agregarAlCarrito(Product producto) {
    setState(() {
      _carrito[producto.id] = (_carrito[producto.id] ?? 0) + 1;
    });
  }

  void _removerDelCarrito(int productoId) {
    setState(() {
      if (_carrito[productoId] != null && _carrito[productoId]! > 1) {
        _carrito[productoId] = _carrito[productoId]! - 1;
      } else {
        _carrito.remove(productoId);
      }
    });
  }

  double _calcularTotal() {
    double total = 0.0;
    _carrito.forEach((productoId, cantidad) {
      final producto = _todosProductos.firstWhere((p) => p.id == productoId);
      total += producto.price * cantidad;
    });
    return total;
  }

  double _calcularCambio() {
    return _montoPagado - _calcularTotal();
  }

  void _procesarPago() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El carrito está vacío")),
      );
      return;
    }

    final total = _calcularTotal();
    
    if (_metodoPago == 'efectivo' && _montoPagado < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El monto pagado es insuficiente")),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Venta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total: \$${NumberFormat('#,###').format(total)}"),
            const SizedBox(height: 8),
            Text("Método: ${_metodoPago.toUpperCase()}"),
            if (_metodoPago == 'efectivo') ...[
              const SizedBox(height: 8),
              Text("Pagado: \$${NumberFormat('#,###').format(_montoPagado)}"),
              Text("Cambio: \$${NumberFormat('#,###').format(_calcularCambio())}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizarVenta();
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void _finalizarVenta() {
    // Limpiar carrito y estado
    setState(() {
      _carrito.clear();
      _montoPagado = 0.0;
      _inputTeclado = '';
      _mostrarTeclado = false;
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("✓ Venta procesada exitosamente"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTeclaPresionada(String tecla) {
    setState(() {
      if (tecla == '⌫') {
        if (_inputTeclado.isNotEmpty) {
          _inputTeclado = _inputTeclado.substring(0, _inputTeclado.length - 1);
        }
      } else if (tecla == 'C') {
        _inputTeclado = '';
      } else if (tecla == 'OK') {
        _montoPagado = double.tryParse(_inputTeclado) ?? 0.0;
        _mostrarTeclado = false;
      } else {
        _inputTeclado += tecla;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Terminal POS",
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
            onPressed: _cargarProductos,
            tooltip: "Recargar productos",
          ),
        ],
      ),
      body: Row(
        children: [
          // Lado izquierdo: Productos
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // Barra de búsqueda y filtros
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      // Búsqueda
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar productos...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          _busqueda = value;
                          _aplicarFiltros();
                        },
                      ),
                      const SizedBox(height: 8),
                      // Filtros de categoría
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _categorias.map((cat) {
                            final isSelected = cat == _filtroCategoria;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _filtroCategoria = cat;
                                    _aplicarFiltros();
                                  });
                                },
                                selectedColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Grid de productos
                Expanded(
                  child: _productosFiltrados.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text("No hay productos disponibles", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = _productosFiltrados[index];
                            return _buildProductoCard(producto);
                          },
                        ),
                ),
              ],
            ),
          ),
          
          // Lado derecho: Carrito y pago
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header del carrito
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Carrito",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_carrito.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() => _carrito.clear());
                            },
                            tooltip: "Vaciar carrito",
                          ),
                      ],
                    ),
                  ),
                  
                  // Lista de productos en carrito
                  Expanded(
                    child: _carrito.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "Carrito vacío",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _carrito.length,
                            itemBuilder: (context, index) {
                              final productoId = _carrito.keys.elementAt(index);
                              final cantidad = _carrito[productoId]!;
                              final producto = _todosProductos.firstWhere((p) => p.id == productoId);
                              return _buildCarritoItem(producto, cantidad);
                            },
                          ),
                  ),
                  
                  // Total y métodos de pago
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "TOTAL:",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${NumberFormat('#,###').format(_calcularTotal())}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24, thickness: 2),
                        
                        // Métodos de pago
                        const Text(
                          "Método de Pago",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetodoPagoButton(
                                'efectivo',
                                'Efectivo',
                                FontAwesomeIcons.moneyBill,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetodoPagoButton(
                                'tarjeta',
                                'Tarjeta',
                                FontAwesomeIcons.creditCard,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetodoPagoButton(
                                'qr',
                                'QR',
                                FontAwesomeIcons.qrcode,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Input de monto (solo para efectivo)
                        if (_metodoPago == 'efectivo') ...[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _mostrarTeclado = true;
                                _inputTeclado = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Monto recibido:", style: TextStyle(fontSize: 16)),
                                  Text(
                                    "\$${NumberFormat('#,###').format(_montoPagado)}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_montoPagado > 0 && _calcularCambio() >= 0)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "CAMBIO:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    "\$${NumberFormat('#,###').format(_calcularCambio())}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Botón de cobrar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _carrito.isEmpty ? null : _procesarPago,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "COBRAR",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
          ),
        ],
      ),
      
      // Teclado numérico flotante
      bottomSheet: _mostrarTeclado ? _buildTecladoNumerico() : null,
    );
  }

  Widget _buildProductoCard(Product producto) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _agregarAlCarrito(producto),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del producto
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: producto.imageUrl != null && producto.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          producto.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.fastfood, size: 48, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.fastfood, size: 48, color: Colors.grey),
              ),
            ),
            
            // Info del producto
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      producto.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "\$${NumberFormat('#,###').format(producto.price)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarritoItem(Product producto, int cantidad) {
    final subtotal = producto.price * cantidad;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    producto.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.red),
                  onPressed: () {
                    setState(() => _carrito.remove(producto.id));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Controles de cantidad
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removerDelCarrito(producto.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppTheme.primary,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "$cantidad",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _agregarAlCarrito(producto),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppTheme.primary,
                    ),
                  ],
                ),
                
                // Subtotal
                Text(
                  "\$${NumberFormat('#,###').format(subtotal)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoPagoButton(String metodo, String label, IconData icon) {
    final isSelected = _metodoPago == metodo;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _metodoPago = metodo;
          if (metodo != 'efectivo') {
            _montoPagado = _calcularTotal();
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primary : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTecladoNumerico() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Monto:", style: TextStyle(fontSize: 18)),
                Text(
                  _inputTeclado.isEmpty ? "\$0" : "\$$_inputTeclado",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Teclado
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              '7', '8', '9',
              '4', '5', '6',
              '1', '2', '3',
              'C', '0', '⌫',
            ].map((tecla) => _buildTecla(tecla)).toList(),
          ),
          const SizedBox(height: 8),
          
          // Botón OK
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _onTeclaPresionada('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTecla(String tecla) {
    return ElevatedButton(
      onPressed: () => _onTeclaPresionada(tecla),
      style: ElevatedButton.styleFrom(
        backgroundColor: tecla == 'C' ? Colors.red : Colors.white,
        foregroundColor: tecla == 'C' ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        tecla,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
