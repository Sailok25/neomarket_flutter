import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:neomarket_flutter/conexio.dart';

class UploadProductScreen extends StatefulWidget {
  @override
  _UploadProductScreenState createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCondition;
  DateTime? _publicationDate;

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

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        var result = await _dbConnection.executeQuery(
          '''
          INSERT INTO nm_productos (id_vendedor, nombre, descripcion, imagenes, categoria, marca, estado, fecha_publicacion, precio, unidades)
          VALUES (:id_vendedor, :name, :description, :image, :category, :brand, :condition, :publicationDate, :price, :units)
          ''',
          {
            'id_vendedor': 1, // Aquí deberías obtener el ID del vendedor actual
            'name': nameController.text,
            'description': descriptionController.text,
            'image': _image?.path, // Guardar la ruta de la imagen
            'category': _selectedCategory,
            'brand': brandController.text,
            'condition': _selectedCondition,
            'publicationDate': _publicationDate?.toIso8601String(),
            'price': priceController.text,
            'units': unitsController.text,
          },
        );

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto subido exitosamente')),
          );
          Navigator.pop(context); // Volver a la pantalla anterior
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir el producto. Inténtalo de nuevo.')),
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
      appBar: AppBar(title: Text('Subir Producto')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Imagen del producto
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 40)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),

              // Campos de texto
              _buildTextField('Nombre del producto', nameController),
              _buildTextField('Descripción', descriptionController),
              _buildTextField('Precio', priceController, keyboardType: TextInputType.number),
              _buildTextField('Marca', brandController),
              _buildTextField('Unidades', unitsController, keyboardType: TextInputType.number),

              // Categoría
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoría'),
                value: _selectedCategory,
                items: [
                  'Accesorios',
                  'Ropa',
                  'Hogar',
                  'Deporte',
                  'Automovil',
                  'Tecnologia'
                ].map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una categoría' : null,
              ),

              // Estado del producto
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Estado del producto'),
                value: _selectedCondition,
                items: [
                  'precintado',
                  'usado',
                  'muy usado',
                  'despiece'
                ].map((condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona un estado' : null,
              ),

              // Fecha de publicación
              TextFormField(
                decoration: InputDecoration(labelText: 'Fecha de publicación (YYYY-MM-DD)'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _publicationDate = pickedDate;
                    });
                  }
                },
                validator: (value) => _publicationDate == null ? 'Selecciona una fecha' : null,
                readOnly: true,
                controller: TextEditingController(
                  text: _publicationDate == null ? '' : _publicationDate!.toIso8601String().split('T')[0],
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _uploadProduct,
                child: Text('Subir Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
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
