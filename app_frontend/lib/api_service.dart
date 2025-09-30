import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'models/categoria.dart';
import 'models/product.dart';
import 'models/vendor.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    if (kIsWeb) {
      baseUrl = "http://localhost:3000";
    } else if (Platform.isAndroid) {
      baseUrl = "http://192.168.101.2:3000";
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
      final url = Uri.parse('$baseUrl/admin/products');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(producto.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(
            "Error al agregar producto: ${response
                .statusCode} -> ${error['error'] ?? 'Desconocido'}");
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

  // ===============================
  // Agregar producto desde Map
  // ===============================
  Future<void> addProductFromMap(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/admin/products');
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
  // Actualizar producto
  // ===============================
  Future<void> updateProduct(Product producto) async {
    try {
      final url = Uri.parse('$baseUrl/admin/products/${producto.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(producto.toJson()),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(
            "Error al actualizar producto: ${response
                .statusCode} -> ${error['error'] ?? 'Desconocido'}");
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
      final response = await http.get(Uri.parse('$baseUrl/admin/categories'));
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
// Obtener vendors
// ===============================
  Future<List<Vendor>> fetchVendors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/vendors'));
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

// ===============================
// Obtener pedidos pendientes
// ===============================
  Future<List<Map<String, dynamic>>> fetchPedidosPendientes() async {
    final url = Uri.parse('$baseUrl/pedidos?estado=pendiente');
    final response = await http.get(
        url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['pedidos']);
      } else {
        throw Exception('Error al obtener pedidos pendientes');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

// ===============================
// Obtener changed_by de un pedido
// ===============================
  Future<String?> fetchChangedBy(int orderId) async {
    try {
      final url = Uri.parse('$baseUrl/pedidos/$orderId/changed-by');
      final response = await http.get(
          url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Aseguramos que exista el campo
        if (data.containsKey("changed_by")) {
          return data["changed_by"].toString();
        } else {
          return null;
        }
      } else {
        throw Exception('Error al obtener changed_by: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

// ===============================
// Obtener detalle de un pedido
// ===============================
  Future<Map<String, dynamic>> fetchDetallePedido(int orderId) async {
    final url = Uri.parse('$baseUrl/pedidos/$orderId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['pedido']);
      } else {
        throw Exception('Error al obtener detalle del pedido');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

// ===============================
// Marcar pedido como procesado
// ===============================
  Future<bool> procesarPedido(int orderId) async {
    final url = Uri.parse('$baseUrl/pedidos/$orderId/procesar');
    final response = await http.put(
        url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Error al procesar pedido: ${response.statusCode}');
    }
  }

  // ===============================
  // 🔑 Login de administrador
  // ===============================
  Future<Map<String, dynamic>> loginAdmin(String username,
      String password) async {
    try {
      final url = Uri.parse('$baseUrl/loginAdmin');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": data["success"] == true,
          "role": data["role"] ?? "user", // 👈 default user
          "userId": data["userId"] ?? 0
        };
      } else {
        return {"success": false, "role": "user", "userId": 0};
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }
}
