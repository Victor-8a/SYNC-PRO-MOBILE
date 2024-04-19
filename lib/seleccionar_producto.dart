import 'package:flutter/material.dart';

class SeleccionarProducto extends StatelessWidget {
   SeleccionarProducto({Key? key}) : super(key: key);

  // Lista de productos de ejemplo
  final List<String> productos = [
    'Producto 1', 'Q20.00',
    'Producto 2', 'Q95.00',
    'Producto 3 ', 'Q250.00',
    'Producto 4,', 'Q63.00',
    'Producto 5', 'Q325.00',
    // Agrega más productos según necesites
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Producto'),
      ),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (BuildContext context, int index) {
          // Retorna un ListTile para cada producto
          return ListTile(
            title: Text(productos[index]),
            onTap: () {
              // Aquí puedes implementar lo que sucede cuando se selecciona un producto
              // Por ejemplo, podrías mostrar más detalles del producto o realizar alguna acción
              // Puedes usar Navigator.pop() para regresar a la pantalla anterior, por ejemplo.
              // Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
