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
        SELECT p.*, m.nombre_marca, m.modelo
        FROM nm_productos p
        JOIN nm_favoritos f ON p.id_producto = f.id_producto
        LEFT JOIN nm_marcas m ON p.marca = m.id_marca
        WHERE f.id_usuario = :userId
        ''',
        {'userId': userId},
      );
      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          _favoriteProducts = result.rows.map((row) => row.assoc()).toList();
          print(
            'Favorite products fetched: ${_favoriteProducts.length}',
          ); // Debug print
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
    print(
      'Building FavoritesScreen with ${_favoriteProducts.length} products',
    ); // Debug print
    return Scaffold(
      appBar: AppBar(title: Text('Favoritos')),
      body: _favoriteProducts.isEmpty
          ? Center(child: Text('No tienes productos favoritos.'))
          : GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7, // Ajusta este valor según sea necesario
              ),
              itemCount: _favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = _favoriteProducts[index];
                print(
                  'Building product card for: ${product['nombre']}',
                ); // Debug print
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
                        // Imagen del producto
                        if (product['imagenes'] != null)
                          Container(
                            height: 150, // Altura fija para la imagen
                            width: double.infinity,
                            child: Image.network(
                              product['imagenes'],
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Icon(Icons.error); // Muestra un icono de error si la imagen no se puede cargar
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre del producto
                              Text(
                                product['nombre'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              // Precio
                              Text(
                                '${product['precio']}€',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Marca y Modelo
                              Row(
                                children: [
                                  Icon(Icons.label, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Marca: ${product['nombre_marca']}',
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.model_training, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Modelo: ${product['modelo']}',
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
