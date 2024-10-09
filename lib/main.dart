import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Menu.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Empresa.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Usuario.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Vendedor.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/CheckInternetConnection.dart';
import 'package:sync_pro_mobile/Pedidos/services/EmpresaService.dart';

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
  if (userId.isNotEmpty) {
    // Asegurarse de que userId no esté vacío
    opcion == 1
        ? await prefs.setString('userId', userId)
        : await prefs.setString('idVendedor', userId);
    print('id guardado en el almacenamiento: $userId');
  } else {
    throw Exception('El userId está vacío o es nulo.');
  }
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

Future<Vendedor> loadSalesperson() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? idVendedor = prefs.getString('idVendedor');

  if (idVendedor != null) {
    try {
      final response =
          await http.get(ApiRoutes.buildUri('vendedor/$idVendedor'));

      if (response.statusCode == 200) {
        Vendedor vendedor = Vendedor.fromJson(jsonDecode(response.body));
        print('Nombre del vendedor recibido: ${vendedor.nombre}');
        await saveVendedorNameToStorage(vendedor.nombre);
        return vendedor;
      } else {
        // Manejo del error en caso de que no se obtenga un código 200
        print('Failed to load salesperson: ${response.statusCode}');
        throw Exception('Failed to load salesperson: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading salesperson: $error');
      throw Exception('Failed to load salesperson: $error');
    }
  } else {
    print("Fallo Vendedores");
    throw Exception('Failed to load salesperson: idVendedor is null');
  }
}

Future<void> saveVendedorNameToStorage(String vendedorName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('vendedorName', vendedorName);
  print('Nombre del vendedor guardado en el almacenamiento: $vendedorName');
}

Future<String?> getVendedorNameFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('vendedorName');
}

class LoginApp extends StatelessWidget {
  final bool isLoggedIn;
  const LoginApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iniciar Sesión',
      home: isLoggedIn ? HomeScreen() : const LoginPage(),
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
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    final response = await http.post(
      ApiRoutes.buildUri('auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Nombre': usuario,
        'password': contrasena,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Iniciando sesión",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      String token = jsonResponse['token'];
      Map<String, dynamic> userJson = jsonResponse['user'];
      String? nombreUsuario = userJson['nombre'];
      int id = userJson['id'] ?? 0;

      await saveTokenToStorage(token);
      await saveIdToStorage(id.toString(), 1);
      await saveIdToStorage(userJson['idVendedor']?.toString() ?? '', 2);
      await savePasswordToStorage(contrasena);

      if (nombreUsuario != null) {
        await saveUsernameToStorage(nombreUsuario);
        await loadSalesperson();

        try {
          Empresa empresa = await fetchEmpresa(id);
          print('Empresa cargada exitosamente: ${empresa.empresa}');
        } catch (error) {
          print('Error al obtener la empresa: $error');
        }

        try {
          await fetchImage().then((imageModel) async {
            await saveImageToFile(imageModel);
            print('Imagen guardada correctamente en el dispositivo.');
          }).catchError((error) {
            print('Error al obtener la imagen: $error');
          });
        } catch (error) {
          print('Error en la descarga y guardado de imagen: $error');
        }

        // Inserta el usuario en la base de datos
        try {
          Usuario usuario = Usuario.fromJson(userJson);
          await insertUsuario(usuario);
          print('Usuario guardado en la base de datos.');
        } catch (error) {
          print('Error al guardar el usuario en la base de datos: $error');
        }

        // Verifica si la tabla Configuraciones está vacía e inserta si es necesario
        try {
          await DatabaseHelperConfiguraciones()
              .insertConfiguracionSiEstaVacia();
          print('Configuración insertada si estaba vacía.');
        } catch (error) {
          print('Error al verificar o insertar configuración: $error');
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        print('No se pudo encontrar el nombre de usuario en la respuesta.');
      }
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

  Future<void> insertUsuario(Usuario usuario) async {
    DatabaseHelperUsuario dbHelper = DatabaseHelperUsuario();
    await dbHelper.insertUsuario(usuario);
  }
}
