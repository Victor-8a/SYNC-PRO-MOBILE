import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart';
import 'package:sync_pro_mobile/db/dbRangoPrecioProducto.dart';

class SeleccionarProducto extends StatefulWidget {
  final List<Product> productos;

  SeleccionarProducto({Key? key, required this.productos}) : super(key: key);

  @override
  _SeleccionarProductoState createState() => _SeleccionarProductoState();
}

class _SeleccionarProductoState extends State<SeleccionarProducto> {
  List<Product> _selectedProducts = [];
  Map<Product, double> _selectedProductPrices = {};
  Map<Product, int> _selectedProductQuantities = {};
  Map<Product, double> _discounts = {};
  List<Product> _filteredProducts = [];
  List<bool> _productSelected = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProductsFromLocalDatabase();
    _productSelected = List<bool>.filled(widget.productos.length, false);
    _filteredProducts = List.from(widget.productos);
    _searchController.addListener(_onSearchChanged);

    // Inicializar _selectedProductPrices, _selectedProductQuantities y _discounts por defecto
    for (var product in _selectedProducts) {
      _selectedProductPrices[product] = product.precioFinal;
      _selectedProductQuantities[product] = 1;
      _discounts[product] = 0;
    }
  }

  Future<List<Product>> getProductsFromLocalDatabase() async {
    final dbHelper = DatabaseHelperProducto(); // Usar la versión de dbProducto
    List<Product> products = await dbHelper.getProducts();
    return products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

void _onSearchChanged() {
  String searchTerm = _searchController.text.toLowerCase();
  setState(() {
    // Divide el término de búsqueda en palabras individuales
    List<String> searchTerms = searchTerm.split(' ').where((term) => term.isNotEmpty).toList();

    _filteredProducts = widget.productos.where((product) {
      // Obtiene todos los valores del producto como una sola lista de cadenas en minúsculas
      List<String> productValues = product.toMap().values
          .map((value) => value.toString().toLowerCase())
          .toList();

      // Verifica si todos los términos de búsqueda están presentes en alguna de las cadenas del producto
      return searchTerms.every((term) =>
        productValues.any((value) => value.contains(term))
      );
    }).toList();
  });
}

void _showPrecioRangos(BuildContext context, int codigo) async {
  // Obtiene los rangos de precio para el producto con el código dado
  final priceRanges = await DatabaseHelperRangoPrecioProducto().getRangosByProductoBarras(codigo);

  // Verifica si se encontraron rangos de precios
  // ignore: unnecessary_null_comparison
  if (priceRanges == null || priceRanges.isEmpty) {
    print('No se encontraron rangos de precios.');
    return;
  }

  // Filtra los rangos para eliminar duplicados
  final seenRanges = <String>{};
  final uniqueRanges = priceRanges.where((range) {
    final rangeString = '${range.cantidadInicio}-${range.cantidadFinal}-${range.precio}';
    if (seenRanges.contains(rangeString)) {
      return false;
    } else {
      seenRanges.add(rangeString);
      return true;
    }
  }).toList();

  // Construye el contenido del diálogo con todos los rangos únicos
  final rangeWidgets = <Widget>[];
  for (var i = 0; i < uniqueRanges.length; i++) {
    final range = uniqueRanges[i];
    rangeWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0), // Espaciado entre rangos
        child: Row(
          children: [
            Expanded(
              child:
              
               Text(
              
                
                'Cantidad: ${range.cantidadInicio} - ${range.cantidadFinal}, \nPrecio: Q${range.precio}',
                style: TextStyle(fontSize: 16.0), // Ajuste del tamaño de fuente
              ),
            ),
          ],
        ),
      ),
    );
    if (i < uniqueRanges.length - 1) {
      rangeWidgets.add(Divider()); // Agrega un Divider entre los rangos
    }
  }

  // Muestra el diálogo con los rangos de precios
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rangos de Precio para ${uniqueRanges[0].descripcion}  \n ${uniqueRanges[0].barras}', ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: rangeWidgets,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.blue,
              ),
              cursorColor: Colors.blue,
            ),
          ),
          Expanded(
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      color: Colors.blue.withOpacity(0),
    ),
    child: ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ListTile(
          title: Text(
            product.descripcion,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Barras: ${product.barras}', // Muestra el código de barras
              ),
              Text(
                'Precio: Q${product.precioFinal.toStringAsFixed(2)}',
              ),
              Text(
                'Existencia: ${product.existencia}',
              ),
              Text(
                'Precio B: Q${product.precioB.toStringAsFixed(2)}',
              ),
              Text(
                'Precio C: Q${product.precioC.toStringAsFixed(2)}',
              ),
              Text(
                'Precio D: Q${product.precioD.toStringAsFixed(2)}',
              ),
              Text(
                'Marca: ${product.marcas}',
              ),
              Text(
                'Categoría: ${product.categoriaSubCategoria}',
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.info_outline,
                color: _productSelected[index] ? Colors.blue : null),
            tooltip: 'Información',
            color: Colors.blue,
            iconSize: 30,
            onPressed: () {
              _showPrecioRangos(context, product.codigo);
            },
          ),
          onTap: _productSelected[index]
              ? null
              : () {
                  Navigator.pop(context, product);
                  setState(() {
                    _productSelected[index] = true;
                  });
                },
        );
      },
    ),
  ),
),

        ],
      ),
    );
  }
}
