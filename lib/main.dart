// Importa el paquete 'dart:convert' y 'package:flutter/material.dart'
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/second_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoginApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Iniciar Sesión',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const LoginPage({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _mostrarError = false; // Variable para controlar el mensaje de error

  Future<void> _login() async {
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    final response = await http.post(
      Uri.parse('http://192.168.1.212:3000/auth/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Nombre': usuario,
        'password': contrasena,
      }),
    );

    if (response.statusCode == 200) {
      // Autenticación exitosa, puedes navegar a la segunda pagina
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const SecondPage()),
      );
    } else {
      // Error en la autenticación
      setState(() {
        _mostrarError = true;
      });

      // Mostrar el SnackBar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
       const  SnackBar(
          content: Text('Datos invalidos'),
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
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_people_rounded),
                ),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _contrasenaController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20.0),
             const  Padding(
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
