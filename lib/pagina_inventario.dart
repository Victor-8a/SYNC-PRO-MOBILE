import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaginaInventario extends StatelessWidget {
  const PaginaInventario({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Inventario'),
    );
  }
}
// Definición de la clase Product
class Product {
  final int codigo;
  final String barras;
  final String descripcion;
  final double precioFinal;

  // Constructor de la clase Product
  Product({
    required this.codigo,
    required this.barras,
    required this.descripcion,
    required this.precioFinal,
  });

  // Factory constructor para convertir un mapa JSON en una instancia de Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      codigo: json['codigo'],
      barras: json['Barras'],
      descripcion: json['Descripcion'],
      precioFinal: json['PrecioFinal'].toDouble(),
    );
  }
}

