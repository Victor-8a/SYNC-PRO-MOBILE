import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Ruta.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/SeleccionarProducto.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/db/dbPedidos.dart' as dbGuardarPedido;
import 'package:sync_pro_mobile/db/dbProducto.dart';
import 'package:sync_pro_mobile/db/dbRangoPrecioProducto.dart';
import 'package:sync_pro_mobile/db/dbVendedores.dart';
import 'package:sync_pro_mobile/main.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/SeleccionarClientes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Models/Producto.dart';
import '../Models/Vendedor.dart';
import '../services/LocalStorage.dart';
import '../../db/dbDetallePedidos.dart' as dbDetallePedidos;
import '../../db/dbDetalleRuta.dart' as dbDetalleRuta;
import '../../db/dbRuta.dart';

void saveSalesperson(Vendedor salesperson) async {
  String salespersonJson = jsonEncode(salesperson.toJson());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('salesperson', salespersonJson);
}

LocalStorage localStorage = LocalStorage();
Future<String> getTokenFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ??
      ""; // Si el token no existe, devuelve una cadena vacía
  return token;
}

Future<String?> getUsernameFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  return username;
}

Future<String?> getPasswordFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? password = prefs.getString('password');
  return password;
}

Future<String> getIdFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ??
      ""; // Si el id no existe, devuelve una cadena vacía
  return userId;
}

Future<Vendedor?> getSalesperson() async {
  String? salespersonJson = await LocalStorage.getString('salesperson');
  if (salespersonJson != null) {
    return Vendedor.fromJson(jsonDecode(salespersonJson));
  } else {
    return null;
  }
}

Future<String?> login() async {
  String? username = await getUsernameFromStorage();
  String? password = await getPasswordFromStorage();

  if (username == null || password == null) {
    Fluttertoast.showToast(
      msg: 'Credenciales no disponibles, no se puede iniciar sesión.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    return null;
  }

  final response = await http.post(
    ApiRoutes.buildUri('auth/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'Nombre': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    String token = jsonDecode(response.body)['token'];
    await saveTokenToStorage(token);
    return token;
  } else {
    Fluttertoast.showToast(
      msg: 'Error al iniciar sesión: ${response.statusCode}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    return null;
  }
}

Future<void> syncOrders() async {
  List<Map<String, dynamic>> unsyncedOrders =
      await dbGuardarPedido.DatabaseHelperPedidos().getUnsyncedOrders();
  String? token = await login();

  if (token == null) {
    token = await login();
    if (token == null) {
      Fluttertoast.showToast(
        msg:
            'No se puede obtener un token, no se pueden sincronizar los pedidos.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
  }

  // Mostrar el Toast por 5 segundos al inicio de la sincronización
  Fluttertoast.showToast(
    msg: 'Iniciando la sincronización de pedidos.',
    toastLength: Toast.LENGTH_LONG, // 4 segundos
    gravity: ToastGravity.BOTTOM,
  );

  // Esperar 1 segundo adicional para cumplir 5 segundos
  await Future.delayed(Duration(seconds: 1));

  for (var order in unsyncedOrders) {
    try {
      var url = ApiRoutes.buildUri('pedidos');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var orderCopy = Map<String, dynamic>.from(order);
      orderCopy.remove('synced');
      orderCopy.remove('id');
      orderCopy.remove('NumPedido');

      var body = jsonEncode(orderCopy);

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 401) {
        // Token expirado o inválido, intentar iniciar sesión nuevamente
        // ignore: unnecessary_null_comparison
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
          response = await http.post(url, headers: headers, body: body);
        } else {
          Fluttertoast.showToast(
            msg: 'Error de Servidor 401',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          return;
        }
      }

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        int idPedido = jsonResponse['savedOrder']['id'];

        List<Map<String, dynamic>> unsyncedOrderDetails =
            await dbDetallePedidos.DatabaseHelperDetallePedidos()
                .getUnsyncedOrderDetails(order['id']);

        int syncedDetailsCount = 0;

        for (int i = 0; i < unsyncedOrderDetails.length; i++) {
          var detail = unsyncedOrderDetails[i];
          try {
            var detailCopy = Map<String, dynamic>.from(detail);
            detailCopy.remove('Id');
            detailCopy['IdPedido'] = idPedido;

            var detailUrl = ApiRoutes.buildUri('detalle_pedidos');
            var detailBody = jsonEncode(detailCopy);

            var detailResponse =
                await http.post(detailUrl, headers: headers, body: detailBody);

            if (detailResponse.statusCode == 201) {
              syncedDetailsCount++;
              if (syncedDetailsCount == unsyncedOrderDetails.length) {
                await dbGuardarPedido.DatabaseHelperPedidos()
                    .markOrderAsSynced(order['id'], idPedido);
              }
            } else {
              Fluttertoast.showToast(
                msg: 'Error. No se pueden sincronizar los detalles del pedido.',
                textColor: Colors.red,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          } catch (error) {
            print('Error al sincronizar detalle del pedido: $error');
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Error al sincronizar pedido: ${response.statusCode}',
          textColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error al sincronizar pedido.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      print('error aqui');
      print(error);
    }
  }

  // Mostrar el Toast por 5 segundos al finalizar la sincronización
  Fluttertoast.showToast(
    msg: 'Sincronización de pedidos completada.',
    toastLength: Toast.LENGTH_LONG, // 4 segundos
    gravity: ToastGravity.BOTTOM,
  );

  // Esperar 1 segundo adicional para cumplir los 5 segundos
  await Future.delayed(Duration(seconds: 1));
}

Future<int?> saveOrder(int selectedClient, String observations,
    int _selectedSalespersonId, DateTime selectedDate) async {
  String? token = await getTokenFromStorage();
  String userId = await getIdFromStorage();

  // ignore: unnecessary_null_comparison
  if (token == null) {
    return null;
  }

  Map<String, dynamic> dataPedido =
      {}; // Declarar dataPedido fuera del bloque try-catch

  try {
    var url = Uri.parse('/');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print('Guardando pedido...');

    dataPedido = {
      "CodCliente": selectedClient,
      "Fecha": DateTime.now().toIso8601String(),
      "Observaciones": observations,
      "IdUsuario": userId,
      "FechaEntrega": selectedDate.toIso8601String(),
      "CodMoneda": 1,
      "TipoCambio": 1,
      "Anulado": false, // Usar 0 en lugar de false
      "idVendedor": _selectedSalespersonId,
    };
    var body = jsonEncode(dataPedido);
    print('Guardando pedido: $body');
    var response = await http.post(url, headers: headers, body: body);
    print(
        'Server responded with status code ${response.statusCode} and body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      int idPedido = jsonResponse['savedOrder']['id'];

      // Guardar en SQLite
      dbGuardarPedido.DatabaseHelperPedidos db =
          dbGuardarPedido.DatabaseHelperPedidos();
      await db.insertOrder(dataPedido);
      print('Pedido guardado en SQLite: $dataPedido');

      // Verificar si se guardó en SQLite
      var savedOrder = await db.getAllOrders();
      // ignore: unnecessary_null_comparison
      if (savedOrder != null) {
        print('Pedido verificado en SQLite: $savedOrder');
      }

      return idPedido;
    } else {
      print(
          'Server responded with status code ${response.statusCode} and body: ${response.body}');
      throw Exception('Failed to save order: ${response.statusCode}');
    }
  } catch (error) {
    print('Error saving order: $error');

    // Guardar en SQLite en caso de error
    dbGuardarPedido.DatabaseHelperPedidos db =
        dbGuardarPedido.DatabaseHelperPedidos();

    print('Pedido guardado en SQLite después del error: $dataPedido');

    return await db.insertOrder(dataPedido);
  }
}

Future<void> saveOrderDetail(
  int idPedido,
  List<Product> selectedProducts,
  Map<Product, int> selectedProductQuantities,
  Map<Product, double> selectedProductPrices,
  Map<Product, double> discounts,
) async {
  try {
    String? token = await getTokenFromStorage();
    // ignore: unnecessary_null_comparison
    if (token == null) {
      throw Exception('Token de autorización no válido');
    }

    var url = ApiRoutes.buildUri('paraElFuturo');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    for (var product in selectedProducts) {
      try {
        var orderDetailData = {
          "IdPedido": idPedido,
          "CodArticulo": product.codigo,
          "Descripcion": product.descripcion,
          "Cantidad": selectedProductQuantities[product],
          "PrecioVenta": selectedProductPrices[product] ?? product.precioFinal,
          "PorcDescuento": discounts[product] ?? 0,
          "Total": ((selectedProductPrices[product] ?? product.precioFinal) *
                  selectedProductQuantities[product]! -
              (selectedProductQuantities[product]! *
                  ((selectedProductPrices[product] ?? product.precioFinal) *
                      (discounts[product] ?? 0) /
                      100)))
        };

        await dbDetallePedidos.DatabaseHelperDetallePedidos()
            .insertOrderDetail(orderDetailData);

        var body = jsonEncode(orderDetailData);
        print('Datos del detalle del pedido a enviar: $body');

        var response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          print('Detalle del pedido guardado en la API correctamente');
          print(
              'Detalle del pedido marcado como sincronizado en SQLite: $orderDetailData');
        } else {
          print(
              'Error al guardar el detalle del pedido en la API: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al procesar el producto ${product.codigo}: $e');
      }
    }
  } catch (error, stackTrace) {
    print('Hubo un error al guardar los detalles del pedido: $error');
    print(stackTrace);
  }
}

//aqui inicia el widget

class PaginaPedidos extends StatefulWidget {
  final Cliente cliente;
  const PaginaPedidos({Key? key, required this.cliente}) : super(key: key);

  @override
  _PaginaPedidosState createState() => _PaginaPedidosState();
}

class _PaginaPedidosState extends State<PaginaPedidos> {
  final DatabaseHelperConfiguraciones dbHelper =
      DatabaseHelperConfiguraciones();
  final DatabaseHelperRuta dbHelperRuta = DatabaseHelperRuta();

  bool usarRuta = false;
  Ruta? miRuta;
  // Porcentaje de descuento

  void _loadSelectedProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedProductsJson =
        prefs.getStringList('selectedProducts');

    if (selectedProductsJson != null) {
      setState(() {
        _selectedProducts = selectedProductsJson.map((jsonString) {
          Map<String, dynamic> productMap = json.decode(jsonString);
          return Product.fromJson(productMap);
        }).toList();

        _selectedProductQuantities = Map.fromIterable(_selectedProducts,
            key: (product) => product,
            value: (product) => prefs.getInt(product.codigo.toString()) ?? 1);
      });
    }
  }

  // En la clase _PaginaPedidosState
  void _loadSelectedClientName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? cliente = prefs.getString('selectedClient');

    List<String>? selectedClientJson = prefs.getStringList('selectedClient');
    if (selectedClientJson != null) {
      Map<String, String> clientData = {};
      selectedClientJson.forEach((item) {
        var parts = item.split(': ');
        if (parts.length == 2) {
          clientData[parts[0]] = parts[1];
        }
      });
      _selectedClient = Cliente(
          codCliente: int.parse(clientData['codCliente']!),
          nombre: clientData['nombre']!,
          cedula: clientData['cedula']!,
          direccion: clientData['direccion']!);
    }
  }

  Future<void> saveVendedorToLocalDatabase(Vendedor vendedor) async {
    try {
      DatabaseHelperVendedor dbHelper = DatabaseHelperVendedor();
      await dbHelper.insertVendedor(vendedor);
    } catch (error) {
      print('Error saving vendedor to local database: $error');
      throw Exception('Failed to save vendedor to local database: $error');
    }
  }

  Future<Vendedor> loadSalesperson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idVendedor = prefs.getString('idVendedor');
    String? vendedorName = prefs.getString('vendedorName');

    return Vendedor(value: int.parse(idVendedor!), nombre: vendedorName!);
  }

  Future<Vendedor> getSalesperson() async {
    try {
      DatabaseHelperVendedor dbHelper = DatabaseHelperVendedor();
      List<Vendedor> vendedores = await dbHelper.getVendedores();
      if (vendedores.isNotEmpty) {
        return vendedores.first;
      } else {
        throw Exception('Vendedor no encontrado en la base de datos local');
      }
    } catch (error) {
      throw Exception('Fallo en obtener el vendedorde manera Local $error');
    }
  }

  Vendedor vendedor = Vendedor(value: 1, nombre: 'Vendedor 1');
  int? _selectedSalespersonId; // ID del vendedor seleccionado
  // ignore: unused_field
  List<Vendedor> _vendedores = [];
  Cliente _selectedClient =
      Cliente(codCliente: 0, nombre: '', cedula: '', direccion: '');
  DateTime _selectedDate = DateTime.now();
  List<Product> _selectedProducts = [];
  Map<Product, int> _selectedProductQuantities = {};

  Map<Product, double> _discounts =
      {}; // Mapa que guarda el descuento asociado con cada producto
  Map<Product, double> _selectedProductPrices = {};
  String _observations = '';
  Color _buttonColor = Colors.blue; // Color para los botones
  double _calculateTotal() {
    double total = 0;
    for (var product in _selectedProducts) {
      int quantity = _selectedProductQuantities[product]!;
      double unitPrice = _selectedProductPrices[product] ?? product.precioFinal;
      total += unitPrice * quantity;
    }
    return total;
  }

  Map<Product, TextEditingController> _quantityControllers = {};
  Map<Product, TextEditingController> _discountControllers = {};

  double _calculateTotalWithDiscount() {
    double total = 0.0;
    // Itera sobre los productos seleccionados y calcula el precio total con descuento
    _selectedProducts.forEach((product) {
      int quantity = _selectedProductQuantities[product] ?? 0;
      double unitPrice = _selectedProductPrices[product] ?? product.precioFinal;
      double discount = _discounts[product] ?? 0;
      double subtotal = unitPrice * quantity * (1 - (discount / 100));

      total += subtotal;
    });
    return total;
  }

  @override
  @override
  void initState() {
    super.initState();
    _selectedClient = widget.cliente;
    loadSalesperson().then((vendedor) {
      if (mounted) {
        setState(() {
          vendedor = vendedor;
        });
      }
    }).catchError((error) {});
    if (widget.cliente.codCliente == 0) _loadSelectedClientName();

    _loadSelectedProducts();
    // Inicializa _selectedProductPrices con precioFinal por defecto
    _selectedProducts.forEach((product) {
      _selectedProductPrices[product] = product.precioFinal;
    }); // Agregar esta línea para cargar los productos seleccionados guardados
    _fetchAndLoadVendedores();
  }

  Future<void> _fetchAndLoadVendedores() async {
    bool fetchSuccess = await _tryFetchAndStoreVendedores();

    // If fetching from server fails, load from local database
    if (!fetchSuccess) {
      print('Failed to fetch from server, loading from local database');
      final vendedores = await DatabaseHelperVendedor().getVendedores();

      if (mounted) {
        setState(() {
          _vendedores = vendedores;
        });
      }
    } else {
      fetchVendedores();
    }
  }

  Future<bool> _tryFetchAndStoreVendedores() async {
    try {
      return await DatabaseHelperVendedor().fetchAndStoreVendedores();
    } catch (e) {
      print('Error fetching and storing vendedores: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    double _totalPrice = _calculateTotalPrice();
    // ignore: unused_local_variable
    Vendedor? _selectedSalesperson;

    return WillPopScope(
        onWillPop: () async {
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¿Está seguro?'),
              content:
                  Text('Puede perder los datos de su pedido si retrocede.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Envía true si confirma
                  },
                  child: Text('Sí'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
              ],
            ),
          );

          return confirm;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Pedidos',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Vendedor>(
                      future: loadSalesperson(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return SizedBox(
                              height:
                                  1); // Si hay un error, no se muestra nada.
                        } else if (snapshot.hasData && snapshot.data != null) {
                          // Si hay datos y no son nulos, muestra la información del vendedor.
                          Vendedor _selectedSalesperson = snapshot.data!;
                          _selectedSalespersonId = _selectedSalesperson.value;
                          return Column(
                            children: [
                              Text(
                                'Vendedor: ${_selectedSalesperson.nombre}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Si los datos están cargando o son nulos, no se muestra nada.
                          return SizedBox(height: 1); // Espacio mínimo.
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Cliente: ' + _selectedClient.nombre,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        // Otros widgets que necesites
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigateToSeleccionarCliente(context);
                      },
                      child: Text(
                        'Seleccionar Cliente',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .calendar_today, // Aquí puedes cambiar el icono por el que desees
                          color: Colors.blue, // Color del icono
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Fecha de Entrega: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.0),
                        InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Text(
                            '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _navigateToSeleccionarProducto(context);
                      },
                      child: Text(
                        'Seleccionar Producto',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Productos seleccionados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Define controladores de texto para cantidades y descuentos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _selectedProducts.reversed.map((product) {
                        // Obtenemos el precio, cantidad y descuento actuales del producto
                        double unitPrice = _selectedProductPrices[product] ??
                            product.precioFinal;
                        int quantity = _selectedProductQuantities[product] ?? 0;
                        double discount = _discounts[product] ?? 0;

                        // Configurar controladores de texto si no existen
                        if (!_quantityControllers.containsKey(product)) {
                          _quantityControllers[product] =
                              TextEditingController(text: quantity.toString());
                        }
                        if (!_discountControllers.containsKey(product)) {
                          _discountControllers[product] =
                              TextEditingController(text: discount.toString());
                        }

                        // Calculamos los valores de subtotal y descuento
                        double subtotalBeforeDiscount = unitPrice * quantity;
                        double discountAmount =
                            subtotalBeforeDiscount * (discount / 100);
                        double subtotal =
                            subtotalBeforeDiscount - discountAmount;

                        // Preparamos la lista de precios disponibles
                        List<double> availablePrices = [
                          product.precioFinal,
                          product.precioB,
                          product.precioC,
                          product.precioD,
                        ].where((price) => price > 0).toList();

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${product.descripcion}',
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    DropdownButton<double>(
                                      value: availablePrices.contains(unitPrice)
                                          ? unitPrice
                                          : product.precioFinal,
                                      items:
                                          availablePrices.toSet().map((price) {
                                        return DropdownMenuItem(
                                          value: price,
                                          child: Text(
                                              'Q${price.toStringAsFixed(2)}'),
                                        );
                                      }).toList(),
                                      onChanged: (newPrice) async {
                                        int? cantidad =
                                            _selectedProductQuantities[product];

                                        if (cantidad != null) {
                                          double newUnitPrice =
                                              await getRangosByProducto(
                                                  product.codigo,
                                                  cantidad,
                                                  product.precioFinal);

                                          if (newUnitPrice != 0) {
                                            _showConfirmQuantityRangeDialog(
                                                context, cantidad);
                                            unitPrice = newUnitPrice;
                                          }
                                        }

                                        setState(() {
                                          _selectedProductPrices[product] =
                                              newPrice!;
                                          subtotalBeforeDiscount =
                                              unitPrice * quantity;
                                          discountAmount =
                                              subtotalBeforeDiscount *
                                                  (discount / 100);
                                          subtotal = subtotalBeforeDiscount -
                                              discountAmount;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close_sharp,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedProducts.remove(product);
                                          _selectedProductPrices
                                              .remove(product);
                                          _selectedProductQuantities
                                              .remove(product);
                                          _discounts.remove(product);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16.0),
                                      child: TextField(
                                        key: Key(
                                            'quantity_${product.codigo}'), // Asignar una clave única
                                        controller:
                                            _quantityControllers[product],
                                        keyboardType: TextInputType.number,
                                        onChanged: (newValue) async {
                                          int newQuantity = int.tryParse(
                                                  newValue == ''
                                                      ? '1'
                                                      : newValue) ??
                                              1;
                                          if (newQuantity > 0) {
                                            // Obtenemos el nuevo precio basado en la cantidad
                                            double newUnitPrice =
                                                await getRangosByProducto(
                                                    product.codigo,
                                                    newQuantity,
                                                    product.precioFinal);

                                            setState(() {
                                              // Actualizamos la cantidad seleccionada
                                              _selectedProductQuantities[
                                                  product] = newQuantity;

                                              // Actualizamos el precio unitario y el subtotal
                                              if (newUnitPrice != 0) {
                                                _selectedProductPrices[
                                                    product] = newUnitPrice;
                                                unitPrice = newUnitPrice;
                                              }
                                              subtotalBeforeDiscount =
                                                  unitPrice * newQuantity;
                                              discountAmount =
                                                  subtotalBeforeDiscount *
                                                      (discount / 100);
                                              subtotal =
                                                  subtotalBeforeDiscount -
                                                      discountAmount;
                                            });
                                          }
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          hintText: '1',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: TextField(
                                        key: Key(
                                            'discount_${product.codigo}'), // Asignar una clave única
                                        controller:
                                            _discountControllers[product],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d{1,2}$')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            // Actualizamos el descuento del producto
                                            _discounts[product] =
                                                double.tryParse(value) ?? 0;
                                            discount = _discounts[product]!;

                                            // Recalculamos el subtotal y descuento
                                            subtotalBeforeDiscount =
                                                unitPrice * quantity;
                                            discountAmount =
                                                subtotalBeforeDiscount *
                                                    (discount / 100);
                                            subtotal = subtotalBeforeDiscount -
                                                discountAmount;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: '% Desc',
                                          floatingLabelStyle:
                                              TextStyle(color: Colors.blue),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Text('Q${subtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20.0),
                    TextField(
                      onChanged: (value) {
                        _observations = value;
                      },
                      decoration: InputDecoration(
                        suffixText: 'Opcional',
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Subtotal: \Q${(_calculateTotal()).toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Descuento: \Q${(_calculateTotal() - _calculateTotalWithDiscount()).toStringAsFixed(2)}', // Diferencia entre el subtotal y el total con descuento
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Total: \Q${(_calculateTotalWithDiscount()).toStringAsFixed(2)}', // Precio total con descuento
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validar campos obligatorios
                          // ignore: unnecessary_null_comparison
                          if (_selectedClient == null ||
                              _selectedSalespersonId == null ||
                              // ignore: unnecessary_null_comparison
                              _selectedDate == null ||
                              _selectedProducts.isEmpty) {
                            // Mostrar mensaje de error si falta algún campo obligatorio
                            Fluttertoast.showToast(
                              msg:
                                  'Por favor complete todos los campos obligatorios.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return; // Detener la ejecución del método
                          }

                          // Mostrar AlertDialog de confirmación antes de agregar el pedido
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('¿Está seguro?'),
                              content: Text('¿Desea agregar el pedido?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Sí'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            // Proceder con el guardado del pedido
                            int? idPedido = await saveOrder(
                              _selectedClient.codCliente,
                              _observations,
                              _selectedSalespersonId ?? 0,
                              _selectedDate,
                            );

                            if (idPedido != null) {
                              // Guardar detalles del pedido
                              saveOrderDetail(
                                idPedido,
                                _selectedProducts,
                                _selectedProductQuantities,
                                _selectedProductPrices,
                                _discounts,
                              );

                              // Mostrar mensaje de éxito
                              Fluttertoast.showToast(
                                msg: 'Pedido guardado exitosamente.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              // await _loadUsaRuta;
                              bool usaConfigRuta = await dbHelper.getUsaRuta();
                              if (usaConfigRuta)
                                miRuta = await dbHelperRuta.getRutaActiva();
                              if (usaConfigRuta && miRuta != null)
                                await dbDetalleRuta.DatabaseHelperDetalleRuta()
                                    .updateIdPedidoDetalleRuta(
                                        _selectedClient.codCliente,
                                        idPedido,
                                        miRuta!.id);

                              // Resetear estado después de guardar
                              _resetState();
                            } else {
                              // Mostrar mensaje de error si falla el guardado del pedido
                              Fluttertoast.showToast(
                                msg: 'Error al guardar el pedido.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                        },
                        child: Text(
                          'Agregar Pedido',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0, // Agrega espacio entre los botones
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('¿Está seguro?'),
                              content: Text('¿Desea cancelar el pedido?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        true); // Cerrar el cuadro de diálogo y devolver true
                                  },
                                  child: Text('Sí'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(
                                      false), // Cerrar el cuadro de diálogo y devolver false
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            _resetState();
                            _resetInfo();
                          }
                        },
                        child: Text(
                          'Cancelar Pedido',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(double.infinity, 50),
                          fixedSize: Size(100, 50),
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> fetchVendedores() async {
    final response = await http.get(ApiRoutes.buildUri('vendedor'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      final vendedores =
          jsonResponse.map((data) => Vendedor.fromJson(data)).toList();
      if (mounted) {
        setState(() {
          _vendedores = vendedores;
        });
      }
    } else {
      print("Fallo vendedores $response");
      throw Exception('Failed to load vendedores');
    }
  }

  void _navigateToSeleccionarCliente(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeleccionarCliente(clientes: [])),
    ).then((selectedClient) {
      if (selectedClient != null) {
        _saveSelectedClient(
            selectedClient); // Guardar el nombre del cliente seleccionado
        setState(() {
          _selectedClient =
              selectedClient; // Actualizar el nombre del cliente seleccionado
        });
      }
    });
  }

  Future<void> _saveSelectedClient(Cliente cliente) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Serializar el producto junto con su cantidad
    Map<String, dynamic> clientData = cliente.toJson();
    // List<String> selectedClientJson = json.encode(productData).toList();
    // Convertir el mapa en una cadena JSON
    List<String> selectedClientJson = clientData.entries.map((entry) {
      return '${entry.key}: ${entry.value.toString()}';
    }).toList();

    await prefs.setStringList('selectedClient',
        selectedClientJson); // Guardar el nombre del cliente en SharedPreferences
  }

  void _navigateToSeleccionarProducto(BuildContext context) async {
    try {
      // Crear una lista para almacenar los productos
      List<Product> products = [];

      // Obtener los productos de la base de datos local
      DatabaseHelperProducto dbHelper = DatabaseHelperProducto();
      List<Product> productsFromDB = await dbHelper.getProducts();

      // Usar los productos obtenidos de la base de datos local
      if (productsFromDB.isNotEmpty) {
        products = productsFromDB;
      } else {
        Fluttertoast.showToast(
            msg: 'No se encontraron productos, cargue su inventarioio primero.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.yellow,
            textColor: Colors.black,
            fontSize: 16.0);

        return;
      }

      // Navegar a la pantalla de selección de producto con los productos locales
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeleccionarProducto(productos: products),
        ),
      ).then((selectedProduct) {
        if (selectedProduct != null) {
          setState(() {
            _selectedProducts.add(selectedProduct);
            if (_selectedProductQuantities.containsKey(selectedProduct)) {
              // Si el producto ya está en la lista, aumentar la cantidad
              _selectedProductQuantities[selectedProduct] =
                  _selectedProductQuantities[selectedProduct]! + 1;
            } else {
              // Si es un nuevo producto, establecer la cantidad en 1
              _selectedProductQuantities[selectedProduct] = 1;
            }
          });
        }
      });
    } catch (error) {
      print('Error al cargar los productos: $error');
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    _selectedProductQuantities.forEach((product, quantity) {
      total += product.precioFinal * quantity;
    });
    return total;
  }

  void _resetState() {
    if (mounted)
      setState(() {
        _selectedClient = Cliente(
            codCliente: 0,
            nombre: 'CONSUMIDOR FINAL ',
            cedula: 'CF',
            direccion: 'CIUDAD');
        _selectedSalespersonId = null;
        _selectedDate = DateTime.now();
        _selectedProducts = [];
        _selectedProductQuantities = {};
        // _observations = '';
      });
    _resetInfo();
  }

  void _resetInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _saveSelectedClient(Cliente(
        codCliente: 0,
        nombre: 'CONSUMIDOR FINAL ',
        cedula: 'CF',
        direccion: 'CIUDAD'));
    await prefs.remove('selectedProducts');
    List<String>? selectedProductsJson = [];
    await prefs.setStringList('selectedProducts', selectedProductsJson);
  }

  Future<double> getRangosByProducto(
      int codigo, int quantity, double precioFinal) async {
    DatabaseHelperRangoPrecioProducto dbHelper =
        DatabaseHelperRangoPrecioProducto();
    final rangoPrecioProducto = await dbHelper.getPrecioByProductoYCantidad(
        codigo, quantity, precioFinal);

    return rangoPrecioProducto;
  }
}

// Método para mostrar el diálogo de confirmación
Future<void> _showConfirmQuantityRangeDialog(
    BuildContext context, int quantity) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita cerrar el diálogo tocando fuera de él
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Selección'),
        content: Text(
            'La cantidad $quantity está dentro del rango específico. ¿Estás seguro de que deseas cambiar el precio?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
            },
          ),
          TextButton(
            child: Text('Confirmar'),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Cierra el diálogo y confirma el cambio
            },
          ),
        ],
      );
    },
  );
}
