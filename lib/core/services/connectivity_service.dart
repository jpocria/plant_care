import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Emite os resultados de conectividade atual.
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Retorna true se há ao menos uma conexão ativa (wifi, mobile, ethernet).
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  bool _hasConnection(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  /// Stream de bool: true = conectado, false = sem conexão.
  Stream<bool> get connectionStream =>
      onConnectivityChanged.map(_hasConnection);
}