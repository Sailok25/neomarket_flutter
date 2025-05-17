import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

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
      userId = args[1] as int?;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product!['imagenes'] != null)
              Image.network(
                product!['imagenes'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
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
            Text(
  'Marca: ${product!['nombre_marca']} ${product!['modelo'] ?? ''}',
  style: TextStyle(fontSize: 16),
),

            SizedBox(height: 8),
            Text(
              'Categoría: ${product!['categoria']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(product!['descripcion'], style: TextStyle(fontSize: 16)),
            Spacer(),
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
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
