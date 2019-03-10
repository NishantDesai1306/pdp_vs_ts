import 'package:flutter/material.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/bloc.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:pdp_vs_ts/constants/theme.dart';
import 'package:pdp_vs_ts/pages/app_explanation.dart';

import 'package:pdp_vs_ts/pages/main_page.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  InternetChangeListener internetStateChange = InternetChangeListener();
  
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => brightness == Brightness.light ? LIGHT_THEME : DARK_THEME,
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'T-Series vs PewDiePie',
          theme: theme,
          routes: <String, WidgetBuilder>{
            MainPage.route: (BuildContext context) => MainPage(),
            AppExplanation.route: (BuildContext context) => AppExplanation(),
          }
        );
      }
    );
  }

  @override
  void dispose() {
    internetStateChange.cancelListener();
    super.dispose();
  }
}
