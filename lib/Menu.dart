import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Inicio/SecondPage.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasPrincipales/PaginaCliente.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasPrincipales/PaginaInventario.dart';
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/Pedidos/services/Configuraciones.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasPriincipales/PuntoDeVenta.dart';
import 'package:sync_pro_mobile/main.dart';

void main() {
  runApp(MyApp());
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _onItemTapped(int index) {
    setState(() {});

    _navigateToPage(index);
  }

  void _navigateToPage(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecondPage()),
      );
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PuntoDeVentaPage()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaginaCliente()),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaginaInventario()),
      );
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('idVendedor');
    await prefs.remove('username');
    await deleteUsuario();

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
        title: Text('Sync Pro Mobile',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.blue[600], // Color más oscuro para el AppBar
      ),
      drawer: _buildDrawer(), // Drawer mejorado
      body: _buildGridView(), // Mejoras en el GridView
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blueAccent],
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
          _buildDrawerItem(Icons.settings, 'Configuraciones', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConfiguracionesPage()),
            );
          }),
          _buildDrawerItem(Icons.logout, 'Cerrar sesión', logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon, String title, GestureTapCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: onTap,
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      crossAxisCount: 2,
      children: <Widget>[
        _buildGridItem('PEDIDOS', Icons.shopping_cart, Colors.indigo[100]!, 0),
        _buildGridItem('PUNTO DE VENTA', Icons.point_of_sale, Colors.indigo[200]!, 1),
        _buildGridItem('CLIENTES', Icons.person, Colors.indigo[400]!, 2),
        _buildGridItem('INVENTARIO', Icons.inventory, Colors.indigo[300]!, 3),
        _buildGridItem('', null, Colors.indigo[500]!, null),
        _buildGridItem('', null, Colors.indigo[600]!, null),
      ],
    );
  }
Widget _buildGridItem(String title, IconData? icon, Color color, int? index) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: index != null
          ? () {
              _onItemTapped(index);
            }
          : null,
      splashColor: Colors.white.withOpacity(0.5), // Aumenta la opacidad del splash
      highlightColor: Colors.white.withOpacity(0.3), // Aumenta la visibilidad del highlight
      hoverColor: Colors.white.withOpacity(0.1),
      splashFactory: InkRipple.splashFactory,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200), // Añade animación para cambios visuales
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 48,
                color: Colors.grey[800],
              ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

  deleteUsuario() async {
    DatabaseHelperUsuario dbHelper = DatabaseHelperUsuario();
    final eliminar = await dbHelper.deleteUsuario();
    return eliminar;
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername =
        prefs.getString('username'); // Cambiado a 'userName'
    setState(() {
      _username = storedUsername ?? '';
    });
  }
}
