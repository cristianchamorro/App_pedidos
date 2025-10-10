import 'package:flutter/material.dart';
import 'package:app_pedidos/screens/location_screen.dart';
import 'package:app_pedidos/pages/productos_por_categoria_page.dart';
import 'package:app_pedidos/models/product.dart';
import 'package:app_pedidos/pages/login_admin_page.dart';
import 'pages/pedidos_cocinero_page.dart';
// 🔹 Importamos
import 'package:app_pedidos/pages/pedidos_cajero_page.dart';
import 'package:app_pedidos/pages/pedidos_domiciliario_page.dart';


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
      home: const RoleSelectionScreen(), // ✅ pantalla inicial
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

        // 🔹 Rutas nuevas para roles
        '/cajero': (context) => const PedidosCajeroPage(),
        '/cocinero': (context) => const PedidosCocineroPage(),
        '/domiciliario': (context) => const PedidosDomiciliarioPage(),
      },
    );
  }
}

/// Pantalla inicial para seleccionar rol
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar Rol"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/location',
                  arguments: {'role': 'user'},
                );
              },
              child: const Text("Ingresar como Usuario"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ✅ Ahora primero abre el login de administrador
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginAdminPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Ingresar como Administrador"),
            ),
          ],
        ),
      ),
    );
  }
}
