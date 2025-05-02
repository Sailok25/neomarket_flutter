import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 0;
  bool isFavorite = false;

  void addToCart() {
    // Lógica para añadir al carrito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Producto añadido al carrito')),
    );
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    // Lógica para guardar en favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isFavorite ? 'Producto añadido a favoritos' : 'Producto eliminado de favoritos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            if (product['imagenes'] != null)
              Image.network(
                product['imagenes'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    product['nombre'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Marca del producto
                  Text(
                    product['marca'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Precio
                  Row(
                    children: [
                      Text(
                        '${product['precio']}€',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      // Botones de cantidad
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                          Text('$quantity'),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (quantity > 0) quantity--;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Calificación
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '${product['calificacion']} (${product['numero_reviews']} Reviews)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Descripción
                  Text(
                    product['descripcion'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Botones de añadir al carrito y guardar a favoritos
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: Text('Añadir al carrito'),
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                        onPressed: toggleFavorite,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Sección de comentarios
                  Text(
                    'Reseñas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Lista de comentarios (simulada)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: product['comentarios']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final comment = product['comentarios'][index];
                      return ListTile(
                        title: Text(comment['usuario']),
                        subtitle: Text(comment['texto']),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
