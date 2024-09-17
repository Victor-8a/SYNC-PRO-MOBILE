import 'package:flutter/material.dart';

class FinalizarCompra extends StatefulWidget {
  const FinalizarCompra({Key? key}) : super(key: key);

  @override
  _FinalizarCompraState createState() => _FinalizarCompraState();
}

class _FinalizarCompraState extends State<FinalizarCompra> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar Compra'),
      ),
      body: Center(
        child: Text('Pantalla de Finalizar Compra'),
      ),
    );
  }
}
