import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class AddReviewScreen extends StatefulWidget {
  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  int? productId;
  int? userId;
  int rating = 0;
  String comment = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      productId = args['productId'] as int?;
      userId = args['userId'] as int?;
    }
  }

  Future<void> _submitReview() async {
    if (productId == null || userId == null) return;

    try {
      await _dbConnection.executeQuery(
        'INSERT INTO nm_resenas (id_usuario, id_producto, puntuacion, comentario, fecha_resena) VALUES (:userId, :productId, :rating, :comment, CURRENT_DATE)',
        {
          'userId': userId,
          'productId': productId,
          'rating': rating,
          'comment': comment,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reseña añadida con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir la reseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Añadir Reseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valoración',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            Text(
              'Comentario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  comment = value;
                });
              },
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe tu comentario aquí',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Enviar Reseña'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
