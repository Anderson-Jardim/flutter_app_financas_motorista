import 'package:flutter/material.dart';

import 'permissoes.dart';
import 'valor_km.dart';

class TelaComBotoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela com Botões'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Permissoes()), 
                          (route) => false
                        );
              },
              child: Text('Habilitar Permissões'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                 Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => ganhoPorKm()), 
                          (route) => false
                        );
              },
              child: Text('Ganho por KM'),
            ),
          ],
        ),
      ),
    );
  }
}
