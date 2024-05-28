import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/main.dart';
import 'package:sync_pro_mobile/nuevo_pedido.dart';
import 'pagina_inventario.dart';
import 'pagina_vendedores.dart';
import 'pagina_registrar.dart';
import 'pagina_cliente.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Importar shared_preferences

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
    PaginaInventario(),
    NuevoPedido(),
    PaginaCliente(),
    PaginaVendedores(),
    PaginaRegistrar(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('idVendedor');
    // Navegar a la página de inicio de sesión y eliminar todas las rutas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
    'Sync Pro Mobile',
    style: TextStyle(color: Colors.white), // Establecer el color del texto en blanco
  ),
  backgroundColor: Colors.blue,
),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        items: const <Widget>[
          Icon(Icons.inventory),
          Icon(Icons.sell_outlined),
          Icon(Icons.person),
          Icon(Icons.store_sharp),
          Icon(Icons.person_add_alt),
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

// La clase LoginPage debe estar definida aquí o importada desde otro archivo


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navegar a la SecondPage (esto es solo para ejemplo, reemplazar con tu lógica de inicio de sesión)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SecondPage()),
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }

