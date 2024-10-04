import 'dart:developer';

import 'package:app_fingo/constant.dart';
import 'package:app_fingo/screens/balanco/meu_balanco.dart';
import 'package:app_fingo/screens/calculadora/info_calc.dart';
import 'package:app_fingo/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'historico/lista_historico.dart';
import 'meta_lucro.dart';
import '../models/api_response.dart';
import '../models/lucro_corrida_model.dart';
import '../models/user.dart';
import '../services/lucro_corrida.dart';
import '../services/user_service.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User? user;
  bool loading = true;
  List<lucroCorridaModel>? lucroCorrida;
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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


  
  void getLucroCorrida() async {
    try {
      ApiResponse response = await getlucroCorridaDetail();
      if (response.error == null) {
        setState(() {
          lucroCorrida = response.data as List<lucroCorridaModel>;
          loading = false;
        });
      } else if (response.error == unauthorized) {
        logout().then((value) => {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false)
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${response.error}')));
      }
    } catch (e, stacktrace) {
      log("Erro ao carregar os dados de lucroCorrida: $e", stackTrace: stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar os dados de lucroCorrida')));
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getLucroCorrida();
  }
  @override
  Widget build(BuildContext context) {
final size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
      // Verificação de nulidade
    if (lucroCorrida == null || lucroCorrida!.isEmpty) {
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
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
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
                    border: Border.all(color: Color(0xFF00ff75), width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Text(
                      user?.username?.substring(0, 2) ?? '??',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(child: CircularProgressIndicator()), // Mostra um indicador de progresso enquanto os dados são carregados
      );
    }

lucroCorridaModel corrida = lucroCorrida![0];
double valorCorrida = double.tryParse(corrida.valor_corrida ?? '0') ?? 0;
    
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
                    currencyFormat.format(valorCorrida),
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
                          Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HistCorridas()), 
                          (route) => false);
                        },),
                        DashboardButton(title: 'Progresso', onTap: (){
                          
                          Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => MetaLucroScreen()), 
                          (route) => false);

                        },),
                         DashboardButton(title: 'Meu balanço', onTap: () {
                         Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Balanco()), 
                          (route) => false);

                        }),
                        DashboardButton(title: 'Calculadora', onTap: (){
                           Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => CalculadoraLucroScreen()), 
                          (route) => false);
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
