import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/Producto.dart';
import 'package:sync_pro_mobile/PantallasSecundarias/pagina_pedidos.dart';
import 'package:sync_pro_mobile/services/Configuraciones.dart';
import 'package:sync_pro_mobile/services/warning_widget_cubit.dart';
import '../main.dart';
import '../PantallasPrincipales/pagina_inventario.dart';
import '../PantallasPrincipales/pagina_cliente.dart';
import '../PantallasPrincipales/pagina_listar_pedido.dart';
import '../PantallasPrincipales/pagina_registrar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:sync_pro_mobile/services/ProductoService.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SecondPage(),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int _selectedIndex = 0;
  String _username = '';
    late Future<List<Product>> futureProducts;
     final ProductService productService = ProductService();

  final List<Widget> _pages = <Widget>[
    PaginaInventario(),
      PaginaListarPedidos(),
    PaginaCliente(),
    PaginaRegistrar(),
  ];


  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

Future<void> _loadUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedUsername = prefs.getString('username'); // Cambiado a 'userName'
  setState(() {
    _username = storedUsername ?? '';
  });
}


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
    await prefs.remove('username');
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
          style: TextStyle(color: Colors.white),

        ),
        backgroundColor: Colors.blue,

      ),


           drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Hola, $_username',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronizar Pedido'),
              onTap: syncOrders,
            ),
            ListTile(
              leading: const Icon(Icons.settings), // Icono para configuraciones
              title: const Text('Configuraciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfiguracionesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: _logout,

            ),
          ],
        ),
      ),




      body: Column(
        children: [
           WarningWidgetCubit(),
          Expanded(child: _pages.elementAt(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        items: const <Widget>[
          Icon(Icons.inventory),
           Icon(Icons.store_sharp),
          Icon(Icons.person_3_rounded),
          Icon(Icons.sell),
          // Icon(Icons.person_add_alt),

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