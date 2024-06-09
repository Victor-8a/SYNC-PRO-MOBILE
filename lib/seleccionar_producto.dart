import 'package:flutter/material.dart';
import 'Models/Producto.dart';

class SeleccionarProducto extends StatelessWidget {
  final List<Product> productosDisponibles;

  SeleccionarProducto({Key? key, required this.productosDisponibles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Producto'),
      ),
      body: ListView.builder(
        itemCount: productosDisponibles.length,
        itemBuilder: (context, index) {
          final product = productosDisponibles[index];
          return ListTile(
            title: Text(product.descripcion),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Precio Final: Q${product.precioFinal.toStringAsFixed(2)}'),
                Text('Existencia: ${product.existencia}'),
                Text('Precio B: Q${product.precioB.toStringAsFixed(2)}'),
                Text('Precio C: Q${product.precioC.toStringAsFixed(2)}'),
                Text('Precio D: Q${product.precioD.toStringAsFixed(2)}'),
              ],
            ),
            onTap: () {
              Navigator.pop(context, product);
            },
          );
        },
      ),
    );
  }
}
