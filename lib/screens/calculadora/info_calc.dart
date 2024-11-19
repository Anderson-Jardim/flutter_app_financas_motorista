import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard.dart';




class CalculadoraLucroScreen extends StatefulWidget {
  @override
  _CalculadoraLucroScreenState createState() => _CalculadoraLucroScreenState();
}

class _CalculadoraLucroScreenState extends State<CalculadoraLucroScreen> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF00ff75)),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Dashboard()),
                  (route) => false);
            },
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Calcule o lucro',
            style: GoogleFonts.poppins(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
            ),
            Text(
              'de cada corrida',
             style: GoogleFonts.poppins(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ff75),
                    ),
            ),
            SizedBox(height: 16),
            Text(
              'A calculadora irá permanecer como um botão na lateral do seu aparelho.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Basta tocar no botão para fazer o cálculo de cada corrida.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Ative a calculadora e comece a rodar. Você só precisa fazer isso uma vez.',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  isSwitched ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 18,
                    color: isSwitched ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(width: 8),
                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.black,
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
