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
  int _totalMediaPages = 1; // Track total number of pages in media carousel
  Set<int> _seenOrderIds = {}; // Track orders we've already seen
  final PageController _pedidosPageController = PageController();
  final PageController _mediaPageController = PageController();

  @override
  void initState() {
    super.initState();
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
      if (mediaUrls.isNotEmpty && _mediaPageController.hasClients && _totalMediaPages > 0) {
        // Loop back to first page when reaching the end
        final nextPage = (_currentMediaIndex + 1) % _totalMediaPages;
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
        // Filter orders to show only those from the last 3 hours
        final now = DateTime.now();
        final filteredData = data.where((pedido) {
          try {
            final createdAt = DateTime.parse(pedido['created_at'] ?? '');
            final difference = now.difference(createdAt);
            return difference.inHours <= 3;
          } catch (e) {
            // If there's an error parsing the date, include the order
            return true;
          }
        }).toList();

        // Check if new orders arrived (for alert/sound)
        // Find orders that we haven't seen before
        final currentOrderIds = filteredData.map((p) => p['order_id'] as int).toSet();
        final newOrderIds = currentOrderIds.difference(_seenOrderIds);
        
        if (newOrderIds.isNotEmpty && _seenOrderIds.isNotEmpty) {
          // Show alert for each new order
          for (final orderId in newOrderIds) {
            _mostrarAlertaNuevoPedido(orderId);
          }
        }

        setState(() {
          _previousPedidosCount = filteredData.length;
          pedidos = filteredData;
          _seenOrderIds = currentOrderIds;
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

  void _mostrarAlertaNuevoPedido(int orderId) async {
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
                        '¡PEDIDO LISTO!',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pedido #$orderId',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to login choice page
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        title: const Text(
          'Pedidos Listos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      )
          : Column(
        children: [
          // Orders Carousel (40% of screen)
          Expanded(
            flex: 40,
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

          // Media Carousel (60% of screen)
          Expanded(
            flex: 60,
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
      padding: const EdgeInsets.all(30),
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
          // Header with status badge - Optimized for visibility without scroll
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 45),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PEDIDO LISTO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Pedido #${pedido["order_id"]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Customer info - Optimized for visibility without scroll
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 40, color: Colors.blue),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    "${pedido["cliente_nombre"] ?? 'Cliente'}",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Page indicator - Optimized size
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
                    boxShadow: _currentPedidoIndex == index
                        ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 6,
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

    // Build responsive grid showing 3 products at a time (or less on smaller screens)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade100, Colors.pink.shade50],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine number of columns based on screen width
          int crossAxisCount = 3; // Default for large screens
          if (constraints.maxWidth < 600) {
            crossAxisCount = 1; // Mobile
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 2; // Tablet
          }

          // Calculate and store total pages for proper looping
          final totalPages = (mediaUrls.length / crossAxisCount).ceil();
          if (_totalMediaPages != totalPages) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _totalMediaPages = totalPages;
                });
              }
            });
          }

          return PageView.builder(
            controller: _mediaPageController,
            onPageChanged: (index) {
              setState(() {
                _currentMediaIndex = index;
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * crossAxisCount;
              final endIndex = (startIndex + crossAxisCount).clamp(0, mediaUrls.length);
              final pageItems = mediaUrls.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Page indicator at top
                    if (mediaUrls.length > crossAxisCount)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (mediaUrls.length / crossAxisCount).ceil(),
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: pageIndex == i ? 50 : 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: pageIndex == i
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: pageIndex == i
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
                    // Grid of products
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: pageItems.length,
                        itemBuilder: (context, index) {
                          final globalIndex = startIndex + index;
                          return _buildProductCard(pageItems[index], globalIndex);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(String url, int index) {
    // Get product info if available
    Product? producto;
    if (index < productos.length) {
      producto = productos[index];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              child: Image.network(
                url,
                fit: BoxFit.cover,
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
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Product name and price
            if (producto != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade50,
                      Colors.pink.shade50,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${producto.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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