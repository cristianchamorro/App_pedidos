import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../api_service.dart';
import '../models/product.dart';
import '../pages/productos_por_categoria_page.dart';

class LocationScreen extends StatefulWidget {
  final String role; // 👈 ahora usamos String para el rol
  const LocationScreen({Key? key, required this.role}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _address = "Ubicación no capturada";
  LatLng? _selectedLocation;
  bool _locationConfirmed = false;
  bool _loading = false;

  final TextEditingController _manualAddressController =
      TextEditingController();

  bool get _isMobileOrWeb =>
      Platform.isAndroid || Platform.isIOS || kIsWeb || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    if (_isMobileOrWeb) {
      _getCurrentLocation();
    } else {
      // Windows / Linux → deshabilitamos ubicación
      _address = "Selecciona en el mapa o escribe tu dirección.";
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _address = "Servicios de ubicación deshabilitados.";
        _loading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _address = "Permiso de ubicación denegado.";
          _loading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _address = "Permiso de ubicación denegado permanentemente.";
        _loading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _selectedLocation = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        if (placemarks.isNotEmpty) {
          var place = placemarks.first;
          _address =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        } else {
          _address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
        }
        _locationConfirmed = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _address = "Error obteniendo ubicación: $e";
        _loading = false;
      });
    }
  }

  Future<void> _openMapModal() async {
    LatLng initialPosition =
        _selectedLocation ?? const LatLng(4.710989, -74.072090); // Bogotá
    LatLng? pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.infinity,
          height: 400,
          child: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: initialPosition, zoom: 15),
            onTap: (latlng) {
              Navigator.pop(context, latlng);
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    )
                  }
                : {},
          ),
        ),
      ),
    );

    if (pickedLocation != null) {
      _selectedLocation = pickedLocation;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pickedLocation.latitude,
        pickedLocation.longitude,
      );

      setState(() {
        if (placemarks.isNotEmpty) {
          var place = placemarks.first;
          _address =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        } else {
          _address =
              "Lat: ${pickedLocation.latitude}, Lng: ${pickedLocation.longitude}";
        }
        _locationConfirmed = true;
      });
    }
  }

  void _useManualAddress() {
    if (_manualAddressController.text.trim().isEmpty) return;

    setState(() {
      _address = _manualAddressController.text.trim();
      _selectedLocation = null;
      _locationConfirmed = true;
    });
  }

  Future<void> _continueToProducts() async {
    if (!_locationConfirmed) return;

    setState(() {
      _loading = true;
    });

    try {
      final apiService = ApiService();
      List<Product> productos = await apiService.fetchProducts();

      // ✅ Ahora pasamos el rol como String
      Navigator.pushNamed(
        context,
        '/productos',
        arguments: {
          'productos': productos,
          'role': widget.role,
          'direccion': _address,
        },
      );
    } catch (e) {
      setState(() {
        _address = "Error cargando productos: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text("Captura de ubicación"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _address,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _locationConfirmed
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 40)
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isMobileOrWeb ? _getCurrentLocation : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            child: const Text("Usar mi ubicación actual"),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _isMobileOrWeb ? _openMapModal : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            child: const Text("Seleccionar en el mapa"),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _manualAddressController,
                            decoration: const InputDecoration(
                              labelText: "Escribe dirección o coordenadas",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _useManualAddress,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            child: const Text("Usar dirección escrita"),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                _locationConfirmed ? _continueToProducts : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            child: const Text("Continuar"),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
