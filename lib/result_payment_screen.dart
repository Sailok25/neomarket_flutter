import 'package:flutter/material.dart';

class ResultPaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSuccess = ModalRoute.of(context)?.settings.arguments as bool;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? Colors.green : Colors.red,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              isSuccess
                  ? 'Pago completado\nGracias por utilizar nuestro servicio'
                  : 'Pago rechazado\nPrueba a usar otra tarjeta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isSuccess) {
                  // Cerrar la pantalla y volver al inicio
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                } else {
                  // Volver a la pantalla de introducción de tarjeta
                  Navigator.pushNamedAndRemoveUntil(context, '/cardInput', (route) => false);
                }
              },
              child: Text(isSuccess ? 'Cerrar' : 'Volver a intentar'),
            ),
          ],
        ),
      ),
    );
  }
}
