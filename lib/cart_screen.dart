import 'package:flutter/material.dart';
import 'conexio.dart'; // Asegúrate de importar tu clase de conexión a la base de datos

class CartScreen extends StatefulWidget {
  final int userId; // Añadir userId como parámetro

  CartScreen({required this.userId}); // Constructor para recibir el userId

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  TextEditingController _promoCodeController = TextEditingController();
  double subtotal = 0.0;
  double iva = 0.0;
  double total = 0.0;
  double discount = 0.0; // Inicializa el descuento en 0.0
  bool isPromoCodeValid = false;
  final DatabaseConnection _dbConnection = DatabaseConnection();
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      print('User ID: ${widget.userId}'); // Imprimir el userId para verificar
      var result = await _dbConnection.executeQuery(
        '''
        SELECT p.*, SUM(c.cantidad) as cantidad
        FROM nm_productos p
        JOIN nm_cesta c ON p.id_producto = c.id_producto
        WHERE c.id_usuario = :userId
        GROUP BY p.id_producto
        ''',
        {'userId': widget.userId}, // Usar el userId del widget
      );
      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          _cartItems = result.rows.map((row) => row.assoc()).toList();
          _calculateSubtotal();
        });
      } else {
        print('No se encontraron productos en la cesta para el usuario actual.');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  void _calculateSubtotal() {
    subtotal = _cartItems.fold(0, (sum, item) {
      double precio = double.tryParse(item['precio'].toString()) ?? 0.0;
      int cantidad = int.tryParse(item['cantidad'].toString()) ?? 0;
      return sum + (precio * cantidad);
    });
    _updateTotal();
  }

  Future<void> _verifyPromoCode() async {
    final String promoCode = _promoCodeController.text;
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT * FROM nm_codigos WHERE codigo = :codigo AND estado = "activo"',
        {'codigo': promoCode}, // Asegúrate de pasar los parámetros como un mapa
      );

      if (result != null && result.rows.isNotEmpty) {
        // Convertir el valor de String a double
        var discountValue = result.rows.first.assoc()['valor_descuento'];
        setState(() {
          discount = double.tryParse(discountValue.toString()) ?? 0.0;
          isPromoCodeValid = true;
          _updateTotal();
        });
      } else {
        setState(() {
          isPromoCodeValid = false;
          discount = 0.0; // Asegúrate de que el descuento se establece en 0.0 si no es válido
          _updateTotal();
        });
      }
    } catch (e) {
      print('Error verifying promo code: $e');
    }
  }

  void _updateTotal() {
    iva = subtotal * 0.21;
    total = subtotal + iva - discount; // Aplicar el descuento una sola vez al total
  }

  Future<void> _removeItemFromCart(int productId) async {
    try {
      await _dbConnection.executeQuery(
        'DELETE FROM nm_cesta WHERE id_producto = :productId AND id_usuario = :userId',
        {
          'productId': productId, // Asegúrate de que productId es un entero
          'userId': widget.userId,
        },
      );
      _fetchCartItems(); // Refresh the cart items after deletion
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrito')),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Text('Aún no has añadido productos a tu cesta'),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return ListTile(
                        leading: item['imagenes'] != null
                            ? Image.network(
                                item['imagenes'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(width: 50, height: 50, color: Colors.grey),
                        title: Text(item['nombre']),
                        subtitle: Text('Cantidad: ${item['cantidad']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                int productId = int.parse(item['id_producto'].toString());
                                _removeItemFromCart(productId);
                              },
                            ),
                            Text('${(double.tryParse(item['precio'].toString()) ?? 0.0 * item['cantidad']).toStringAsFixed(2)}€'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCodeController,
                        decoration: InputDecoration(
                          labelText: 'Código promocional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _verifyPromoCode,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('€${subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IVA (21%):', style: TextStyle(fontSize: 16)),
                    Text('€${iva.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Descuento:', style: TextStyle(fontSize: 16)),
                    Text('-€${discount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('€${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment');
                  },
                  child: Text('Realizar Pago'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
