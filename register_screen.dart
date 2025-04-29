import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:neomarket_flutter/conexio.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool newsletter = false;
  File? _image;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DatabaseConnection _dbConnection = DatabaseConnection();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final hashedPassword = BCrypt.hashpw(passwordController.text, BCrypt.gensalt());

        var result = await _dbConnection.executeQuery(
          '''
          INSERT INTO nm_usuarios (nombre, apellido, descripcion, dni, email, fecha_nacimiento, direccion_envio, contrasena, newsletter)
          VALUES (:name, :lastName, :description, :dni, :email, :birthDate, :address, :password, :newsletter)
          ''',
          {
            'name': nameController.text,
            'lastName': lastNameController.text,
            'description': descriptionController.text,
            'dni': dniController.text,
            'email': emailController.text,
            'birthDate': birthDateController.text,
            'address': addressController.text,
            'password': hashedPassword,
            'newsletter': newsletter ? 1 : 0,
          },
        );

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro exitoso')),
          );
          Navigator.pushNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar. Inténtalo de nuevo.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Imagen de perfil
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.add_a_photo, size: 40) : null,
                ),
              ),
              SizedBox(height: 16),

              // Campos de texto
              _buildTextField('Nombre', nameController),
              _buildTextField('Apellido', lastNameController),
              _buildTextField('Descripción', descriptionController),
              _buildTextField('DNI', dniController),
              _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField('Fecha de nacimiento (YYYY-MM-DD)', birthDateController),
              _buildTextField('Dirección de envío', addressController),
              _buildTextField('Contraseña', passwordController, obscureText: true),

              // Newsletter
              CheckboxListTile(
                title: Text('Suscribirse al newsletter'),
                value: newsletter,
                onChanged: (bool? value) {
                  setState(() {
                    newsletter = value ?? false;
                  });
                },
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _register,
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
  }
}
