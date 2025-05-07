import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrito')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Aún no has añadido productos a tu cesta'),
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
                        decoration: InputDecoration(
                          labelText: 'Código promocional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Space between the TextField and the Button
                    IconButton(
                      icon: Icon(Icons.arrow_forward), // Using an icon for the button
                      onPressed: () {
                        // Action to verify the promotional code
                        print('Verificando tu codigo promocional...');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('\$0.00', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IVA (21%):', style: TextStyle(fontSize: 16)),
                    Text('\$0.00', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Action to proceed to payment
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
