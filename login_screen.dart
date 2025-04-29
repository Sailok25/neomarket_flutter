import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseConnection _dbConnection = DatabaseConnection();

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        var result = await _dbConnection.executeQuery(
          'SELECT nombre, contrasena FROM nm_usuarios WHERE email = :email',
          {'email': email},
        );

        if (result?.rows.isNotEmpty == true) {
          var row = result!.rows.first.assoc();
          var name = row['nombre'];
          var hashedPassword = row['contrasena'];

          if (hashedPassword != null && BCrypt.checkpw(password, hashedPassword)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Login correcto! Bienvenido, $name")),
            );
            Navigator.pushNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Correo o contraseña incorrectos.")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Correo o contraseña incorrectos.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 72, color: Colors.deepPurple),
              SizedBox(height: 24),
              Text(
                'Bienvenido',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}