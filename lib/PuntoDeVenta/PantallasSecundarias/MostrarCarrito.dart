import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasSecundarias/FinalizarCompra.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/AperturaCajaActiva.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/VerificarExistencia.dart';
import 'package:sync_pro_mobile/db/dbCarrito.dart';

class MostrarCarrito extends StatefulWidget {
  @override
  _MostrarCarritoState createState() => _MostrarCarritoState();
}

class _MostrarCarritoState extends State<MostrarCarrito> {
  Map<Product, int> _cart = {};
  Map<Product, double> _selectedPrices = {};
  bool _isLoading = false;
  bool _canFinalizePurchase =
      true; // Nueva variable para habilitar/deshabilitar la compra
  final DatabaseHelperCarrito _databaseHelper = DatabaseHelperCarrito();
  Map<Product, double> _selectedDiscounts = {};

  @override
  void initState() {
    _loadCartFromDatabase();
    super.initState();
  }

  Future<void> _loadCartFromDatabase() async {
    setState(() {
      _isLoading = true;
    });

    final cartItems = await _databaseHelper.getCarritoItems();
    Map<Product, int> cartMap = {};
    for (var item in cartItems) {
      final product = Product.fromMap(item);
      cartMap[product] = item['Cantidad'] as int;

      // Convertir precio a double para evitar problemas de tipo
      _selectedPrices[product] = (item['Precio'] as num).toDouble();

      // Convertir el descuento a double o inicializarlo a 0 si no existe
      _selectedDiscounts[product] = item['PorcDescuento'] != null
          ? (item['PorcDescuento'] as num).toDouble()
          : 0.0;
    }

    setState(() {
      _cart = cartMap;
      _isLoading = false;
    });
  }

  Future<void> _updateDiscountInDatabase(int codigo, double discount) async {
    await _databaseHelper.updateCarritoDiscount(codigo, discount);
  }

  // Actualizar la cantidad del producto en la base de datos
  Future<void> _updateQuantityInDatabase(Product product, int quantity) async {
    if (quantity > 0) {
      await _databaseHelper.updateCarritoItem(product.codigo, quantity);
      setState(() {
        _cart[product] = quantity; // Actualizar solo la cantidad del producto
      });
    } else {
      await _databaseHelper.removeCarritoItem(product.codigo);
      setState(() {
        _cart.remove(product); // Eliminar el producto del carrito
      });
    }
  }

  double _calculateSubtotal(Product product, int quantity) {
    double price = _selectedPrices[product] ?? 0.0;
    double discount = _selectedDiscounts[product] ?? 0.0;
    double discountAmount = (price * discount / 100);
    double finalPrice = price - discountAmount;
    return finalPrice * quantity;
  }

  Future<void> _updatePriceInDatabase(int codigo, double price) async {
    await _databaseHelper.updateCarritoPrice(codigo, price);
  }

  void finalizarCompra() async {
    dynamic aperturaResult = await getAperturaCajaActiva();

    if (aperturaResult == -1) {
      mostrarMensajeError(
        'No puedes finalizar la compra, no cuentas con apertura de caja.',
      );

      setState(() {
        _canFinalizePurchase = false;
      });

      return;
    }

    if (aperturaResult == 0 || aperturaResult is int) {
      List<Product> productosInsuficientes = await validarExistencias(_cart);

      if (productosInsuficientes.isEmpty) {
        setState(() {
          _canFinalizePurchase = true;
        });
        _navegarAFinalizarCompra();
      } else {
        mostrarMensajeError(_generarMensajeError(productosInsuficientes));
      }
    }
  }

  void _navegarAFinalizarCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalizarCompra(
          selectedClient: Cliente(),
        ),
      ),
    );
  }

  String _generarMensajeError(List<Product> productosInsuficientes) {
    StringBuffer mensajeError =
        StringBuffer("Algunos productos exceden la existencia disponible:\n");

    for (var producto in productosInsuficientes) {
      int cantidadDisponible = producto.existencia;
      mensajeError.writeln(
          "${producto.descripcion}: Solo hay ${cantidadDisponible} disponibles.");
    }

    return mensajeError.toString();
  }

  void mostrarMensajeError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)), // Bordes redondeados
        title: Row(
          children: [
            Icon(Icons.error_outline,
                color: Colors.red, size: 28), // Icono de advertencia
            SizedBox(width: 10), // Espacio entre el icono y el texto
            Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mensaje,
                style: TextStyle(
                    fontSize: 16,
                    height: 1.4), // Ajuste de tamaño y espacio entre líneas
              ),
              SizedBox(height: 20), // Espacio entre el texto y el botón
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Aceptar',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor:
                  Colors.red, // Fondo del botón rojo para llamar la atención
              padding: EdgeInsets.symmetric(
                  vertical: 12, horizontal: 20), // Tamaño del botón
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)), // Bordes redondeados
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcular el subtotal y el total
    double subtotal =
        _cart.entries.fold(0.0, (double sum, MapEntry<Product, int> entry) {
      return sum +
          (_selectedPrices[entry.key]! *
              entry.value); // Precio por cantidad sin descuento
    });

    double totalDescuento =
        _cart.entries.fold(0.0, (double sum, MapEntry<Product, int> entry) {
      double price = _selectedPrices[entry.key]!;
      int quantity = entry.value;
      double discount = (_selectedDiscounts[entry.key] ?? 0) / 100;

      // Calcular el descuento total aplicado para este producto
      double discountAmount = price * discount * quantity;
      return sum + discountAmount; // Suma el descuento aplicado
    });

    double totalFinal =
        subtotal - totalDescuento; // Total final con descuentos aplicados

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrito',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Acción del carrito
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100], // Fondo suave
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cart.keys.length,
                      itemBuilder: (context, index) {
                        final product = _cart.keys.elementAt(index);
                        final quantity = _cart[product]!;
                        final TextEditingController _controller =
                            TextEditingController(text: quantity.toString());

                        List<double> validPrices = [
                          product.precioFinal,
                          product.precioB,
                          product.precioC,
                          product.precioD
                        ].where((price) => price > 0).toList();

                        return Card(
                          elevation: 7, // Sombra para un efecto 3D
                          margin: EdgeInsets.symmetric(vertical: 9),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.descripcion,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Q${_selectedPrices[product]?.toStringAsFixed(2) ?? "0.00"} x $quantity',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700]),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Subtotal: Q${_calculateSubtotal(product, quantity).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Row para Dropdown, Descuento y Cantidad
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Dropdown para seleccionar precio
                                    Expanded(
                                      child: DropdownButtonFormField<double>(
                                        value: _selectedPrices[product],
                                        decoration: InputDecoration(
                                          labelText: 'Precio',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 12.0),
                                        ),
                                        isExpanded: true,
                                        onChanged: (double? newValue) {
                                          if (newValue != null &&
                                              validPrices.contains(newValue)) {
                                            setState(() {
                                              _selectedPrices[product] =
                                                  newValue;
                                            });
                                            _updatePriceInDatabase(
                                                product.codigo, newValue);
                                          }
                                        },
                                        items: validPrices
                                            .map<DropdownMenuItem<double>>(
                                                (double value) {
                                          return DropdownMenuItem<double>(
                                            value: value,
                                            child: Text(
                                                'Q${value.toStringAsFixed(2)}',
                                                style: TextStyle(fontSize: 12)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    // Campo de descuento
                                    // Campo de descuento
                                    SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: _selectedDiscounts[product]
                                                    ?.toString() ??
                                                "0"),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onSubmitted: (value) {
                                          double? newDiscount =
                                              double.tryParse(value);
                                          if (newDiscount != null &&
                                              newDiscount >= 0 &&
                                              newDiscount <= 100) {
                                            setState(() {
                                              _selectedDiscounts[product] =
                                                  newDiscount;
                                            });
                                            _updateDiscountInDatabase(
                                                product.codigo, newDiscount);
                                          } else {
                                            setState(() {
                                              _selectedDiscounts[product] =
                                                  _selectedDiscounts[product] ??
                                                      0;
                                            });
                                          }
                                        },
                                        style: TextStyle(fontSize: 10),
                                        decoration: InputDecoration(
                                          labelText: 'Desc',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 12.0),
                                        ),
                                      ),
                                    ),

                                    // Controles de cantidad
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove_circle,
                                              color: Colors.red, size: 20),
                                          onPressed: () {
                                            if (quantity > 1) {
                                              _updateQuantityInDatabase(
                                                  product, quantity - 1);
                                            } else {
                                              _updateQuantityInDatabase(
                                                  product, 0);
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: TextField(
                                            controller: _controller,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.end,
                                            onSubmitted: (value) {
                                              int? newQuantity =
                                                  int.tryParse(value);
                                              if (newQuantity != null &&
                                                  newQuantity >= 0) {
                                                _updateQuantityInDatabase(
                                                    product, newQuantity);
                                              } else {
                                                _controller.text =
                                                    quantity.toString();
                                              }
                                            },
                                            style: TextStyle(fontSize: 14),
                                            decoration: InputDecoration(
                                              labelText: 'Cant',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 3.0,
                                                      vertical: 4.0),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add_circle,
                                              color: Colors.green, size: 20),
                                          onPressed: () {
                                            _updateQuantityInDatabase(
                                                product, quantity + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Subtotal: Q${subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            SizedBox(
                                height: 4), // Reducir el tamaño del espaciado
                            Text(
                              'Descuento: Q${totalDescuento.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Total: Q${totalFinal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                10), // Mantener algo de separación entre los textos y el botón
                        GestureDetector(
                          onTap: _cart.isEmpty || !_canFinalizePurchase
                              ? null
                              : () {
                                  finalizarCompra();
                                },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0), // Ajustar el padding del botón
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 5.0,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Finalizar Compra',
                                style: TextStyle(
                                  fontSize:
                                      16, // Reducir ligeramente el tamaño de la fuente del botón
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
