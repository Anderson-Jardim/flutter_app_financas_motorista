
import 'package:app_fingo/screens/dashboard.dart';
import 'package:app_fingo/screens/login/welcome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

import '../register/register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null){
      _saveAndRedirectToHome(response.data as User);
    }
    else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}')
      ));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
    backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
          },
        ),
        
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.108),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                 
                      SizedBox(height: height * 0.02),

                    Container(
                      width: 400,
                      height: 40, 
                      child: Padding(
          padding:  EdgeInsets.all(1.0),
          child: Image(
            image: CachedNetworkImageProvider(
            maxWidth: 841,
            maxHeight: 250,
            logo02,     
            ),
            loadingBuilder: (context, child, loadingProgress){
              if(loadingProgress == null){
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.transparent,
                ),
              );
            },
            alignment: Alignment.topLeft,
          ),
        ),
                    ),

                      Container(        
                        alignment: Alignment.center,          
                        width: width * 0.9,
                        height: 106,  
                        child: Text(                      
                        'Bem vindo.',
                        style:  GoogleFonts.inter(
                          fontSize: constraints.maxWidth * 0.143,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),                 
                       ),
                      ),
                      SizedBox(height: 50),
                       Form(
                    key: formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: TextStyle(color: Colors.grey),
                          keyboardType: TextInputType.emailAddress,
                          controller: txtEmail,
                          validator: (val) => val!.isEmpty ? 'Email ou celular inválidos' : null,
                          decoration: InputDecoration(
                            
                           labelText: 'E-mail ou celular',
                           labelStyle: 
                            GoogleFonts.inter(  
                              fontSize: 20,
                            fontWeight: FontWeight.w600,
                             color: Color(0xFFD3D3D3),
                             ),
                             border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF171F20), ),
                             ),
                             focusedBorder: UnderlineInputBorder(         
                            borderSide: BorderSide(color: Color(0xFF171F20)),              
                               ),
                              )
                        ),

                        SizedBox(height: 30,),

                        TextFormField(
                          style: TextStyle(color: Colors.grey),
                          controller: txtPassword,
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'minímo 6 caracteres' : null,
                          decoration: InputDecoration(
                            
                           labelText: 'Senha',
                           labelStyle: 
                            GoogleFonts.inter(  
                              fontSize: 20,
                            fontWeight: FontWeight.w600,
                             color: Color(0xFFD3D3D3),
                             ),
                             border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF171F20), ),
                             ),
                             focusedBorder: UnderlineInputBorder(         
                            borderSide: BorderSide(color: Color(0xFF171F20),),              
                               ),
                              )
                        ),

                        SizedBox(height: height * 0.16),

                        loading? Center(child: CircularProgressIndicator(),)
                        :

                         ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()){
                              setState(() {
                                 loading = true; 
                                _loginUser();
                              });
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF00ff75),                        
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.02,
                            horizontal: width * 0.30
                            
                          ),
                          
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(121),
                          ),
                        ),
                        child: Text(
                          textAlign: TextAlign.center,
                          'Entrar',
                          style:   GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: constraints.maxWidth * 0.041,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                      ), 
                        SizedBox(height: 15,),
                       
                      ],
                    ),
                  ), 
                       

                      ElevatedButton(
                        onPressed: () {
                           /* Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Register()), (route) => false); */
                        },
                        style: ElevatedButton.styleFrom(

                          primary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.02,
                            horizontal: width * 0.14
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(121),
                            side: BorderSide(color: Colors.black,),
                            
                          ),
                        ),
                        child: Text(
                          
                          textAlign: TextAlign.center,
                          'Esqueci minha senha',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: constraints.maxWidth * 0.041,
                            fontWeight: FontWeight.w500,
                            ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      
                    
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}