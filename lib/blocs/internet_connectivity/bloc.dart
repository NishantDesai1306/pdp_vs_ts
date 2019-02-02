import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/state.dart';

// didnt used normal flutter bloc because we want the state to be accessible without bloc
// hence we have mae InternetState class as singleton so that we can just change the members
// of the singleton instance of that class and broadcast an update event

class InternetChangeListener {
  static final InternetChangeListener _singleton = InternetChangeListener.initial();

  factory InternetChangeListener() {
    return _singleton;
  }

  final InternetState internetState = InternetState();
  final StreamController<InternetState> _changeController = StreamController<InternetState>.broadcast();
  
  StreamSubscription<ConnectivityResult> _internetConnectivityChangeListener;
  Stream<InternetState> get onChange => _changeController.stream;

  InternetChangeListener.initial() {
    _internetConnectivityChangeListener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      internetState.update(result);
      _changeController.add(internetState);
    });
  }

  cancelListener() {
    _changeController.close();
    _internetConnectivityChangeListener.cancel();
  }
}