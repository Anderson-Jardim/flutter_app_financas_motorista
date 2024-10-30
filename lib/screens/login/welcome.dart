import 'package:app_fingo/constant.dart';
import 'package:app_fingo/screens/login/login.dart';
import 'package:app_fingo/screens/register/register.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
    backgroundColor: Color(0xFF171f20),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                 
                     SizedBox(height: height * 0.02),

                    Container(
                      width: 300,
                      height: 130, 
                      child: 
                      Padding(
          padding:  EdgeInsets.all(1.0),
          child: Image(
            image: CachedNetworkImageProvider(
            maxWidth: 782,
            maxHeight: 400,
            logo01,     
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
                        width: 300,
                        height: 106,  
                        child: Text(                      
                        'Olá!',
                        style:  GoogleFonts.poppins(
                          fontSize: constraints.maxWidth * 0.190,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),                 
                       ),
                      ),
                      
                      Container(
                        width: 300, 
                        child: Text(
                        'Pronto para\nlucrar mais?',
                        style: GoogleFonts.poppins(  
                        fontSize: constraints.maxWidth * 0.095,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF00ff75),
                        letterSpacing: 2,
                        height: 1
                         ), 
                      ),
                      ),
                       SizedBox(height: height * 0.26),

                      ElevatedButton(
                        onPressed: () {
                           Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Register()), (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.02,
                            horizontal: width * 0.17
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(121),
                          ),
                        ),
                        child: Text(
                          
                          textAlign: TextAlign.center,
                          'Criar nova conta',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: constraints.maxWidth * 0.050,
                            fontWeight: FontWeight.w400,
                            ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false);
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
                            fontSize: constraints.maxWidth * 0.050,
                            fontWeight: FontWeight.w400,
                          )
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

