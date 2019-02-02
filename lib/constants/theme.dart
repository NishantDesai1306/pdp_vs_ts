import 'package:flutter/material.dart';

ThemeData LIGHT_THEME = ThemeData(
  primarySwatch: Colors.blue,
  backgroundColor: Colors.grey[50],
  primaryColor: Colors.blue,
  accentColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.grey[50],

  brightness: Brightness.dark,
  iconTheme: IconThemeData(
    color: Colors.white,
  ),

  dialogBackgroundColor: Colors.grey[50],
  textSelectionHandleColor: Colors.blue,

  textTheme: TextTheme(
    title: TextStyle( color: Colors.white ),
    body1: TextStyle( color: Colors.black87 ),
    body2: TextStyle( color: Colors.black54 ),
  )
);


const DARK_BLUE_COLOR = {
  'R': 25,
  'G': 74,
  'B': 142
};
Color getDarkBlueColor (double opacity) => Color.fromRGBO(
  DARK_BLUE_COLOR['R'],
  DARK_BLUE_COLOR['G'],
  DARK_BLUE_COLOR['B'],
  opacity
);

Map<int, Color> darkBlueColor = {
  50: getDarkBlueColor(.1),
  100: getDarkBlueColor(.2),
  200: getDarkBlueColor(.3),
  300: getDarkBlueColor(.4),
  400: getDarkBlueColor(.5),
  500: getDarkBlueColor(.6),
  600: getDarkBlueColor(.7),
  700: getDarkBlueColor(.8),
  800: getDarkBlueColor(.9),
  900: getDarkBlueColor(1),
};

ThemeData DARK_THEME = ThemeData(
  primarySwatch: MaterialColor(0xFF194A8E, darkBlueColor),
  backgroundColor: Colors.grey[900],
  primaryColor: darkBlueColor[900],
  accentColor: darkBlueColor[500],
  scaffoldBackgroundColor: Colors.grey[900],
  dialogBackgroundColor: Colors.grey[900],
  textSelectionHandleColor: darkBlueColor[900],

  brightness: Brightness.dark,
  iconTheme: IconThemeData(
    color: Colors.white,
  ),

  textTheme: TextTheme(
    title: TextStyle( color: Colors.white ),
    body1: TextStyle( color: Colors.white70 ),
    body2: TextStyle( color: Colors.white54 ),
  )
);
