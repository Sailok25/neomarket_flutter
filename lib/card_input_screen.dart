import 'package:flutter/material.dart';

class CardInputScreen extends StatelessWidget {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Introduce tu tarjeta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo para el número de tarjeta
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 16, // Límite de 16 dígitos
              decoration: InputDecoration(
                labelText: 'Número de tarjeta',
                border: OutlineInputBorder(),
                counterText: '', // Oculta el contador de caracteres
              ),
            ),
            SizedBox(height: 16),

            // Campos para la fecha de caducidad y el PIN en una fila
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expirationDateController,
                    keyboardType: TextInputType.number,
                    maxLength: 5, // Formato MM/YY
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      counterText: '', // Oculta el contador de caracteres
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4, // PIN de 4 dígitos
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      border: OutlineInputBorder(),
                      counterText: '', // Oculta el contador de caracteres
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Botón de pago
            ElevatedButton(
              onPressed: () {
                final cardNumber = _cardNumberController.text;
                final expirationDate = _expirationDateController.text;
                final pin = _pinController.text;

                // Validación del número de tarjeta
                if (cardNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, introduce un número de tarjeta.')),
                  );
                  return;
                }
                if (cardNumber.length < 13 || cardNumber.length > 19) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('El número de tarjeta debe tener entre 13 y 19 dígitos.')),
                  );
                  return;
                }

                // Validación de la fecha de caducidad
                if (expirationDate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, introduce la fecha de caducidad.')),
                  );
                  return;
                }
                if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expirationDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Formato de fecha inválido. Usa MM/YY.')),
                  );
                  return;
                }

                // Validación del PIN
                if (pin.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, introduce el PIN.')),
                  );
                  return;
                }
                if (pin.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('El PIN debe tener 4 dígitos.')),
                  );
                  return;
                }

                // Validación del número de tarjeta (par o impar)
                final number = int.tryParse(cardNumber);
                if (number == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Número de tarjeta no válido.')),
                  );
                  return;
                }

                // Navegar a la pantalla de resultado del pago
                Navigator.pushNamed(
                  context,
                  '/resultPayment',
                  arguments: number % 2 != 0,
                );
              },
              child: Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
