import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Placemark de stub para todas las plataformas.
/// Retorna datos vacíos para Windows/Web.
class Placemark {
  final String street;
  final String locality;
  final String administrativeArea;

  Placemark({this.street = '', this.locality = '', this.administrativeArea = ''});
}

/// Función simulada para geocoding.
/// Siempre retorna un Placemark vacío.
Future<List<Placemark>> placemarkFromCoordinates(double latitude, double longitude) async {
  return [Placemark()];
}
