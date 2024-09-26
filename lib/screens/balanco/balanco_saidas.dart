import 'package:app_fingo/screens/balanco/meu_balanco.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdicionarSaida extends StatefulWidget {
  @override
  State<AdicionarSaida> createState() => _AdicionarSaidaState();
}

class _AdicionarSaidaState extends State<AdicionarSaida> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF00ff75)),
          onPressed: () {
             Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Balanco()), 
                          (route) => false);

          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.05),
            RichText(
              text: TextSpan(
                text: 'Adicione tudo\n',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'o que sair.',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ff75),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.04),
            // Campo de texto 'Tipo de saída'
            TextField(
              decoration: InputDecoration(
                labelText: 'Tipo de saída',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: height * 0.02),
            // Campo de texto 'Valor da saída'
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor da saída',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: height * 0.04),
            // Opções Gasto ou Lucro
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Gasto',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    value: false,
                    onChanged: (newValue) {},
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Lucro',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    value: false,
                    onChanged: (newValue) {},
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.04),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: width * 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Ação ao adicionar saída
                },
                child: Text(
                  'Adicionar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

