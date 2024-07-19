import 'package:app_fingo/constant.dart';
import 'package:app_fingo/screens/balanco/meu_balanco.dart';
import 'package:app_fingo/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User? user;
  bool loading = true;

  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()), 
          (route) => false
        )
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}')
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF171f20),
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo_02.png', 
            alignment: Alignment.topLeft,
          ),
        ),

           title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            user?.username ?? 'Carregando...',
            style: GoogleFonts.poppins(
                              color: Colors.white,
                              
                              ), // Adiciona estilo ao texto se necessário
          ),
        ),
      
        actions: [
          GestureDetector(
            onTap: (){
              logout().then((value) => {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomeScreen()), 
                          (route) => false
                        )
                      });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
               
               
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF00ff75), width: 2), // Cor e largura da borda
                ),
                child: CircleAvatar(
          
                  backgroundColor: Colors.transparent,
                  child: Text(
                    user?.username?.substring(0, 2) ?? '??', 
                    style: GoogleFonts.poppins(
                                color: Colors.white,
                              
                                ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: loading 
          ? Center(child: CircularProgressIndicator()) 
          : Container(
              width:width * 2.9,
              height: height * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.05),
                  Container(
                    width: width * 0.85,
                    child: Text(
                    'Saldo atual',
                    style: GoogleFonts.poppins(
                              color: Color(0xFFc2c2c2),
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              ),
                  ),
                  ),
                  
                  SizedBox(height: height * 0.01),
                  Container(
                    width: width * 0.85,
                    child: Text(
                    'R\$0,00',
                    style: GoogleFonts.poppins(
                              color: Color(0xFF00ff75),
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                  
                   SizedBox(height: height * 0.03),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 20, // Espaçamento horizontal entre os containers
                      runSpacing: 20, // Espaçamento vertical entre os containers
                      children: [
                        DashboardButton(title: 'Histórico', onTap: (){

                        },),
                        DashboardButton(title: 'Progresso', onTap: (){

                        },),
                         DashboardButton(title: 'Meu balanço', onTap: () {
                         Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Balanco()), 
                          (route) => false);

                        }),
                        DashboardButton(title: 'Calculadora', onTap: (){

                        },),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  Container(
                    width: width * 0.87,
                    height:  height* 0.22,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF0000),
                      border: Border.all(
                       // Cor da borda
                        width: 2, // Largura da borda
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    
                  ),
                  
               SizedBox(height: height * 0.01),
                ],
              ),
            ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const DashboardButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.14,
      width: width * 0.41,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFEBEBEB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onTap,
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.symmetric(
                             
                            horizontal: width * 0.02
                          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              ),
          ),
        ),
      ),
    );
  }
}
