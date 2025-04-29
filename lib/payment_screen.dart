import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecciona un método de pago:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de introducción de tarjeta
                Navigator.pushNamed(context, '/cardInput');
              },
              child: Text('Tarjeta de Crédito/Débito'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Acción para pagar con Google Pay (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Método no implementado, utiliza tarjeta débito.')),
                );
              },
              child: Text('Google Pay'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Acción para pagar con Apple Pay (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Método no implementado, utiliza tarjeta débito.')),
                );
              },
              child: Text('Apple Pay'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Acción para pagar con PayPal (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Método no implementado, utiliza tarjeta débito.')),
                );
              },
              child: Text('PayPal'),
            ),
          ],
        ),
      ),
    );
  }
}
