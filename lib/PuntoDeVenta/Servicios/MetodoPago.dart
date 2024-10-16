import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/services/BancosService.dart';

void showPaymentOptionsModal(
    BuildContext context, double total, Function(String) onSelected) {
  final List<String> _paymentOptions = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
    'Cheque'
  ];

  final List<String> _cardOptions = ['American Express', 'Mastercard', 'Visa'];

  String selectedPayment = _paymentOptions.first;
  String selectedBankOrCard = '';
  List<String> _banks = []; // Lista vacía de bancos
  String referenceNumber = '';
  double amount = total;
  double change = 0.0;

  TextEditingController amountController =
      TextEditingController(text: total.toStringAsFixed(2));

  // Método para cargar los bancos solo una vez
  void loadBanks() async {
    List<String> banks = await fetchBanks();
    if (banks.isNotEmpty) {
      _banks = banks; // Asignar la lista de bancos cargados
    }
  }

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      // Cargar los bancos al abrir el modal
      loadBanks();

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Método de Pago',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Seleccione su método de pago preferido y complete la información requerida.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  DropdownButtonFormField<String>(
                    value: selectedPayment,
                    items: _paymentOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPayment = newValue!;
                        selectedBankOrCard = ''; // Resetear el banco o tarjeta
                        if (selectedPayment == 'Efectivo') {
                          change = (amount > total) ? amount - total : 0.0;
                        } else {
                          change = 0.0;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Método de Pago',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      hintText: 'Ingrese el monto',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? total;
                        if (selectedPayment == 'Efectivo') {
                          change = (amount > total) ? amount - total : 0.0;
                        } else {
                          change = 0.0;
                        }
                      });
                    },
                  ),
                  if (selectedPayment == 'Tarjeta' &&
                      _cardOptions.isNotEmpty) ...[
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedBankOrCard.isNotEmpty
                          ? selectedBankOrCard
                          : null,
                      items: _cardOptions.map((String card) {
                        return DropdownMenuItem<String>(
                          value: card,
                          child: Text(card),
                        );
                      }).toList(),
                      onChanged: (String? newCard) {
                        setState(() {
                          selectedBankOrCard = newCard!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Tarjeta',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                  if (selectedPayment != 'Efectivo' &&
                      selectedPayment != 'Tarjeta' &&
                      _banks.isNotEmpty) ...[
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedBankOrCard.isNotEmpty
                          ? selectedBankOrCard
                          : null,
                      items: _banks.map((String bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                      onChanged: (String? newBank) {
                        setState(() {
                          selectedBankOrCard = newBank!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Banco',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                  if (selectedPayment != 'Efectivo') ...[
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Número de referencia',
                        hintText: 'Ingrese el número de referencia',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          referenceNumber = value;
                        });
                      },
                    ),
                  ],
                  if (selectedPayment == 'Efectivo' && change > 0) ...[
                    SizedBox(height: 16),
                    Text(
                      'Vuelto: \Q${change.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total a pagar: \Q${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (amount < total) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'El monto no puede ser menor al total a pagar.'),
                              ),
                            );
                            return;
                          }

                          if ((selectedPayment == 'Efectivo' &&
                                  amount >= total) ||
                              (selectedPayment != 'Efectivo' &&
                                  referenceNumber.isNotEmpty)) {
                            onSelected(selectedPayment);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Por favor, complete todos los campos correctamente.'),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.check),
                        label: Text('Pagar'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
