import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/categoria.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../api_service.dart';

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({Key? key}) : super(key: key);

  @override
  _AgregarProductoPageState createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _buscarController = TextEditingController();

  bool _loading = false;

  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;

  List<Vendor> _vendors = [];
  Vendor? _vendorSeleccionado;

  List<Product> _todosProductos = [];
  List<Product> _resultadosBusqueda = [];
  Product? _productoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarVendors();
    _cargarTodosProductos();
  }

  Future<void> _cargarCategorias() async {
    try {
      final apiService = ApiService();
      final categorias = await apiService.fetchCategorias();
      setState(() {
        _categorias = categorias;
        if (_categorias.isNotEmpty) _categoriaSeleccionada = _categorias.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando categorías: $e')),
      );
    }
  }

  Future<void> _cargarVendors() async {
    try {
      final apiService = ApiService();
      final vendors = await apiService.fetchVendors();
      setState(() {
        _vendors = vendors;
        if (_vendors.isNotEmpty) _vendorSeleccionado = _vendors.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando vendors: $e')),
      );
    }
  }

  Future<void> _cargarTodosProductos() async {
    try {
      final api = ApiService();
      final productos = await api.fetchProducts();
      setState(() {
        _todosProductos = productos;
        _resultadosBusqueda = productos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando productos: $e')),
      );
    }
  }

  void _buscarProducto(String query) {
    final resultados = _todosProductos
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _resultadosBusqueda = resultados;
    });
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate() ||
        _categoriaSeleccionada == null ||
        _vendorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos obligatorios')),
      );
      return;
    }

    setState(() => _loading = true);

    final double precio = double.tryParse(_priceController.text) ?? 0.0;
    final int categoriaId = _categoriaSeleccionada!.id;
    final int vendorId = _vendorSeleccionado!.id;

    if (precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un precio válido')),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      final apiService = ApiService();

      if (_productoSeleccionado != null) {
        // Actualizar producto existente
        final updatedProduct = Product(
          id: _productoSeleccionado!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: precio,
          imageUrl: _imageUrlController.text.trim(),
          categoryId: categoriaId,
          vendorId: vendorId,
        );
        await apiService.updateProduct(updatedProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado correctamente')),
        );
      } else {
        // Agregar nuevo producto
        final Map<String, dynamic> data = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': precio,
          'imageUrl': _imageUrlController.text.trim(),
          'categoryId': categoriaId,
          'vendorId': vendorId,
        };
        await apiService.addProductFromMap(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto agregado correctamente')),
        );
      }

      // Limpiar formulario
      _formKey.currentState!.reset();
      setState(() {
        _categoriaSeleccionada = _categorias.isNotEmpty ? _categorias.first : null;
        _vendorSeleccionado = _vendors.isNotEmpty ? _vendors.first : null;
        _productoSeleccionado = null;
        _buscarController.clear();
        _resultadosBusqueda = _todosProductos;
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administrar Productos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
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
          children: [
            // =================== BUSCADOR ===================
            TextField(
              controller: _buscarController,
              decoration: const InputDecoration(
                labelText: 'Buscar producto existente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _buscarProducto,
            ),
            const SizedBox(height: 16),

            if (_resultadosBusqueda.isNotEmpty && _buscarController.text.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _resultadosBusqueda.length,
                itemBuilder: (context, index) {
                  final p = _resultadosBusqueda[index];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text("\$${p.price.toStringAsFixed(2)}"),
                    onTap: () {
                      setState(() {
                        _productoSeleccionado = p;
                        _nameController.text = p.name;
                        _descriptionController.text = p.description ?? '';
                        _priceController.text = p.price.toString();
                        _imageUrlController.text = p.imageUrl ?? '';
                        _categoriaSeleccionada = _categorias.firstWhere(
                            (c) => c.id == p.categoryId,
                            orElse: () => _categorias.first);
                        _vendorSeleccionado = _vendors.firstWhere(
                            (v) => v.id == p.vendorId,
                            orElse: () => _vendors.first);
                      });
                    },
                  );
                },
              ),

            const SizedBox(height: 16),
            // =================== FORMULARIO ===================
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la descripción' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el precio' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'URL Imagen'),
                  ),
                  const SizedBox(height: 16),
                  _categorias.isEmpty
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<Categoria>(
                          value: _categoriaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          items: _categorias
                              .map((cat) => DropdownMenuItem<Categoria>(
                                    value: cat,
                                    child: Text(cat.name),
                                  ))
                              .toList(),
                          onChanged: (cat) {
                            setState(() {
                              _categoriaSeleccionada = cat;
                            });
                          },
                        ),
                  const SizedBox(height: 16),
                  _vendors.isEmpty
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<Vendor>(
                          value: _vendorSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Establecimiento',
                            border: OutlineInputBorder(),
                          ),
                          items: _vendors
                              .map((v) => DropdownMenuItem<Vendor>(
                                    value: v,
                                    child: Text(v.name),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _vendorSeleccionado = v;
                            });
                          },
                        ),
                  const SizedBox(height: 20),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _guardarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: Text(
                              _productoSeleccionado != null ? 'Actualizar Producto' : 'Agregar Producto'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
