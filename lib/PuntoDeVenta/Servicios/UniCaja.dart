// import 'dart:convert';

// import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
// import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
// import 'package:http/http.dart' as http;

// Future<bool?> fetchUniCaja() async {
//   String? token = await login();

//   if (token == null) {
//     token = await login();
//     if (token == null) {
//       throw Exception('No token found and unable to login');
//     }
//   }

//   try {
//     final response = await http.get(
//       ApiRoutes.buildUri('config'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       var unicajaData = data.firstWhere(
//         (item) => item['unicaja'] == true,
//         orElse: () => null,
//       );

//       if (unicajaData != null) {
//         return unicajaData['unicaja'];
//       } else {
//         print('No se encontró ningún dato con unicaja = true');
//         return null;
//       }
//     } else {
//       print(
//           'Error al cargar la configuración, StatusCode: ${response.statusCode}');
//       return null;
//     }
//   } catch (e) {
//     print('Error al cargar la configuración: $e');
//     return null;
//   }
// }
