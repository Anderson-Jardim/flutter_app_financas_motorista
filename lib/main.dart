import 'package:app_fingo/screens/gastos.dart';
import 'package:app_fingo/screens/register.dart';
import 'package:flutter/material.dart';

import 'screens/loading.dart';
import 'screens/welcome.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
