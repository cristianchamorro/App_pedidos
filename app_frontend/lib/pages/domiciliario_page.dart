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
  final _estadosCtrl =
  TextEditingController(text: 'pendiente,preparando,listo');

  Map<String, dynamic>? _driver;
  List<Map<String, dynamic>> _activos = [];
  List<Map<String, dynamic>> _historial = [];
  bool _cargando = false;

  String _status = 'available';
  bool _live = false;
  StreamSubscription<Position>? _posSub;

  // Estilos reutilizables
  Color get _primary => Colors.deepPurple;
  ButtonStyle get _btnPrimary => ElevatedButton.styleFrom(
    backgroundColor: _primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
  ButtonStyle get _btnOutlined => OutlinedButton.styleFrom(
    foregroundColor: _primary,
    side: BorderSide(color: _primary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
  InputDecoration _input(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary, width: 1.6),
      ),
    );
  }

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
      final a = await _api.getDriverOrders(id,
          estadosCsv: _estadosCtrl.text.trim());
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
      _snack('Estado actualizado a "$s"');
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _updateLocationOnce() async {
    try {
      final id = _id();
      final ok = await _ensurePerms();
      if (!ok) throw Exception('Permiso de ubicación denegado');
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _api.updateDriverLocation(id, pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _driver = {
        ...?_driver,
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
      _snack('Ubicación actualizada');
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
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 15),
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
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
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
      _snack('Acción "${_accionLabel(action)}" aplicada');
    } catch (e) {
      _snack(e.toString());
    }
  }

  String _accionLabel(String action) {
    switch (action) {
      case 'picked':
        return 'Recogido';
      case 'route':
        return 'En ruta';
      case 'delivered':
        return 'Entregado';
      default:
        return action;
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text(
          'Domiciliario',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.05,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Sección datos del domiciliario
              _SectionCard(
                title: 'Datos del Domiciliario',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _driverIdCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _input(
                              'ID Domiciliario',
                              hint: 'Ej. 1',
                              suffix: IconButton(
                                tooltip: 'Limpiar',
                                onPressed: () => setState(() {
                                  _driverIdCtrl.clear();
                                }),
                                icon: const Icon(Icons.clear),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _cargar,
                          style: _btnPrimary,
                          child: _cargando
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Cargar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (d != null) ...[
                      _InfoRow(
                        left: Text(
                          'Estado: ${d['status'] ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        right: Text('Ubicación: ${_fmtLoc(d['lat'], d['lng'])}'),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        left: Text('Actualizado: ${d['updated_at'] ?? '-'}'),
                        right: Row(
                          children: [
                            DropdownButton<String>(
                              value: _status,
                              underline: const SizedBox.shrink(),
                              items: const [
                                DropdownMenuItem(
                                    value: 'available',
                                    child: Text('available')),
                                DropdownMenuItem(
                                    value: 'busy', child: Text('busy')),
                                DropdownMenuItem(
                                    value: 'offline', child: Text('offline')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _status = v ?? 'available'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _updateStatus,
                              style: _btnOutlined,
                              child: const Text('Actualizar estado'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: _updateLocationOnce,
                            style: _btnOutlined,
                            child: const Text('Actualizar ubicación'),
                          ),
                          const SizedBox(width: 12),
                          Switch.adaptive(
                              value: _live, onChanged: _toggleLive),
                          const Text('Ubicación en vivo'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Sección pedidos activos
              _SectionCard(
                title: 'Pedidos asignados',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _estadosCtrl,
                            decoration: _input(
                              'Estados (coma)',
                              hint: 'pendiente,listo',
                              suffix: IconButton(
                                tooltip: 'Restablecer',
                                onPressed: () => setState(() {
                                  _estadosCtrl.text =
                                  'pendiente,preparando,listo';
                                }),
                                icon: const Icon(Icons.restore),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _cargar,
                          style: _btnOutlined,
                          child: const Text('Recargar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_activos.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No hay pedidos asignados'),
                        ),
                      ),
                    ..._activos.map(
                          (p) => _PedidoCard(
                        pedido: p,
                        onAction: (a) =>
                            _accion(a, (p['order_id'] as num).toInt()),
                        primary: _primary,
                        btnPrimary: _btnPrimary,
                        btnOutlined: _btnOutlined,
                      ),
                    ),
                  ],
                ),
              ),

              // Sección historial
              _SectionCard(
                title: 'Historial',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_historial.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Sin historial reciente'),
                        ),
                      ),
                    ..._historial.map(
                          (p) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _primary.withOpacity(0.1),
                            child: Icon(Icons.receipt_long,
                                color: _primary, size: 20),
                          ),
                          title: Text('#${p['order_id']} - ${p['status']}'),
                          subtitle: Text(
                              '${p['cliente_nombre']}  •  \$${p['total']}  •  ${p['created_at']}'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Flexible(child: left), const SizedBox(width: 12), right],
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({
    required this.pedido,
    required this.onAction,
    required this.primary,
    required this.btnPrimary,
    required this.btnOutlined,
  });

  final Map<String, dynamic> pedido;
  final void Function(String action) onAction;
  final Color primary;
  final ButtonStyle btnPrimary;
  final ButtonStyle btnOutlined;

  @override
  Widget build(BuildContext context) {
    final productos = (pedido['productos'] as List?) ?? [];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primary.withOpacity(0.1),
                child: Icon(Icons.assignment, color: primary, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '#${pedido['order_id']}  •  ${pedido['status']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${pedido['cliente_nombre']}  (${pedido['cliente_telefono']})'),
          Text('${pedido['direccion_entrega']}'),
          Text('Total: \$${pedido['total']}'),
          const SizedBox(height: 8),
          const Text('Productos:'),
          ...productos.map((it) {
            final m = Map<String, dynamic>.from(it);
            return Text(
                '- ${m['cantidad']} x ${m['nombre']}  (\$${m['price']})');
          }),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => onAction('picked'),
                style: btnOutlined,
                child: const Text('Recogido'),
              ),
              OutlinedButton(
                onPressed: () => onAction('route'),
                style: btnOutlined,
                child: const Text('En ruta'),
              ),
              ElevatedButton(
                onPressed: () => onAction('delivered'),
                style: btnPrimary,
                child: const Text('Entregado'),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}