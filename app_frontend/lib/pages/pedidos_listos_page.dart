import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import '../models/product.dart';

class PedidosListosPage extends StatefulWidget {
  const PedidosListosPage({super.key});

  @override
  State<PedidosListosPage> createState() => _PedidosListosPageState();
}

class _PedidosListosPageState extends State<PedidosListosPage> {
  final ApiService api = ApiService();
  List<Map<String, dynamic>> pedidos = [];
  List<Product> productos = [];
  List<String> mediaUrls = []; // URLs for images/videos
  bool isLoading = true;
  Timer? _refreshTimer;
  Timer? _pedidosCarouselTimer;
  Timer? _mediaCarouselTimer;
  int _currentPedidoIndex = 0;
  int _currentMediaIndex = 0;
  int _previousPedidosCount = 0;
  final PageController _pedidosPageController = PageController();
  final PageController _mediaPageController = PageController();

  @override
  void initState() {
    super.initState();
    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _cargarDatos();

    // Refresh orders every 5 seconds to detect new ready orders
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _cargarPedidos();
    });

    // Auto-advance pedidos carousel every 7 seconds
    _pedidosCarouselTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (pedidos.isNotEmpty && _pedidosPageController.hasClients) {
        final nextPage = (_currentPedidoIndex + 1) % pedidos.length;
        _pedidosPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });

    // Auto-advance media carousel every 5 seconds
    _mediaCarouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mediaUrls.isNotEmpty && _mediaPageController.hasClients) {
        final nextPage = (_currentMediaIndex + 1) % mediaUrls.length;
        _mediaPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No navigation arguments needed - this is a standalone screen
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pedidosCarouselTimer?.cancel();
    _mediaCarouselTimer?.cancel();
    _pedidosPageController.dispose();
    _mediaPageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarPedidos(),
      _cargarMediaUrls(),
    ]);
  }

  Future<void> _cargarPedidos() async {
    try {
      final data = await api.obtenerPedidosPorEstado("listo");
      if (mounted) {
        // Check if new orders arrived (for alert/sound)
        if (data.length > _previousPedidosCount && _previousPedidosCount > 0) {
          _mostrarAlertaNuevoPedido();
        }
        
        setState(() {
          _previousPedidosCount = pedidos.length;
          pedidos = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _cargarMediaUrls() async {
    try {
      // Load products and use their images as media URLs
      final data = await api.fetchProducts();
      if (mounted) {
        // Extract image URLs from products and shuffle
        final urls = data
            .where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty)
            .map((p) => p.imageUrl!)
            .toList();
        urls.shuffle(Random());
        
        // If no product images, use placeholder URLs
        if (urls.isEmpty) {
          urls.addAll([
            'https://via.placeholder.com/800x600?text=Producto+1',
            'https://via.placeholder.com/800x600?text=Producto+2',
            'https://via.placeholder.com/800x600?text=Producto+3',
          ]);
        }
        
        setState(() {
          mediaUrls = urls;
          productos = data;
        });
      }
    } catch (e) {
      print('Error al cargar media URLs: $e');
      // Use fallback URLs
      if (mounted) {
        setState(() {
          mediaUrls = [
            'https://via.placeholder.com/800x600?text=Bienvenido',
            'https://via.placeholder.com/800x600?text=Productos',
          ];
        });
      }
    }
  }

  void _mostrarAlertaNuevoPedido() {
    // Show visual alert
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.notification_important, color: Colors.white),
              SizedBox(width: 12),
              Text(
                '¡Nuevo pedido listo!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Play system sound
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : Column(
              children: [
                // Orders Carousel (top half)
                Expanded(
                  flex: 1,
                  child: _buildPedidosCarousel(),
                ),
                
                // Media Carousel (bottom half)
                Expanded(
                  flex: 1,
                  child: _buildMediaCarousel(),
                ),
              ],
            ),
    );
  }

  Widget _buildPedidosCarousel() {
    if (pedidos.isEmpty) {
      return Container(
        color: Colors.green[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'No hay pedidos listos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Los pedidos aparecerán aquí cuando estén preparados',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.green[50],
      child: PageView.builder(
        controller: _pedidosPageController,
        onPageChanged: (index) {
          setState(() {
            _currentPedidoIndex = index;
          });
        },
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          return _buildPedidoCard(pedidos[index]);
        },
      ),
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido) {
    final productos = (pedido["productos"] as List?) ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade100, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header with status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 40),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PEDIDO LISTO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Pedido #${pedido["order_id"]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Customer info
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 32, color: Colors.blue),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "${pedido["cliente_nombre"] ?? 'Cliente'}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 32, color: Colors.blue),
                    const SizedBox(width: 15),
                    Text(
                      "${pedido["cliente_telefono"] ?? '-'}",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Products
          if (productos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200, width: 3),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.restaurant_menu, size: 32, color: Colors.orange),
                      SizedBox(width: 15),
                      Text(
                        'Productos:',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...productos.take(3).map((prod) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${prod["cantidad"]}x",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              "${prod["nombre"]}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (productos.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '+ ${productos.length - 3} más...',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          
          const Spacer(),
          
          // Page indicator
          if (pedidos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pedidos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPedidoIndex == index ? 40 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _currentPedidoIndex == index
                        ? Colors.green
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel() {
    if (mediaUrls.isEmpty) {
      return Container(
        color: Colors.purple[50],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      color: Colors.purple[50],
      child: PageView.builder(
        controller: _mediaPageController,
        onPageChanged: (index) {
          setState(() {
            _currentMediaIndex = index;
          });
        },
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return _buildMediaCard(mediaUrls[index], index);
        },
      ),
    );
  }

  Widget _buildMediaCard(String url, int index) {
    // Get product info if available
    Product? producto;
    if (index < productos.length) {
      producto = productos[index];
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade100, Colors.pink.shade50],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Media image
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRoundedRectangle(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 20),
                          if (producto != null)
                            Text(
                              producto.name,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Product info overlay
          if (producto != null)
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(
                    producto.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (producto.description != null && producto.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        producto.description!,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.deepPurple],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      '\$${producto.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Page indicator
          if (mediaUrls.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  mediaUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentMediaIndex == index ? 40 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _currentMediaIndex == index
                          ? Colors.purple
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ClipRoundedRectangle extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRoundedRectangle({
    Key? key,
    required this.child,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}
