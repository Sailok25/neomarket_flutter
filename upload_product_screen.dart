import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neomarket_flutter/conexio.dart';
import 'dart:io';

class UploadProductScreen extends StatefulWidget {
  @override
  _UploadProductScreenState createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseConnection _dbConnection = DatabaseConnection();

  int? userId;
  List<Map<String, dynamic>> _brands = [];
  int? _selectedBrand;
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      var result = await _dbConnection.executeQuery('SELECT id_marca, nombre_marca FROM nm_marcas');
      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          _brands = result.rows.map((row) => row.assoc()).toList();
          print('Brands fetched: $_brands'); // Debug print
        });
      }
    } catch (e) {
      print('Error fetching brands: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      String? imagePath = _image != null ? _image!.path : null;
      print('Submitting form with data:');
      print('User ID: $userId');
      print('Name: ${_nameController.text}');
      print('Description: ${_descriptionController.text}');
      print('Image Path: $imagePath');
      print('Category: $_selectedCategory');
      print('Brand: $_selectedBrand');
      print('Condition: $_selectedCondition');
      print('Price: ${_priceController.text}');
      print('Units: ${_unitsController.text}');

      await _dbConnection.executeQuery(
        'INSERT INTO nm_productos (id_vendedor, nombre, descripcion, imagenes, categoria, marca, estado, estado_anuncio, fecha_publicacion, precio, unidades) VALUES (:id_vendedor, :nombre, :descripcion, :imagenes, :categoria, :marca, :estado, :estado_anuncio, :fecha_publicacion, :precio, :unidades)',
        {
          'id_vendedor': userId,
          'nombre': _nameController.text,
          'descripcion': _descriptionController.text,
          'imagenes': imagePath,
          'categoria': _selectedCategory,
          'marca': _selectedBrand,
          'estado': _selectedCondition,
          'estado_anuncio': 'activo',
          'fecha_publicacion': DateTime.now().toString(),
          'precio': double.parse(_priceController.text),
          'unidades': int.parse(_unitsController.text),
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto subido correctamente')),
      );
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir el producto: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      userId = int.tryParse(args['userId'].toString());
      print('User ID: $userId'); // Debug print
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _unitsController,
                decoration: InputDecoration(labelText: 'Unidades'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa las unidades del producto';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: ['Accesorios', 'Ropa', 'Hogar', 'Deporte', 'Automovil', 'Tecnologia']
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedBrand,
                decoration: InputDecoration(labelText: 'Marca'),
                items: _brands
                    .map((brand) => DropdownMenuItem<int>(
                          value: int.parse(brand['id_marca'].toString()), // Asegúrate de que el valor sea un int
                          child: Text(brand['nombre_marca']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                    print('Selected Brand ID: $value'); // Debug print
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una marca';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: InputDecoration(labelText: 'Estado del Producto'),
                items: ['precintado', 'usado', 'muy usado', 'despiece']
                    .map((condition) => DropdownMenuItem<String>(
                          value: condition,
                          child: Text(condition),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona el estado del producto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              if (_image != null) Image.file(_image!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Subir Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
