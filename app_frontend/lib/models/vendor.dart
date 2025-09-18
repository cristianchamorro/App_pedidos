class Vendor {
  final int id;
  final String name;

  // Constructor
  Vendor({required this.id, required this.name});

  // Factory constructor desde JSON
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
