import 'package:flutter/material.dart';
import 'pagina_inventario.dart';
import 'pagina_pedidos.dart';
import 'pagina_vendedores.dart';
import 'pagina_registrar.dart';
import 'pagina_cliente.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SecondPage(),
    );
  }
}

class SecondPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const SecondPage({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const  PaginaInventario(),
    const PaginaPedidos(),
    const PaginaVendedores(),
    const PaginaRegistrar(),
    const PaginaCliente(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SS Super Sistemas'),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        items: const  <Widget>[
          Icon(Icons.inventory),
          Icon(Icons.sell_outlined),
          Icon(Icons.search),
          Icon(Icons.select_all_sharp),
          Icon(Icons.person),
        ],
        onTap: _onItemTapped,
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
