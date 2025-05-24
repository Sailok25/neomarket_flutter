import 'package:flutter/material.dart';
import 'conexio.dart'; // Asegúrate de importar tu clase de conexión a la base de datos

class ResultPaymentScreen extends StatelessWidget {
  final DatabaseConnection _dbConnection = DatabaseConnection();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final isSuccess = args?['isSuccess'] as bool?;
    final userId = args?['userId'] as int?;
    final cartItems = args?['cartItems'] as List<Map<String, dynamic>>?;

    if (isSuccess != null && isSuccess && userId != null && cartItems != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _updateProductStock(cartItems);
        await _clearUserCart(userId);
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess != null && isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess != null && isSuccess ? Colors.green : Colors.red,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              isSuccess != null && isSuccess
                  ? 'Pago completado\nGracias por utilizar nuestro servicio'
                  : 'Pago rechazado\nPrueba a usar otra tarjeta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isSuccess != null && isSuccess) {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                } else {
                  Navigator.pushNamedAndRemoveUntil(context, '/cardInput', (route) => false);
                }
              },
              child: Text(isSuccess != null && isSuccess ? 'Cerrar' : 'Volver a intentar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProductStock(List<Map<String, dynamic>> cartItems) async {
    try {
      for (var item in cartItems) {
        int productId = item['id_producto'];
        int quantity = item['cantidad'];

        await _dbConnection.executeQuery(
          '''
          UPDATE nm_productos
          SET unidades = unidades - :quantity
          WHERE id_producto = :productId
          ''',
          {'quantity': quantity, 'productId': productId},
        );
      }
    } catch (e) {
      print('Error updating product stock: $e');
    }
  }

  Future<void> _clearUserCart(int userId) async {
    try {
      await _dbConnection.executeQuery(
        'DELETE FROM nm_cesta WHERE id_usuario = :userId',
        {'userId': userId},
      );
    } catch (e) {
      print('Error clearing user cart: $e');
    }
  }
}
