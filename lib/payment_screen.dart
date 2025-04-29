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
            ElevatedButton.icon(
              onPressed: () {
                // Acción para pagar con tarjeta (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pagando con tarjeta...')),
                );
              },
              icon: Icon(Icons.credit_card),
              label: Text('Tarjeta de Crédito/Débito'),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para pagar con PayPal (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pagando con PayPal...')),
                );
              },
              icon: Icon(Icons.account_balance_wallet),
              label: Text('PayPal'),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para pagar con Apple Pay (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pagando con Apple Pay...')),
                );
              },
              icon: Icon(Icons.apple),
              label: Text('Apple Pay'),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para pagar con Google Pay (mockup)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pagando con Google Pay...')),
                );
              },
              icon: Icon(Icons.android),
              label: Text('Google Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
