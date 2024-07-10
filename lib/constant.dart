// ----- STRINGS ------
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const baseURL = 'http://192.168.0.118:8000/api';
const loginURL = baseURL + '/login';
const registerURL = baseURL + '/register';
const expensesURL = baseURL + '/expenses';
const logoutURL = baseURL + '/logout';
const InfooneURL = baseURL + '/infoone';
const meslucrosURL = baseURL + '/meslucros';
const userURL = baseURL + '/user';
const postsURL = baseURL + '/posts';
const commentsURL = baseURL + '/comments';
const classcorridasURL = baseURL + '/classcorridas';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';


// --- input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                      
                      ),
                       focusedBorder: OutlineInputBorder(
                     
                    borderSide: BorderSide(color: Colors.black87, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
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
                        color: Colors.white,
                        fontSize: FontStyle,
                        ),),
    style: ElevatedButton.styleFrom(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black),
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
                        color: Colors.white,
                        fontSize: FontStyle,
                        ),),
    style: ElevatedButton.styleFrom(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.grey),
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

