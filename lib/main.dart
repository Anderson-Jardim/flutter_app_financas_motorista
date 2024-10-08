import 'package:app_fingo/screens/login/login.dart';
import 'package:flutter/material.dart';

import 'screens/login/loading.dart';
import 'screens/login/welcome.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loading(),
    );
  }
}
 