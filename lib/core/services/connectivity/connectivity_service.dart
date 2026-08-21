import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

abstract interface class IConnectivityService {
  /// Emits `true` when the device has at least one active network
  /// interface, `false` when it has none (airplane mode, no signal, etc).
  Stream<bool> get onStatusChanged;

  Future<bool> get isOnline;
}

@LazySingleton(as: IConnectivityService)
class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get onStatusChanged =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }
}
