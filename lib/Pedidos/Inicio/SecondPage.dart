import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/Pedidos/services/ObtenerPedido.dart';
import 'package:sync_pro_mobile/Pedidos/services/SincronizarPedidos.dart';
import 'package:sync_pro_mobile/Pedidos/services/SincronizarRuta.dart';
import 'package:sync_pro_mobile/Pedidos/services/WarningWidgetCubit.dart';
import '../PantallasPrincipales/PaginaListarPedido.dart';
import '../PantallasPrincipales/PaginaRutas.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:sync_pro_mobile/Pedidos/services/ProductoService.dart';

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
    PaginaListarPedidos(),
    PaginaRegistrar(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername =
        prefs.getString('username'); // Cambiado a 'userName'
    setState(() {
      _username = storedUsername ?? '';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedidos',
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
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo,
                    Colors.blueAccent
                  ], // Gradiente de colores
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      'Hola, $_username', // Variable dinámica para el nombre de usuario
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.indigo),
              title: const Text('Sincronizar Pedido'),
              onTap: syncOrders, // Función para sincronizar pedidos
            ),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.indigo),
              title: const Text('Sincronizar Ruta'),
              onTap: syncRutas, // Función para sincronizar rutas
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.indigo),
              title: const Text('Descargar Pedidos'),
              onTap: fetchPedido, // Función para descargar pedidos
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
        items: const <Widget>[Icon(Icons.store_sharp), Icon(Icons.sell)],
        onTap: _onItemTapped,
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Login Page'),
    ),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
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
