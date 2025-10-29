import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../api_service.dart';
import '../models/product.dart';

class PedidosListosPage extends StatefulWidget {
  const PedidosListosPage({super.key});

  @override
  State<PedidosListosPage> createState() => _PedidosListosPageState();
}

class _PedidosListosPageState extends State<PedidosListosPage> {
  final ApiService api = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> pedidos = [];
  List<Product> productos = [];
  List<String> mediaUrls = []; // URLs for images/videos
  bool isLoading = true;
  bool _showingAlert = false;
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
    _audioPlayer.dispose();
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
        // Filter products with images
        final productsWithImages = data
            .where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty)
            .toList();
        
        // Shuffle the products themselves (not just URLs)
        productsWithImages.shuffle(Random());
        
        // If no product images, use placeholder URLs
        if (productsWithImages.isEmpty) {
          setState(() {
            mediaUrls = [
              'https://via.placeholder.com/800x600?text=Producto+1',
              'https://via.placeholder.com/800x600?text=Producto+2',
              'https://via.placeholder.com/800x600?text=Producto+3',
            ];
            productos = [];
          });
        } else {
          setState(() {
            productos = productsWithImages;
            mediaUrls = productsWithImages.map((p) => p.imageUrl!).toList();
          });
        }
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
          productos = [];
        });
      }
    }
  }

  void _mostrarAlertaNuevoPedido() async {
    if (!mounted || _showingAlert) return;
    
    setState(() {
      _showingAlert = true;
    });
    
    // Play notification sound
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Fallback to system sound if custom sound fails
      SystemSound.play(SystemSoundType.alert);
    }
    
    // Show prominent visual alert overlay
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (context) => Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(60),
                  margin: const EdgeInsets.symmetric(horizontal: 80),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        size: 120,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        '¡NUEVO PEDIDO LISTO!',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Por favor, acérquese a recoger su pedido',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      
      // Auto-dismiss after 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _showingAlert = false;
        });
      }
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
                
                // Visual separator between sections
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade300,
                        Colors.purple.shade300,
                      ],
                    ),
                  ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade100, Colors.green.shade50],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 150,
                color: Colors.green.shade300,
              ),
              const SizedBox(height: 40),
              Text(
                'No hay pedidos listos',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  'Los pedidos aparecerán aquí cuando estén preparados',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(50),
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
          // Header with status badge - Larger for TV
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 60),
                const SizedBox(width: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PEDIDO LISTO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      'Pedido #${pedido["order_id"]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Customer info - Larger for TV visibility
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 48, color: Colors.blue),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    "${pedido["cliente_nombre"] ?? 'Cliente'}",
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Page indicator - Larger for TV
          if (pedidos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pedidos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: _currentPedidoIndex == index ? 50 : 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: _currentPedidoIndex == index
                        ? Colors.green
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _currentPedidoIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
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
      child: Stack(
        children: [
          // Large product image - takes almost full screen
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRoundedRectangle(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey.shade300, Colors.grey.shade200],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 150,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 30),
                            if (producto != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  producto.name,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Product name overlay at bottom
          if (producto != null)
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  producto.name,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          
          // Page indicator at top
          if (mediaUrls.length > 1)
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  mediaUrls.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: _currentMediaIndex == i ? 50 : 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: _currentMediaIndex == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _currentMediaIndex == i
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
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
