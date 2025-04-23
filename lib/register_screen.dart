import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool newsletter = false;
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
              _buildTextField('Nombre'),
              _buildTextField('Apellido'),
              _buildTextField('Descripción'),
              _buildTextField('DNI'),
              _buildTextField('Email', keyboardType: TextInputType.emailAddress),
              _buildTextField('Fecha de nacimiento (YYYY-MM-DD)'),
              _buildTextField('Dirección de envío'),
              _buildTextField('Contraseña', obscureText: true),

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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí iría la lógica de envío al backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Formulario válido')),
                    );
                  }
                },
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
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
