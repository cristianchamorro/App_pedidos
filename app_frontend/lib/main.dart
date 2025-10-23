import 'package:flutter/material.dart';
import 'package:app_pedidos/screens/location_screen.dart';
import 'package:app_pedidos/pages/productos_por_categoria_page.dart';
import 'package:app_pedidos/models/product.dart';
import 'package:app_pedidos/pages/login_choice_page.dart';
import 'package:app_pedidos/pages/login_admin_page.dart';
import 'pages/pedidos_cocinero_page.dart';
import 'package:app_pedidos/pages/pedidos_cajero_page.dart';
import 'package:app_pedidos/pages/domiciliario_page.dart';
import 'package:app_pedidos/pages/pedidos_listos_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Pedidos',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginChoicePage(), // ✅ pantalla inicial unificada
      routes: {
        '/location': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final role = args['role'] as String;

          return LocationScreen(role: role); // ✅ pasamos el rol
        },
        '/productos': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          final productos = args['productos'] as List<Product>;
          final role = args['role'] as String;
          final direccion = args['direccion'] as String? ?? "Sin dirección";

          return ProductosPorCategoriaPage(
            productos: productos,
            direccionEntrega: direccion,
            role: role, // ✅ ahora sí pasamos el rol
            onAgregarAlPedido: (producto) {
              print("Producto agregado: ${producto.name}");
              print("Pedido a entregar en: $direccion");
            },
          );
        },

        // Rutas para roles administrativos
        '/cajero': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return const PedidosCajeroPage();
        },
        '/cocinero': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return const PedidosCocineroPage();
        },
        '/domiciliario': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return const DomiciliarioPage();
        },
        '/pedidos-listos': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return const PedidosListosPage();
        },
      },
    );
  }
}