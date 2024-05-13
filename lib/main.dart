// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/second_page.dart';

void main() {
  runApp(const LoginApp());
}

Future<void> saveTokenToStorage(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  print('Token guardado en el almacenamiento: $token');
}

Future<void> saveIdToStorage(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  print('id guardado en el almacenamiento: $userId');
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Iniciar Sesión',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _mostrarError = false;

  Future<void> _login() async {
    int id = 0;
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    final response = await http.post(
      Uri.parse('http://192.168.1.169:3500/auth/signin'),
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
      id = jsonDecode(response.body)['user']['id'];
      saveTokenToStorage(token);
      print('Token: $token');
      //guardar el id
      saveIdToStorage(id.toString());
      print('id: $id');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SecondPage()),
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
