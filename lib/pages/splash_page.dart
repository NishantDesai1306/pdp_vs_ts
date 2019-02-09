import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/bloc.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/state.dart';
import 'package:pdp_vs_ts/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  static final String route = '/splash';
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  InternetChangeListener internetChangeListener = InternetChangeListener();
  InternetState internetState = InternetState();
  StreamSubscription internetChangeSubscription;

  _SplashPageState() {
    if (internetState.isReady) {
      goToMainPage();
    }

    internetChangeSubscription = internetChangeListener.onChange.listen((data) {
      if (internetState.isReady) {
        goToMainPage();
      }
    });
  }

  goToMainPage() {
    Navigator.of(context).pushReplacementNamed(MainPage.route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Image.asset('assets/images/logo.png'),        
      ),
    );
  }

  @override
  void dispose() {
    internetChangeSubscription.cancel();
    super.dispose();   
  }
}