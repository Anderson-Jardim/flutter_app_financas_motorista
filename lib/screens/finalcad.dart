import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalCad extends StatefulWidget {
  @override
 _FinalCadState createState() => _FinalCadState();
}

class _FinalCadState extends State<FinalCad> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Tudo pronto.',
                  style: GoogleFonts.poppins(
                          fontSize: 45,
                          height: 1,
                          fontWeight: FontWeight.w700
                        ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Você pode alterar esses dados\n a qualquer momento.',
                  style: GoogleFonts.poppins(
                          fontSize: 16,
                          height: 1,
                          fontWeight: FontWeight.w400
                        ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                SizedBox(
                  
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.04,
                      horizontal: width * 0.20
                      ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Entrar no app',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: height * 0.025,
                        
                        ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}