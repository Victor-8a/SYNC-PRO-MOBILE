String letras(String numero) {
  // Declara variables de tipo cadena
  // ignore: unused_local_variable
  String palabras = "", entero = "", dec = "", flag = "N";

  // Número negativo
  if (numero.startsWith("-")) {
    numero = numero.substring(1);
    palabras = "MENOS ";
  }

  // Dividir parte entera y decimal
  bool decimalFlag = false;
  for (int y = 0; y < numero.length; y++) {
    if (numero[y] == ".") {
      decimalFlag = true;
    } else {
      if (!decimalFlag) {
        entero += numero[y];
      } else {
        dec += numero[y];
      }
    }
  }

  if (dec.length == 1) {
    dec += "0"; // Asegúrate de que haya dos dígitos en la parte decimal
  }

  // Conversión de la parte entera
  if (int.tryParse(entero) != null && int.parse(entero) <= 999999999) {
    palabras += convertirEntero(entero).trim(); // Convertir parte entera
  } else {
    return "";
  }

  // Añadir "QUETZALES" siempre
  palabras += " QUETZALES";

  // Añadir la parte decimal si existe
  if (dec.isNotEmpty) {
    int decNum = int.parse(dec);
    if (decNum > 0) {
      palabras += " CON " + convertirEntero(dec) + " CENTAVOS";
    }
  }

  return palabras.trim();
}

String convertirEntero(String entero) {
  String palabras = "";
  int num;

  for (int y = entero.length - 1; y >= 0; y--) {
    num = entero.length - (y + 1);

    switch (y + 1) {
      case 3:
      case 6:
      case 9:
        // Asigna las palabras para las centenas
        switch (entero[num]) {
          case '1':
            if (entero[num + 1] == '0' && entero[num + 2] == '0') {
              palabras += "CIEN ";
            } else {
              palabras += "CIENTO ";
            }
            break;
          case '2':
            palabras += "DOSCIENTOS ";
            break;
          case '3':
            palabras += "TRESCIENTOS ";
            break;
          case '4':
            palabras += "CUATROCIENTOS ";
            break;
          case '5':
            palabras += "QUINIENTOS ";
            break;
          case '6':
            palabras += "SEISCIENTOS ";
            break;
          case '7':
            palabras += "SETECIENTOS ";
            break;
          case '8':
            palabras += "OCHOCIENTOS ";
            break;
          case '9':
            palabras += "NOVECIENTOS ";
            break;
        }
        break;
      case 2:
      case 5:
      case 8:
        // Asigna las palabras para las decenas
        switch (entero[num]) {
          case '1':
            switch (entero[num + 1]) {
              case '0':
                palabras += "DIEZ ";
                break;
              case '1':
                palabras += "ONCE ";
                break;
              case '2':
                palabras += "DOCE ";
                break;
              case '3':
                palabras += "TRECE ";
                break;
              case '4':
                palabras += "CATORCE ";
                break;
              case '5':
                palabras += "QUINCE ";
                break;
              default:
                palabras += "DIECI";
            }
            break;
          case '2':
            if (entero[num + 1] == '0') {
              palabras += "VEINTE ";
            } else {
              palabras += "VEINTI";
            }
            break;
          case '3':
            palabras += entero[num + 1] == '0' ? "TREINTA " : "TREINTA Y ";
            break;
          case '4':
            palabras += entero[num + 1] == '0' ? "CUARENTA " : "CUARENTA Y ";
            break;
          case '5':
            palabras += entero[num + 1] == '0' ? "CINCUENTA " : "CINCUENTA Y ";
            break;
          case '6':
            palabras += entero[num + 1] == '0' ? "SESENTA " : "SESENTA Y ";
            break;
          case '7':
            palabras += entero[num + 1] == '0' ? "SETENTA " : "SETENTA Y ";
            break;
          case '8':
            palabras += entero[num + 1] == '0' ? "OCHENTA " : "OCHENTA Y ";
            break;
          case '9':
            palabras += entero[num + 1] == '0' ? "NOVENTA " : "NOVENTA Y ";
            break;
        }
        break;
      case 1:
      case 4:
      case 7:
        // Asigna las palabras para las unidades
        switch (entero[num]) {
          case '1':
            palabras += (num == entero.length - 1) ? "UNO " : "UN ";
            break;
          case '2':
            palabras += "DOS ";
            break;
          case '3':
            palabras += "TRES ";
            break;
          case '4':
            palabras += "CUATRO ";
            break;
          case '5':
            palabras += "CINCO ";
            break;
          case '6':
            palabras += "SEIS ";
            break;
          case '7':
            palabras += "SIETE ";
            break;
          case '8':
            palabras += "OCHO ";
            break;
          case '9':
            palabras += "NUEVE ";
            break;
        }
        break;
    }

    // Asigna la palabra mil
    if (y == 3) {
      if (entero.substring(3, 6) != "000") palabras += "MIL ";
    }

    // Asigna la palabra millón
    if (y == 6) {
      if (entero.length == 7 && entero[0] == '1') {
        palabras += "MILLON ";
      } else {
        palabras += "MILLONES ";
      }
    }
  }

  return palabras
      .trim(); // Retorna sin espacios en blanco al principio o al final
}
