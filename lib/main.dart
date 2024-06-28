import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Inicio/second_page.dart';
import 'package:sync_pro_mobile/services/check_internet_connection.dart';

final internetChecker = CheckInternetConnection();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLoggedIn = await checkIfLoggedIn() ?? false;
  runApp(LoginApp(isLoggedIn: isLoggedIn));
}

Future<bool?> checkIfLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  return token != null;
}

Future<void> saveTokenToStorage(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  print('Token guardado en el almacenamiento: $token');
}

Future<void> saveIdToStorage(String userId, int opcion) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  opcion == 1
      ? await prefs.setString('userId', userId)
      : await prefs.setString('idVendedor', userId);
  print('id guardado en el almacenamiento: $userId');
}

Future<void> saveUsernameToStorage(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username); // Cambiado a 'userName'
  print('Nombre de usuario guardado en el almacenamiento: $username');
}

Future<String?> getUsernameFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}
Future<String?> getPasswordFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('password');
}

Future<void> savePasswordToStorage(String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('password', password);
  print('Contraseña guardada en el almacenamiento: $password');
}


class LoginApp extends StatelessWidget {
  final bool isLoggedIn;
  const LoginApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iniciar Sesión',
      home: isLoggedIn ? const SecondPage() : const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  // ignore: unused_field
  bool _mostrarError = false;

  Future<void> _login() async {
    int id = 0;
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    final response = await http.post(
      Uri.parse('http://192.168.1.212:3000/auth/signIn'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': id.toString(),
        'Nombre': usuario,
        'password': contrasena,
      }),
    );
    print('prueba de id para ver si devuelve algo');
    print('id: $id');

    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)['token'];
      String? nombreUsuario = jsonDecode(response.body)['user']?['nombre'];
      id = jsonDecode(response.body)['user']?['id'] ?? 0;

      saveTokenToStorage(token);
      saveIdToStorage(id.toString(), 1);
      saveIdToStorage(
          jsonDecode(response.body)['user']?['idVendedor']?.toString() ?? '',
          2);
      savePasswordToStorage(contrasena);  // Guarda la contraseña aquí

      if (nombreUsuario != null) {
        saveUsernameToStorage(nombreUsuario);
      } else {
        print('No se pudo encontrar el nombre de usuario en la respuesta.');
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SecondPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _mostrarError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos inválidos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double avatarSize = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SS Super Sistemas'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: avatarSize,
                  backgroundImage: const NetworkImage(
                      'https://th.bing.com/th/id/OIP.nxnPTtlVtp1CkDc34ZR57gHaHa?rs=1&pid=ImgDetMain'),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.emoji_people_rounded),
                  ),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Super Sistemas 2024 ©',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),  
      ),
    );
  }
}
