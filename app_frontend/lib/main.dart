import 'package:flutter/material.dart';
import 'package:app_pedidos/screens/location_screen.dart';
import 'package:app_pedidos/pages/productos_por_categoria_page.dart';
import 'package:app_pedidos/models/product.dart';
import 'package:app_pedidos/api_service.dart';

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
      home: const LocationScreen(),
      routes: {
        '/productos': (context) {
          // Recuperamos los productos pasados como argumento
          final args =
              ModalRoute.of(context)!.settings.arguments as List<Product>;

          // Creamos ProductosPorCategoriaPage pasando todos los parámetros obligatorios
          return ProductosPorCategoriaPage(
            productos: args,
            direccionEntrega: "Sin dirección", // Valor temporal
            onAgregarAlPedido: (producto) {
              // Aquí luego implementarás la lógica real de agregar al pedido
              print("Producto agregado: ${producto.name}");
            },
          );
        },
      },
    );
  }
}
