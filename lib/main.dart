import 'package:app_fingo/screens/dashboard.dart';
import 'package:app_fingo/screens/login/login.dart';
import 'package:app_fingo/screens/calculadora/permissoes.dart';
import 'package:flutter/material.dart';

import 'screens/calculadora/valor_km.dart';
import 'screens/login/loading.dart';
import 'screens/login/welcome.dart';
import 'screens/calculadora/permissoes.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}