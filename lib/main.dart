import 'package:flutter/material.dart';
// import 'package:background_fetch/background_fetch.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/bloc.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:pdp_vs_ts/constants/theme.dart';
import 'package:pdp_vs_ts/pages/about_me.dart';

import 'package:pdp_vs_ts/pages/main_page.dart';
import 'package:pdp_vs_ts/pages/splash_page.dart';

/// This "Headless Task" is run when app is terminated.
// void backgroundFetchHeadlessTask() async {
//   print('[BackgroundFetch] Headless event received.');
//   BackgroundFetch.finish();
// }

void main() {
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  // Configure BackgroundFetch.
  // BackgroundFetch.configure(BackgroundFetchConfig(
  //     minimumFetchInterval: 15,
  //     startOnBoot: true,
  //     stopOnTerminate: false,
  //     enableHeadless: true
  // ), () async {
  //   print('background fetch event received 123');
  //   BackgroundFetch.finish();
  // });

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
          home: SplashPage(),
          routes: <String, WidgetBuilder>{
            SplashPage.route: (BuildContext context) => SplashPage(),
            MainPage.route: (BuildContext context) => MainPage(),
            AboutMePage.route: (BuildContext context) => AboutMePage(),
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
