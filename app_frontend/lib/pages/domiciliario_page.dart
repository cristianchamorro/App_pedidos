import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api_service.dart';

class DomiciliarioPage extends StatefulWidget {
  const DomiciliarioPage({super.key});

  @override
  State<DomiciliarioPage> createState() => _DomiciliarioPageState();
}

class _DomiciliarioPageState extends State<DomiciliarioPage> {
  final _api = ApiService();
  final _driverIdCtrl = TextEditingController(text: '');
  final _estadosCtrl = TextEditingController(text: 'pendiente,preparando,listo');

  Map<String, dynamic>? _driver;
  List<Map<String, dynamic>> _activos = [];
  List<Map<String, dynamic>> _historial = [];
  bool _cargando = false;

  String _status = 'available';
  bool _live = false;
  StreamSubscription<Position>? _posSub;

  @override
  void dispose() {
    _posSub?.cancel();
    _driverIdCtrl.dispose();
    _estadosCtrl.dispose();
    super.dispose();
  }

  int _id() {
    final id = int.tryParse(_driverIdCtrl.text.trim());
    if (id == null || id <= 0) {
      throw Exception('Ingrese un ID válido');
    }
    return id;
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final id = _id();
      final d = await _api.getDriver(id);
      final a = await _api.getDriverOrders(id, estadosCsv: _estadosCtrl.text.trim());
      final h = await _api.getDriverOrdersHistory(id);
      setState(() {
        _driver = d;
        _status = (d['status'] ?? 'available').toString();
        _activos = a;
        _historial = h;
      });
    } catch (e) {
      _snack(e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _updateStatus() async {
    try {
      final id = _id();
      final s = await _api.updateDriverStatus(id, _status);
      setState(() => _driver = {...?_driver, 'status': s});
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _updateLocationOnce() async {
    try {
      final id = _id();
      final ok = await _ensurePerms();
      if (!ok) throw Exception('Permiso de ubicación denegado');
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _api.updateDriverLocation(id, pos.latitude, pos.longitude);
      setState(() => _driver = {
        ...?_driver,
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _toggleLive(bool on) async {
    setState(() => _live = on);
    _posSub?.cancel();
    if (!on) return;
    try {
      final id = _id();
      final ok = await _ensurePerms();
      if (!ok) throw Exception('Permiso de ubicación denegado');
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15),
      ).listen((pos) async {
        try {
          await _api.updateDriverLocation(id, pos.latitude, pos.longitude);
          if (!mounted) return;
          setState(() => _driver = {
            ...?_driver,
            'lat': pos.latitude,
            'lng': pos.longitude,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      }, onError: (err) {
        _snack('Ubicación en vivo falló: $err');
        setState(() => _live = false);
        _posSub?.cancel();
      });
    } catch (e) {
      _snack(e.toString());
      setState(() => _live = false);
    }
  }

  Future<bool> _ensurePerms() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> _accion(String action, int orderId) async {
    try {
      final id = _id();
      if (action == 'picked') await _api.driverPickedUp(id, orderId);
      if (action == 'route') await _api.driverOnRoute(id, orderId);
      if (action == 'delivered') await _api.driverDelivered(id, orderId);
      await _cargar();
    } catch (e) {
      _snack(e.toString());
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _fmtLoc(dynamic lat, dynamic lng) {
    if (lat == null || lng == null) return '-';
    final la = (lat as num).toDouble();
    final ln = (lng as num).toDouble();
    return '${la.toStringAsFixed(5)}, ${ln.toStringAsFixed(5)}';
    }

  @override
  Widget build(BuildContext context) {
    final d = _driver;
    return Scaffold(
      appBar: AppBar(title: const Text('Domiciliario')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _driverIdCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ID Domiciliario', hintText: 'Ej. 1'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _cargar,
                          child: _cargando
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Cargar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (d != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estado: ${d['status'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Ubicación: ${_fmtLoc(d['lat'], d['lng'])}'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Actualizado: ${d['updated_at'] ?? '-'}'),
                          Row(
                            children: [
                              DropdownButton<String>(
                                value: _status,
                                items: const [
                                  DropdownMenuItem(value: 'available', child: Text('available')),
                                  DropdownMenuItem(value: 'busy', child: Text('busy')),
                                  DropdownMenuItem(value: 'offline', child: Text('offline')),
                                ],
                                onChanged: (v) => setState(() => _status = v ?? 'available'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(onPressed: _updateStatus, child: const Text('Actualizar estado')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton(onPressed: _updateLocationOnce, child: const Text('Actualizar ubicación')),
                          const SizedBox(width: 12),
                          Switch(value: _live, onChanged: _toggleLive),
                          const Text('Ubicación en vivo'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pedidos asignados', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _estadosCtrl,
                          decoration: const InputDecoration(labelText: 'Estados (coma)', hintText: 'pendiente,listo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: _cargar, child: const Text('Recargar')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._activos.map((p) => _PedidoCard(
                    pedido: p,
                    onAction: (a) => _accion(a, (p['order_id'] as num).toInt()),
                  )),
                ]),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._historial.map((p) => ListTile(
                    title: Text('#${p['order_id']} - ${p['status']}'),
                    subtitle: Text('${p['cliente_nombre']}  •  \$${p['total']}  •  ${p['created_at']}'),
                  )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({required this.pedido, required this.onAction});

  final Map<String, dynamic> pedido;
  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    final productos = (pedido['productos'] as List?) ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${pedido['order_id']}  •  ${pedido['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${pedido['cliente_nombre']}  (${pedido['cliente_telefono']})'),
          Text('${pedido['direccion_entrega']}'),
          Text('Total: \$${pedido['total']}'),
          const SizedBox(height: 6),
          const Text('Productos:'),
          ...productos.map((it) {
            final m = Map<String, dynamic>.from(it);
            return Text('- ${m['cantidad']} x ${m['nombre']}  (\$${m['price']})');
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(onPressed: () => onAction('picked'), child: const Text('Recogido')),
              const SizedBox(width: 6),
              OutlinedButton(onPressed: () => onAction('route'), child: const Text('En ruta')),
              const SizedBox(width: 6),
              ElevatedButton(onPressed: () => onAction('delivered'), child: const Text('Entregado')),
            ],
          ),
        ]),
      ),
    );
  }
}