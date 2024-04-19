import 'package:flutter/material.dart';
class SeleccionarCliente extends StatelessWidget {
  const SeleccionarCliente({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí puedes implementar la lógica para mostrar una lista de clientes
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Cliente'),
      ),
      body: Center(
        child: Text('Pantalla de Selección de Clientes'), 
      ),
    );
  }
}