// ----- STRINGS ------
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const baseURL = 'http://192.168.0.118:8000/api';
/* const baseURL = 'https://506e-190-89-190-130.ngrok-free.app/api'; */
const loginURL = baseURL + '/login';
const registerURL = baseURL + '/register';
const expensesURL = baseURL + '/expenses';
const logoutURL = baseURL + '/logout';
const InfooneURL = baseURL + '/infoone';
const meslucrosURL = baseURL + '/meslucros';
const lucroCorridaURL = baseURL + '/monthly-earnings';
const userURL = baseURL + '/user';
const postsURL = baseURL + '/posts';
const commentsURL = baseURL + '/comments';
const classcorridasURL = baseURL + '/classcorridas';
const saidaLucro = baseURL + '/subtract-from-lucro';
const saidaLucroAdd = baseURL + '/add-saida-lucro';
const saidaLucroGet = baseURL + '/get-saida-lucro';
const getGastos = baseURL + '/get-saida-lucro';
const getLerCorrida = baseURL + '/lercorrida';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';


// --- input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,

      labelStyle: 
        GoogleFonts.poppins(  
          fontWeight: FontWeight.w500,
           color: Colors.white,
          
                 ),
                focusedBorder: OutlineInputBorder(         
                    borderSide: BorderSide(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                    ),
                    enabledBorder: OutlineInputBorder(

                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 3
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  ),
    );
}


// button
ElevatedButton kTextButton(String label, Function onPressed, Padding, FontStyle){
  return ElevatedButton( 
    child: Text(label, style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: FontStyle,
                        fontWeight: FontWeight.w400,
                        ),),
    style: ElevatedButton.styleFrom(
      backgroundColor: MaterialStateColor.resolveWith((states) => Color(0xFF00ff75)),
      padding: Padding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(121),
                      ),
    ),
    onPressed: () => onPressed(),
  );
}

// button anterior
ElevatedButton kButtonAnterior(String label, Function onPressed, Padding, FontStyle){
  return ElevatedButton( 
    child: Text(label, style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: FontStyle,
                        fontWeight: FontWeight.w400,
                        ),),
    style: ElevatedButton.styleFrom(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
      padding: Padding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(121),
                      ),
    ),
    onPressed: () => onPressed(),
  );
}

// loginRegisterHint
Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
        child: Text(label, style:TextStyle(color: Colors.blue)),
        onTap: () => onTap()
      )
    ],
  );
}


// likes and comment btn

Expanded kLikeAndComment (int value, IconData icon, Color color, Function onTap) {
  return Expanded(
      child: Material(
        child: InkWell(
          onTap: () => onTap(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color,),
                SizedBox(width:4),
                Text('$value')
              ],
            ),
          ),
        ),
      ),
    );
}

