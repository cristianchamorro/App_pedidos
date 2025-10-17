import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../api_service.dart';
import '../models/product.dart';

class LocationScreen extends StatefulWidget {
  final String role;
  const LocationScreen({Key? key, required this.role}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _address = "Ubicación no capturada";
  LatLng? _selectedLocation;
  bool _locationConfirmed = false;
  bool _loading = false;
  double? _locationAccuracy;
  String _selectedMethod = "none"; // none, gps, map, manual, search

  final TextEditingController _manualAddressController =
      TextEditingController();
  final TextEditingController _searchAddressController =
      TextEditingController();
  
  // Store recent addresses (max 3, session-only storage)
  final List<String> _recentAddresses = [];
  static const int _maxRecentAddresses = 3;
  static const int _minSearchLength = 3;

  bool get _isMobileOrDesktop =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS);

  bool get _isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    // Don't auto-capture location, let user choose method
    if (_isWeb) {
      _address = "Selecciona un método para capturar tu ubicación";
    } else {
      _address = "Selecciona un método para capturar tu ubicación";
    }
  }
  
  @override
  void dispose() {
    _manualAddressController.dispose();
    _searchAddressController.dispose();
    super.dispose();
  }
  
  /// Helper method to format coordinates as a string
  String _formatCoordinates(double lat, double lng) {
    return "Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}";
  }
  
  /// Helper method to add address to recent addresses list
  void _addToRecentAddresses(String address) {
    if (!_recentAddresses.contains(address)) {
      _recentAddresses.insert(0, address);
      if (_recentAddresses.length > _maxRecentAddresses) {
        _recentAddresses.removeLast();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _selectedMethod = "gps";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _address = "Servicios de ubicación deshabilitados.";
        _loading = false;
        _selectedMethod = "none";
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
          _selectedMethod = "none";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _address = "Permiso de ubicación denegado permanentemente.";
        _loading = false;
        _selectedMethod = "none";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _locationAccuracy = position.accuracy;

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        if (placemarks.isNotEmpty) {
          var place = placemarks.first;
          _address =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        } else {
          _address = _formatCoordinates(position.latitude, position.longitude);
        }
        _locationConfirmed = true;
        _loading = false;
        
        // Add to recent addresses
        _addToRecentAddresses(_address);
      });
    } catch (e) {
      setState(() {
        _address = "Error obteniendo ubicación: $e";
        _loading = false;
        _selectedMethod = "none";
      });
    }
  }

  Future<void> _openMapModal() async {
    if (_isWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El mapa no está disponible en versión Web")),
      );
      return;
    }

    LatLng initialPosition =
        _selectedLocation ?? const LatLng(4.710989, -74.072090); // Bogotá
    
    LatLng? pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.infinity,
          height: 500,
          child: Stack(
            children: [
              GoogleMap(
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
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    '📍 Toca en el mapa para seleccionar tu ubicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _loading = true;
        _selectedMethod = "map";
      });
      
      _selectedLocation = pickedLocation;
      
      try {
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
            _address = _formatCoordinates(pickedLocation.latitude, pickedLocation.longitude);
          }
          _locationConfirmed = true;
          _loading = false;
          
          // Add to recent addresses
          _addToRecentAddresses(_address);
        });
      } catch (e) {
        setState(() {
          _address = "Error obteniendo dirección: $e";
          _loading = false;
        });
      }
    }
  }

  void _useManualAddress() {
    if (_manualAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa una dirección")),
      );
      return;
    }

    setState(() {
      _address = _manualAddressController.text.trim();
      _selectedLocation = null;
      _locationConfirmed = true;
      _selectedMethod = "manual";
      _locationAccuracy = null;
      
      // Add to recent addresses
      _addToRecentAddresses(_address);
    });
  }
  
  Future<void> _searchAddress() async {
    String searchQuery = _searchAddressController.text.trim();
    
    // Validate minimum search length
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa una dirección para buscar")),
      );
      return;
    }
    
    if (searchQuery.length < _minSearchLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("La dirección debe tener al menos $_minSearchLength caracteres")),
      );
      return;
    }

    setState(() {
      _loading = true;
      _selectedMethod = "search";
    });

    try {
      List<Location> locations = await locationFromAddress(searchQuery);

      if (locations.isNotEmpty) {
        Location loc = locations.first;
        _selectedLocation = LatLng(loc.latitude, loc.longitude);

        // Get the full address from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );

        setState(() {
          if (placemarks.isNotEmpty) {
            var place = placemarks.first;
            _address =
                "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
          } else {
            _address = searchQuery;
          }
          _locationConfirmed = true;
          _loading = false;
          
          // Add to recent addresses
          _addToRecentAddresses(_address);
        });
      } else {
        setState(() {
          _address = "No se encontró la dirección";
          _loading = false;
          _selectedMethod = "none";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se encontró la dirección. Intenta con más detalles."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _address = "Error al buscar la dirección";
        _loading = false;
        _selectedMethod = "none";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo buscar la dirección. Verifica tu conexión."),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _useRecentAddress(String address) {
    setState(() {
      _address = address;
      _locationConfirmed = true;
      _selectedMethod = "recent";
      _selectedLocation = null;
      _locationAccuracy = null;
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
        title: const Text(
          "Captura tu ubicación",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade100,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _locationConfirmed 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _locationConfirmed 
                                ? Icons.check_circle
                                : Icons.location_on,
                            color: _locationConfirmed 
                                ? Colors.green
                                : Colors.orange,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _locationConfirmed 
                                    ? "Ubicación capturada"
                                    : "Sin ubicación",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _locationConfirmed 
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_locationAccuracy != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Precisión: ${_locationAccuracy!.toStringAsFixed(0)}m',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_selectedMethod != "none") ...[
                      const SizedBox(height: 8),
                      Text(
                        'Método: ${_getMethodName()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Location Methods Section
            const Text(
              'Selecciona un método de captura:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // GPS Location Button (only for mobile/desktop)
            if (_isMobileOrDesktop)
              _buildLocationMethodCard(
                icon: Icons.gps_fixed,
                title: 'Ubicación GPS',
                subtitle: 'Usa tu ubicación actual',
                color: Colors.blue,
                onTap: _getCurrentLocation,
              ),
            
            if (_isMobileOrDesktop)
              const SizedBox(height: 12),
            
            // Map Picker Button (only for mobile/desktop)
            if (_isMobileOrDesktop)
              _buildLocationMethodCard(
                icon: Icons.map,
                title: 'Seleccionar en mapa',
                subtitle: 'Elige tu ubicación en el mapa',
                color: Colors.green,
                onTap: _openMapModal,
              ),
            
            if (_isMobileOrDesktop)
              const SizedBox(height: 12),
            
            // Search Address Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.purple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buscar dirección',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Busca tu dirección por nombre',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchAddressController,
                      decoration: InputDecoration(
                        hintText: "Ej: Calle 100 Bogotá",
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _searchAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text(
                          'Buscar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Manual Address Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_location,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Escribir dirección',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ingresa tu dirección manualmente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _manualAddressController,
                      decoration: InputDecoration(
                        hintText: "Ej: Carrera 7 #100-20",
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _useManualAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Usar esta dirección',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Recent Addresses
            if (_recentAddresses.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Direcciones recientes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ..._recentAddresses.map((address) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    address,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () => _useRecentAddress(address),
                ),
              )).toList(),
            ],
            
            const SizedBox(height: 24),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _locationConfirmed && !_loading 
                    ? _continueToProducts 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  elevation: _locationConfirmed ? 5 : 0,
                  shadowColor: Colors.deepPurple.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Continuar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: _locationConfirmed 
                                ? Colors.white 
                                : Colors.grey.shade600,
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLocationMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getMethodName() {
    switch (_selectedMethod) {
      case "gps":
        return "GPS";
      case "map":
        return "Mapa";
      case "manual":
        return "Manual";
      case "search":
        return "Búsqueda";
      case "recent":
        return "Reciente";
      default:
        return "Ninguno";
    }
  }
}
