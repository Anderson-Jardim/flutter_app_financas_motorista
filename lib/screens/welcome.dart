import 'package:app_fingo/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  
                    SizedBox(height: 70),

                    Container(
                      
                      width: 300,
                      height: 106,
                      
                      child: Text(
                      
                      
                      'Olá!',
                      style:  GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.170,
                        fontWeight: FontWeight.bold,
                      ),
                    
                    ),
                    ),
                    
                    
                    Container(
                     
                      width: 300,
                      
                      child: Text(
                      
                      'Pronto para\nlucrar mais?',
                      style: GoogleFonts.poppins( 
                        
                        fontSize: constraints.maxWidth * 0.085,
                        fontWeight: FontWeight.w500,
                      letterSpacing: 3,
                      height: 1
                        ), 
                      
                    ),
                    ),
                    
                     SizedBox(height: 200), 
                  
                    
                    ElevatedButton(
                      onPressed: () {
                         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Register()), (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.13,
                          vertical: 25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(121),
                        ),
                      ),
                      child: Text(
                        'Criar nova conta',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: constraints.maxWidth * 0.045,
                          ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        
                        
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.25,
                          vertical: 25,
                          
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(121),
                        ),
                      ),
                      child: Text(
                        'Entrar',
                        style:   GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: constraints.maxWidth * 0.045,
                          
                        )
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

