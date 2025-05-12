import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  List<Map<String, dynamic>> _favoriteProducts = [];
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map) {
      userId = args['userId'] as int?;
      print('User ID received: $userId'); // Debug print
      if (userId != null) {
        _fetchFavoriteProducts();
      } else {
        print('User ID is null'); // Debug print
      }
    } else {
      print('No arguments received'); // Debug print
    }
  }

  Future<void> _fetchFavoriteProducts() async {
    try {
      print('Fetching favorite products for user ID: $userId'); // Debug print
      var result = await _dbConnection.executeQuery(
        '''
        SELECT p.*
        FROM nm_productos p
        JOIN nm_favoritos f ON p.id_producto = f.id_producto
        WHERE f.id_usuario = :userId
        ''',
        {'userId': userId},
      );
      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          _favoriteProducts = result.rows.map((row) => row.assoc()).toList();
          print('Favorite products fetched: ${_favoriteProducts.length}'); // Debug print
        });
      } else {
        print('No favorite products found'); // Debug print
      }
    } catch (e) {
      print('Error fetching favorite products: $e'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building FavoritesScreen with ${_favoriteProducts.length} products'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: _favoriteProducts.isEmpty
          ? Center(child: Text('No tienes productos favoritos.'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = _favoriteProducts[index];
                print('Building product card for: ${product['nombre']}'); // Debug print
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/productDetail',
                        arguments: [product, userId],
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product['imagenes'] != null)
                          Image.network(
                            product['imagenes'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['nombre'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${product['precio']}€',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Marca: ${product['marca']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
