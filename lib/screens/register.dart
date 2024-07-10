/* import 'dart:ui';

import 'package:app_fingo/screens/gastos.dart';
import 'package:app_fingo/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'home.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController
    emailornumberController = TextEditingController(),
    nameController = TextEditingController(), 
    userController = TextEditingController(),
    passwordController = TextEditingController();
    /* passwordConfirmController = TextEditingController(); */

  void _registerUser () async {
    ApiResponse response = await register(nameController.text, userController.text, emailornumberController.text, passwordController.text);
    if(response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } 
    /* else {
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}')
      ));
    } */
  }

  // Save and redirect to home
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>GastosPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.06), // Add some space at the top
                Container(
                  width: width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(                   
                        'Precisamos\nconhecer\nvocê.',
                        style: GoogleFonts.poppins(
                          fontSize: 45,
                          height: 1,
                          fontWeight: FontWeight.w800
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.05),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  
                 child: Column(
                  children: [
                    TextFormField(
                  controller: emailornumberController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    
                    labelText: 'Número ou e-mail',
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
                

                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número ou e-mail';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.04),
                TextFormField(

                  controller: nameController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome completo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.04),
                TextFormField(
                  controller: userController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nome de usuário',
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome de usuário';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.04),
                TextFormField(
                  controller: passwordController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Senha',
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
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha';
                    }
                    return null;
                  },
                ),

                  ],
                 ),
                  
                  
                  ),

                

                SizedBox(height: height * 0.05),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.30
                      ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(121),
                      ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                    _registerUser();
                  });
                    }

                  },
                  child: Text(
                    'Próximo',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: height * 0.025,
                        
                        ),
                  ),
                ),

               SizedBox(height: height * 0.02),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.30
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(121),
                      ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
                  },
                  child: Text(
                    'Anterior',
                    style:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: height * 0.025,
                        ),
                  ),
                ),

                  SizedBox(height: height * 0.05),
                const Text(
                  "Ao se cadastrar, você concorda com nossos\n termos, Política de privacidade e política de Cookies",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01), // Add some space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
} */