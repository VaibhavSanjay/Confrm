import 'package:flutter/material.dart';

final List<String> daysOfWeek = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
final List<ColorSwatch> availableColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green,
  Colors.blue, Colors.indigo, Colors.purple, Colors.grey, const MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100:Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  )];
final List<String> availableColorsStrings = ['Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Indigo', 'Purple', 'Gray', 'White'];
const int maxArchiveTasks = 500;
const int maxTasks = 50;
const double filterDistance = 20; // 20 Meters
const double alertDistance = 1000; // 1000 Meters