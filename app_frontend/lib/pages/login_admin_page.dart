import 'package:flutter/material.dart';
import '../api_service.dart';

class LoginAdminPage extends StatefulWidget {
  const LoginAdminPage({super.key});

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.loginAdmin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result["success"] == true) {
        final role = result["role"] ?? "user";

        if (mounted) {
          switch (role) {
            case "admin":
              Navigator.pushReplacementNamed(
                context,
                '/location',
                arguments: {"role": "admin"},
              );
              break;
            case "cajero":
              Navigator.pushReplacementNamed(
                context,
                '/cajero',
                arguments: {"role": "cajero"},
              );
              break;
            case "cocinero":
              Navigator.pushReplacementNamed(
                context,
                '/cocinero',
                arguments: {"role": "cocinero"},
              );
              break;
            case "domiciliario":
              Navigator.pushReplacementNamed(
                context,
                '/domiciliario',
                arguments: {"role": "domiciliario"},
              );
              break;
            default:
              setState(() {
                _errorMessage = "Rol desconocido: $role";
              });
          }
        }
      } else {
        setState(() {
          _errorMessage = "Usuario o contraseña incorrectos";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error al conectar con el servidor: $e";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login para Administradores",
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
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 100,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Usuario",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese usuario" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese contraseña" : null,
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _login,
                    child: const Text("Ingresar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
