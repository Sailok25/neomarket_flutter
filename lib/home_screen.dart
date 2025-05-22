import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _selectedFilter = 'Todos';
  int? userId; // Variable to store the user ID

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the user ID from the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      // Convert the user ID from a string to an integer
      userId = int.tryParse(args['userId'].toString());
      print('User ID: $userId'); // Print the user ID for verification
    }
  }

  Future<void> _fetchProducts() async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT p.*, m.nombre_marca, m.modelo FROM nm_productos p LEFT JOIN nm_marcas m ON p.marca = m.id_marca',
      );
      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          _products = result.rows.map((row) => row.assoc()).toList();
          _filteredProducts = _products;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Precio':
          _filteredProducts = List.from(_products)
            ..sort((a, b) => a['precio'].compareTo(b['precio']));
          break;
        case 'A-Z':
          _filteredProducts = List.from(_products)
            ..sort((a, b) => a['nombre'].compareTo(b['nombre']));
          break;
        case 'Marca':
          _filteredProducts = List.from(_products)
            ..sort((a, b) => a['marca'].compareTo(b['marca']));
          break;
        case 'Categoría':
          _filteredProducts = List.from(_products)
            ..sort((a, b) => a['categoria'].compareTo(b['categoria']));
          break;
        default:
          _filteredProducts = _products;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          // Display the user ID in the AppBar
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {'userId': userId},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cesta'),
              onTap: () {
                if (userId != null) {
                  Navigator.pushNamed(
                    context,
                    '/cart',
                    arguments: userId, // Asegúrate de pasar el userId aquí
                  );
                } else {
                  // Manejar el caso en el que userId es null, por ejemplo, redirigir a una pantalla de error o mostrar un mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: No se proporcionó un ID de usuario válido.',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Subir producto'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/upload',
                  arguments: {'userId': userId},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favoritos'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/favoritos',
                  arguments: {
                    'userId': userId,
                  }, // Asegúrate de pasar el userId aquí
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificaciones'),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Ayuda'),
              onTap: () {
                Navigator.pushNamed(context, '/help');
              },
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/start',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Botones de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text('Precio'),
                  selected: _selectedFilter == 'Precio',
                  onSelected: (selected) {
                    if (selected) _applyFilter('Precio');
                  },
                ),
                FilterChip(
                  label: Text('A-Z'),
                  selected: _selectedFilter == 'A-Z',
                  onSelected: (selected) {
                    if (selected) _applyFilter('A-Z');
                  },
                ),
                FilterChip(
                  label: Text('Marca'),
                  selected: _selectedFilter == 'Marca',
                  onSelected: (selected) {
                    if (selected) _applyFilter('Marca');
                  },
                ),
                FilterChip(
                  label: Text('Categoría'),
                  selected: _selectedFilter == 'Categoría',
                  onSelected: (selected) {
                    if (selected) _applyFilter('Categoría');
                  },
                ),
              ],
            ),
          ),
          // Productos en formato de tarjetas
          Expanded(
            child:
                _filteredProducts.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio:
                            0.7, // Ajusta este valor según sea necesario
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
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
                                      loadingBuilder: (
                                        BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stackTrace,
                                      ) {
                                        return Icon(
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
                                      // Marca
                                      Text(
                                        'Marca: ${product['nombre_marca']}',
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      // Categoría
                                      Text(
                                        'Categoría: ${product['categoria']}',
                                        style: TextStyle(fontSize: 14),
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
    );
  }
}
