import 'package:connectivity/connectivity.dart';

class InternetState {
  static final InternetState _singleton = new InternetState.initial();

  factory InternetState() {
    return _singleton;
  }

  ConnectivityResult connectivityResult = ConnectivityResult.none;
  bool isReady = false;

  InternetState.initial() {
    Connectivity().checkConnectivity().then((ConnectivityResult intialResult) {
      connectivityResult = intialResult;
    });
  }

  void update(ConnectivityResult result) {
    connectivityResult = result;
    isReady = true;
  }

  bool isConnected() {
    return InternetState.getBooleanStatus(connectivityResult);
  }

  static bool getBooleanStatus(ConnectivityResult result) {
    if (result == null) {
      return false;
    }

    return ConnectivityResult.wifi == result || ConnectivityResult.mobile == result;
  }
}