import 'package:flutter/material.dart';

class PuntoDeVentaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Punto de Venta'),
      ),
      body: Center(
        child: Text(
          'Página de Punto de Venta',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
