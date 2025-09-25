class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final String? categoryName;
  final int vendorId;
  final String? vendorName;
  final String? driverName; // <-- nuevo campo

  int cantidad;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    required this.vendorId,
    this.vendorName,
    this.driverName, // <-- incluimos en el constructor
    this.cantidad = 1,
  });
  
  
  void resetCantidad() {   
    cantidad = 1; // o 0, según prefieras mostrar   // 🔴 Método para resetear cantidad
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] is String) {
      parsedPrice = double.tryParse(json['price']) ?? 0.0;
    } else if (json['price'] is int) {
      parsedPrice = (json['price'] as int).toDouble();
    } else if (json['price'] is double) {
      parsedPrice = json['price'];
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: parsedPrice,
      imageUrl: json['image_url'] ?? json['imageUrl'],
      categoryId: json['category_id'] ?? json['categoryId'] ?? 0,
      categoryName: json['category_name'] ?? json['categoryName'],
      vendorId: json['vendor_id'] ?? json['vendorId'] ?? 0,
      vendorName: json['vendor_name'] ?? json['vendorName'],
      driverName: json['driver_name'] ?? json['driverName'], // <-- se lee del JSON si viene
      cantidad: json['cantidad'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'driver_name': driverName, // <-- incluimos
      'cantidad': cantidad,
    };
  }
}
