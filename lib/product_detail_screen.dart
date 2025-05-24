import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';
import 'report_screen.dart'; // Asegúrate de importar la pantalla de reporte
import 'add_review_screen.dart'; // Importa la pantalla para agregar reseñas

class ProductDetailScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  Map<String, dynamic>? product;
  int? userId;
  bool isFavorite = false;
  int quantity = 1; // Variable para manejar la cantidad

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as List?;
    if (args != null && args.length >= 2) {
      product = args[0] as Map<String, dynamic>;
      userId = int.tryParse(args[1].toString()); // Conversión a int
      print(
        'Product Data: $product',
      ); // Imprime los datos del producto en la consola
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    if (userId == null || product == null) return;

    try {
      var result = await _dbConnection.executeQuery(
        'SELECT * FROM nm_favoritos WHERE id_usuario = :userId AND id_producto = :productId',
        {'userId': userId, 'productId': product!['id_producto']},
      );
      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          isFavorite = true;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<bool> _checkIfReported() async {
    if (userId == null || product == null) return false;

    try {
      var result = await _dbConnection.executeQuery(
        'SELECT * FROM nm_advertencias WHERE fk_id_producto = :productId AND id_advertencia = :userId',
        {'productId': product!['id_producto'], 'userId': userId},
      );
      return result != null && result.rows.isNotEmpty;
    } catch (e) {
      print('Error checking report status: $e');
      return false;
    }
  }

  Future<bool> _hasUserReviewed() async {
    if (userId == null || product == null) return false;

    try {
      var result = await _dbConnection.executeQuery(
        'SELECT * FROM nm_resenas WHERE id_usuario = :userId AND id_producto = :productId',
        {'userId': userId, 'productId': product!['id_producto']},
      );
      return result != null && result.rows.isNotEmpty;
    } catch (e) {
      print('Error checking if user has reviewed: $e');
      return false;
    }
  }

  Future<void> _toggleFavorite() async {
    if (userId == null || product == null) return;

    try {
      if (isFavorite) {
        await _dbConnection.executeQuery(
          'DELETE FROM nm_favoritos WHERE id_usuario = :userId AND id_producto = :productId',
          {'userId': userId, 'productId': product!['id_producto']},
        );
      } else {
        await _dbConnection.executeQuery(
          'INSERT INTO nm_favoritos (id_usuario, id_producto) VALUES (:userId, :productId)',
          {'userId': userId, 'productId': product!['id_producto']},
        );
      }
      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      print('Error toggling favorite status: $e');
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    if (userId == null || product == null) return;

    try {
      await _dbConnection.executeQuery(
        'INSERT INTO nm_cesta (id_usuario, id_producto, cantidad) VALUES (:userId, :productId, :quantity)',
        {
          'userId': userId,
          'productId': product!['id_producto'],
          'quantity': quantity, // Usar la cantidad seleccionada
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Producto añadido al carrito')));
    } catch (e) {
      print('Error adding product to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el producto al carrito')),
      );
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).pop(); // Cerrar el diálogo al hacer clic en la imagen
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(product!['imagenes'], fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ropa':
        return Icons.checkroom;
      case 'Tecnologia':
        return Icons.phone_android;
      case 'Hogar':
        return Icons.home;
      case 'Deporte':
        return Icons.sports_soccer;
      case 'Automovil':
        return Icons.directions_car;
      case 'Accesorios':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT r.*, u.nombre, u.apellido FROM nm_resenas r JOIN nm_usuarios u ON r.id_usuario = u.id_usuario WHERE r.id_producto = :productId',
        {'productId': product!['id_producto']},
      );
      if (result != null && result.rows.isNotEmpty) {
        return result.rows.map((row) {
          var review = row.assoc();
          // Convertir la puntuación a un tipo numérico y luego a una cadena de texto
          review['puntuacion'] =
              (num.tryParse(review['puntuacion'].toString()) ?? 0).toString();
          return review;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Detalles del Producto')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Producto')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product!['imagenes'] != null)
                GestureDetector(
                  onTap: _showImageDialog,
                  child: Image.network(
                    product!['imagenes'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              SizedBox(height: 16),
              Text(
                product!['nombre'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${product!['precio']}€',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.label,
                    size: 20,
                  ), // Icono de etiqueta para la marca
                  SizedBox(width: 4),
                  Text(
                    'Marca: ${product!['nombre_marca']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.model_training, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Modelo: ${product!['modelo']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(_getCategoryIcon(product!['categoria']), size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Categoría: ${product!['categoria']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Stock disponible: ${product!['unidades']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(product!['descripcion'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  ElevatedButton(
                    onPressed: _addToCart,
                    child: Text('Añadir al carrito'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () async {
                  bool isReported = await _checkIfReported();
                  if (isReported) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ya has reportado este producto')),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/report',
                      arguments: {
                        'userId': userId,
                        'productId': int.parse(
                          product!['id_producto'].toString(),
                        ),
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Denunciar Producto'),
              ),
              SizedBox(height: 16),
              Text(
                'Reseñas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchReviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error al cargar las reseñas');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No hay reseñas aún');
                  } else {
                    return Column(
                      children:
                          snapshot.data!.map((review) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          review['titulo'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Row(
                                          children: List.generate(5, (index) {
                                            int rating =
                                                int.tryParse(
                                                  review['puntuacion']
                                                      .toString(),
                                                ) ??
                                                0;
                                            return Icon(
                                              index < rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(review['comentario']),
                                    SizedBox(height: 4),
                                    Text(
                                      'Fecha: ${review['fecha_resena']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  bool hasReviewed = await _hasUserReviewed();
                  if (hasReviewed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ya has añadido una reseña para este producto',
                        ),
                      ),
                    );
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddReviewScreen(
                              userId: userId!,
                              productId: int.parse(
                                product!['id_producto'].toString(),
                              ),
                            ),
                      ),
                    );
                    if (result == true) {
                      setState(
                        () {},
                      ); // Refrescar la pantalla para mostrar la nueva reseña
                    }
                  }
                },
                child: Text('Añadir Reseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
