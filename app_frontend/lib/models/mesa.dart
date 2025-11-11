class Mesa {
  final int id;
  final String nombre;
  final int capacidad;
  String estado; // libre, ocupada, reservada, porpagar
  int? orderId;
  double? total;
  
  Mesa({
    required this.id,
    required this.nombre,
    required this.capacidad,
    this.estado = 'libre',
    this.orderId,
    this.total,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      capacidad: json['capacidad'] as int,
      estado: json['estado'] as String? ?? 'libre',
      orderId: json['order_id'] as int?,
      total: json['total'] != null ? double.parse(json['total'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'capacidad': capacidad,
      'estado': estado,
      'order_id': orderId,
      'total': total,
    };
  }
}
