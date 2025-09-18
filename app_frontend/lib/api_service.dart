import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'models/product.dart';
import 'models/categoria.dart';
import 'models/vendor.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    if (kIsWeb) {
      baseUrl = "http://localhost:3000";
    } else if (Platform.isAndroid) {
      baseUrl = "http://10.0.2.2:3000";
    } else if (Platform.isIOS) {
      baseUrl = "http://localhost:3000";
    } else {
      baseUrl = "http://localhost:3000";
    }
  }

  // ===============================
  // Obtener productos
  // ===============================
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  // ===============================
  // Agregar producto desde Product
  // ===============================
  Future<void> addProduct(Product producto) async {
    try {
      final url = Uri.parse('$baseUrl/productos');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(producto.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(
            "Error al agregar producto: ${response.statusCode} -> ${error['error'] ?? 'Desconocido'}");
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

  // ===============================
  // Agregar producto desde Map (recomendado)
  // ===============================
  Future<void> addProductFromMap(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/productos');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String msg = 'Desconocido';
        try {
          final error = jsonDecode(response.body);
          msg = error['error'] ?? msg;
        } catch (_) {}
        throw Exception(
            "Error al agregar producto: ${response.statusCode} -> $msg");
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

  // ===============================
  // Obtener categorías
  // ===============================
  Future<List<Categoria>> fetchCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categorias'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((cat) => Categoria.fromJson(cat)).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }
  
// ===============================
// Actualizar producto
// ===============================
Future<void> updateProduct(Product producto) async {
  try {
    final url = Uri.parse('$baseUrl/productos/${producto.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(
          "Error al actualizar producto: ${response.statusCode} -> ${error['error'] ?? 'Desconocido'}");
    }
  } catch (e) {
    throw Exception("No se pudo conectar al backend: $e");
  }
}

  // ===============================
  // Obtener vendors
  // ===============================
  Future<List<Vendor>> fetchVendors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vendors'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((v) => Vendor.fromJson(v)).toList();
      } else {
        throw Exception('Error al cargar vendors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }
}
