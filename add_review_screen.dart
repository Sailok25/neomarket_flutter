import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class AddReviewScreen extends StatefulWidget {
  final int userId;
  final int productId;

  AddReviewScreen({required this.userId, required this.productId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  String _title = '';
  String _comment = '';

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _dbConnection.executeQuery(
          'INSERT INTO nm_resenas (id_usuario, id_producto, puntuacion, titulo, comentario, fecha_resena) VALUES (:userId, :productId, :rating, :title, :comment, CURDATE())',
          {
            'userId': widget.userId,
            'productId': widget.productId,
            'rating': _rating, // Asegúrate de que _rating sea un int
            'title': _title,
            'comment': _comment,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reseña añadida correctamente')),
        );
        Navigator.pop(context, true); // Indica que se añadió una nueva reseña
      } catch (e) {
        print('Error adding review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir la reseña')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Añadir Reseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Comentario'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un comentario';
                  }
                  return null;
                },
                onSaved: (value) {
                  _comment = value!;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitReview,
                child: Text('Enviar Reseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
