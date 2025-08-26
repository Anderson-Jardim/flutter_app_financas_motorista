import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard.dart';

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
        backgroundColor: Color(0xFF171f20),
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
                          fontWeight: FontWeight.w700,
                          color: Colors.white
                        ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Você pode alterar esses dados\n a qualquer momento.',
                  style: GoogleFonts.poppins(
                          fontSize: 16,
                          height: 1,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                        ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                SizedBox(
                  
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00FF75),
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.03,
                      horizontal: width * 0.10
                      ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
                  },
                  child: Text(
                    'Vamos rodar!',
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: height * 0.040,
                        fontWeight: FontWeight.w700
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