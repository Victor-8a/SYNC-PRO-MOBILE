import 'dart:async';
import 'package:sync_pro_mobile/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_pro_mobile/services/CheckInternetConnection.dart';

class ConnectionStatusCubit extends Cubit<ConnectionStatus> {
  late StreamSubscription _connectionSubscripcion;

  ConnectionStatusCubit() : super(ConnectionStatus.online) {
    _connectionSubscripcion = internetChecker.internetStatus().listen(emit);
  }

  @override
  Future<void> close() {
    _connectionSubscripcion.cancel();
    return super.close();
      }

  }
 
