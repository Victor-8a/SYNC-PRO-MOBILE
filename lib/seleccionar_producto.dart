import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Definición de la clase Product
class Product {
  final String name;
  final double price;

  Product(this.name, this.price);
}

// Definición de la clase SeleccionarProducto
class SeleccionarProducto extends StatefulWidget {
  @override
  _SeleccionarProductoState createState() => _SeleccionarProductoState();
}

class _SeleccionarProductoState extends State<SeleccionarProducto> {
  List<Product> productos = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }
// Función para obtener los productos desde la API
Future<void> _fetchProducts() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.1.169:3500/dashboard'));
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, parsear los datos y actualizar el estado
      final List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        productos = jsonResponse.map((data) {
          return Product(
            data['Descripcion'] ?? 'Sin descripción',
            data['PrecioFinal'] != 0 ? double.parse(data['PrecioFinal'].toString()) : 0.0,
          );
        }).toList();
      });
    } else {
      // Si la solicitud falla, mostrar un mensaje de error
      throw Exception('Error al cargar los productos');
    }
  } catch (error) {
    // Manejar el error
    print('Error al cargar los productos: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Producto'),
      ),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(productos[index].name),
            subtitle: Text('Q${productos[index].price.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pop(context, productos[index]);
            },
          );
        },
      ),
    );
  }
}

// Ejemplo de uso de SeleccionarProducto
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ejemplo de Seleccionar Producto'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SeleccionarProducto()),
              );
            },
            child: Text('Seleccionar Producto'),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
