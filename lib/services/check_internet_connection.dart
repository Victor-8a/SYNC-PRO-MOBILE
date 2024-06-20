import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatus {
  online,
  offline,
}

class CheckInternetConnection {
  final Connectivity _connectivity = Connectivity();

  final _controller = BehaviorSubject.seeded(ConnectionStatus.online);

  StreamSubscription? _connectionSubscripcion;
  CheckInternetConnection() {
    _checkInternetConnection();
  }

  Stream<ConnectionStatus> internetStatus() {
    _connectionSubscripcion ??= _connectivity.onConnectivityChanged
        .listen((_) => _checkInternetConnection());
    return _controller.stream;
  }

  Future<void> _checkInternetConnection() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final result = await InternetAddress.lookup('google.com');
   
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _controller.sink.add(ConnectionStatus.online);
        print('si hay conexion');
      } else {
        _controller.sink.add(ConnectionStatus.offline);
        print('no hay conexion');
      }
         print('VERIFICAR SI ESTA PASANDO ALGO');
      print(InternetAddress.lookup);
      
    } on SocketException catch (_) {
      _controller.sink.add(ConnectionStatus.offline);
    }
  }

  Future<void> close() async {
    await _connectionSubscripcion?.cancel();
    await _controller.close();
  }
}
