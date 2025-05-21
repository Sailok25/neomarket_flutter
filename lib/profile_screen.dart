import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userProducts = [];
  int favoritesCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the user ID from the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      int? userId = args['userId'] as int?;
      if (userId != null) {
        _fetchUserData(userId);
        _fetchUserProducts(userId);
        _fetchFavoritesCount(userId);
      }
    }
  }

  Future<void> _fetchUserData(int userId) async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT nombre, apellido, email FROM nm_usuarios WHERE id_usuario = :userId',
        {'userId': userId},
      );

      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          userData = result.rows.first.assoc();
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _fetchUserProducts(int userId) async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT p.*, m.nombre_marca, m.modelo FROM nm_productos p LEFT JOIN nm_marcas m ON p.marca = m.id_marca WHERE p.id_vendedor = :userId',
        {'userId': userId},
      );

      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          userProducts = result.rows.map((row) => row.assoc()).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching user products: $e');
    }
  }

  Future<void> _fetchFavoritesCount(int userId) async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT COUNT(*) as count FROM nm_favoritos WHERE id_usuario = :userId',
        {'userId': userId},
      );

      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          favoritesCount = int.parse(
            result.rows.first.assoc()['count'].toString(),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching favorites count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image and Name
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData != null
                        ? '${userData!['nombre']} ${userData!['apellido']}'
                        : 'Nombre Usuario',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData != null ? userData!['email'] : 'user@example.com',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(userProducts.length.toString(), 'Productos'),
                _buildStatColumn('0/0', 'Valoraciones'),
                _buildStatColumn(favoritesCount.toString(), 'Guardados'),
              ],
            ),

            const SizedBox(height: 20),

            // User Products
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.6, // Ajusta la altura según sea necesario
              child:
                  userProducts.isEmpty
                      ? const Center(
                        child: Text("Aún no has subido ningún producto"),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: userProducts.length,
                        itemBuilder: (context, index) {
                          final product = userProducts[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                // Navegar a la pantalla de detalles del producto
                                Navigator.pushNamed(
                                  context,
                                  '/productDetail',
                                  arguments: [product, userData?['id_usuario']],
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
                                        loadingBuilder: (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder: (
                                          BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.error,
                                          ); // Muestra un icono de error si la imagen no se puede cargar
                                        },
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Nombre del producto
                                        Text(
                                          product['nombre'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Precio
                                        Text(
                                          '${product['precio']}€',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Marca
                                        Text(
                                          'Marca: ${product['nombre_marca'] ?? 'Sin marca'}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Categoría
                                        Text(
                                          'Categoría: ${product['categoria'] ?? 'Sin categoría'}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
