import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'models/categoria.dart';
import 'models/product.dart';
import 'models/vendor.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    // Load backend URL from .env file
    final envUrl = dotenv.env['BACKEND_URL'];
    
    if (envUrl != null && envUrl.isNotEmpty) {
      // Validate the URL format
      final uri = Uri.tryParse(envUrl);
      if (uri != null && uri.hasScheme && uri.hasAuthority) {
        // Use the URL from .env file if valid
        baseUrl = envUrl;
        if (kDebugMode) {
          print('Backend URL loaded from .env: $baseUrl');
        }
      } else {
        // Invalid URL format, use default
        if (kDebugMode) {
          print('Warning: Invalid BACKEND_URL format in .env: $envUrl. Using default.');
        }
        baseUrl = _getDefaultUrl();
      }
    } else {
      // No URL in .env, use default
      baseUrl = _getDefaultUrl();
    }
  }

  // Helper method to get default URL based on platform
  String _getDefaultUrl() {
    if (kIsWeb) {
      return "http://localhost:3000";
    } else if (Platform.isAndroid) {
      return "http://192.168.101.6:3000";
    } else if (Platform.isIOS) {
      return "http://localhost:3000";
    } else {
      return "http://localhost:3000";
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
            "Error al agregar producto: ${response.statusCode} -> ${error['error'] ?? 'Desconocido'}");
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
        throw Exception("Error al agregar producto: ${response.statusCode} -> $msg");
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
            "Error al actualizar producto: ${response.statusCode} -> ${error['error'] ?? 'Desconocido'}");
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
    final response = await http.get(url, headers: {"Content-Type": "application/json"});

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
      final response = await http.get(url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
  // Confirmar pago de un pedido y cambiar estado a 'preparando'
  // ===============================
  Future<bool> confirmarPago(int orderId, double efectivo, {int? changedBy}) async {
    final url = Uri.parse('$baseUrl/pedidos/$orderId/pago');
    final body = {
      "efectivo": efectivo,
      if (changedBy != null) "changed_by": changedBy,
    };
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Error al confirmar pago: ${response.statusCode}');
    }
  }

  // ===============================
  // Obtener pedidos en preparación
  // ===============================
  Future<List<Map<String, dynamic>>> fetchPedidosEnPreparacion() async {
    final url = Uri.parse('$baseUrl/pedidos?estado=pagado');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['pedidos']);
      } else {
        throw Exception('Error al obtener pedidos en preparación');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  // ===============================
  // Obtener pedidos por estado
  // ===============================
  Future<List<Map<String, dynamic>>> obtenerPedidosPorEstado(String estado) async {
    final url = Uri.parse('$baseUrl/pedidos?estado=$estado');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['pedidos']);
      } else {
        throw Exception('Error al obtener pedidos con estado $estado');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  // ===============================
  // Marcar pedido como listo en cocina
  // ===============================
  Future<bool> marcarListoCocina(int orderId, {int? changedBy}) async {
    final url = Uri.parse('$baseUrl/pedidos/$orderId/listo'); // 👈 Ojo aquí
    final body = <String, dynamic>{};
    if (changedBy != null) {
      body["changed_by"] = changedBy;
    }
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Error al marcar pedido listo en cocina: ${response.statusCode}');
    }
  }

  // ===============================
  // Marcar pedido como procesado
  // ===============================
  Future<bool> procesarPedido(int orderId) async {
    final url = Uri.parse('$baseUrl/pedidos/$orderId/procesar');
    final response = await http.put(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Error al procesar pedido: ${response.statusCode}');
    }
  }

  // ===============================
  // 🔐 Login de administrador
  // ===============================
  Future<Map<String, dynamic>> loginAdmin(String username, String password) async {
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

  // ===============================
  // 🔹 Domiciliarios (Drivers)
  // ===============================

  Future<Map<String, dynamic>> getDriver(int driverId) async {
    final res = await http.get(Uri.parse('$baseUrl/drivers/$driverId'));
    final data = _decode(res);
    return Map<String, dynamic>.from(data['driver'] ?? {});
  }

  Future<String> updateDriverStatus(int driverId, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/drivers/$driverId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    final data = _decode(res);
    return (data['driver']?['status'] ?? status).toString();
  }

  Future<void> updateDriverLocation(int driverId, double lat, double lng) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/drivers/$driverId/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'lat': lat, 'lng': lng}),
    );
    _decode(res);
  }

  Future<List<Map<String, dynamic>>> getDriverOrders(int driverId, {String? estadosCsv}) async {
    final uri = Uri.parse('$baseUrl/drivers/$driverId/orders').replace(queryParameters: {
      if (estadosCsv != null && estadosCsv.trim().isNotEmpty) 'estados': estadosCsv
    });
    final res = await http.get(uri);
    final data = _decode(res);
    return List<Map<String, dynamic>>.from(data['pedidos'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getDriverOrdersHistory(int driverId) async {
    final res = await http.get(Uri.parse('$baseUrl/drivers/$driverId/orders/history'));
    final data = _decode(res);
    return List<Map<String, dynamic>>.from(data['pedidos'] ?? []);
  }

  Future<void> driverPickedUp(int driverId, int orderId) async {
    final res = await http.post(Uri.parse('$baseUrl/drivers/$driverId/orders/$orderId/picked-up'));
    _decode(res);
  }

  Future<void> driverOnRoute(int driverId, int orderId) async {
    final res = await http.post(Uri.parse('$baseUrl/drivers/$driverId/orders/$orderId/on-route'));
    _decode(res);
  }

  Future<void> driverDelivered(int driverId, int orderId) async {
    final res = await http.post(Uri.parse('$baseUrl/drivers/$driverId/orders/$orderId/delivered'));
    _decode(res);
  }

  // -------- helper interno --------
  dynamic _decode(http.Response r) {
    final txt = r.body;
    dynamic data;
    try {
      data = txt.isNotEmpty ? json.decode(txt) : {};
    } catch (_) {
      data = {'raw': txt};
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception(data is Map && data['error'] != null ? data['error'] : 'HTTP ${r.statusCode}');
    }
    return data;
  }

  // ===============================
  // 🔹 Cajero - Reportes y Estadísticas
  // ===============================

  /// Obtener ventas del día actual
  Future<Map<String, dynamic>> obtenerVentasDelDia() async {
    try {
      final url = Uri.parse('$baseUrl/cajero/ventas/dia');
      final response = await http.get(url, headers: {"Content-Type": "application/json"});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data);
        } else {
          throw Exception('Error al obtener ventas del día');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

  /// Obtener reporte de ventas por rango de fechas
  Future<Map<String, dynamic>> obtenerReporteVentas(String fechaInicio, String fechaFin) async {
    try {
      final url = Uri.parse('$baseUrl/cajero/ventas/reporte?fecha_inicio=$fechaInicio&fecha_fin=$fechaFin');
      final response = await http.get(url, headers: {"Content-Type": "application/json"});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data);
        } else {
          throw Exception('Error al obtener reporte de ventas');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

  /// Obtener historial de pagos
  Future<Map<String, dynamic>> obtenerHistorialPagos({int limit = 50, int offset = 0}) async {
    try {
      final url = Uri.parse('$baseUrl/cajero/pagos/historial?limit=$limit&offset=$offset');
      final response = await http.get(url, headers: {"Content-Type": "application/json"});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data);
        } else {
          throw Exception('Error al obtener historial de pagos');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }

  /// Obtener estadísticas de caja
  Future<Map<String, dynamic>> obtenerEstadisticasCaja() async {
    try {
      final url = Uri.parse('$baseUrl/cajero/estadisticas');
      final response = await http.get(url, headers: {"Content-Type": "application/json"});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data);
        } else {
          throw Exception('Error al obtener estadísticas de caja');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("No se pudo conectar al backend: $e");
    }
  }
}