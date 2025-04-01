import 'dart:developer';
import 'package:app_fingo/constant.dart';
import 'package:app_fingo/screens/balanco/meu_balanco.dart';
import 'package:app_fingo/screens/calculadora/permissoes_ou_valorkm.dart';
import 'package:app_fingo/screens/login/welcome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/classcorridas_service.dart';
import '../services/meslucro_service.dart';
import 'historico/lista_historico.dart';
import 'meta_lucro/meta_lucro.dart';
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

Future<void> _refreshData() async {
    setState(() {
      loading = true;
    });
    getUser();
    getLucroCorrida();
  }


  void checkUserData() async {
  ApiResponse response = await getMeslucroDetail(); // Função que verifica dados em 'mesLucro'
  ApiResponse infones = await getInfooneDetail(); 
  ApiResponse gastos = await getExpensesDetail(); 
  ApiResponse classcorridas = await getclassCorridasDetail(); 
  
  // Verifica se response.data é uma lista e se está vazia
  if (
    response.error == null && response.data != null && response.data is List && (response.data as List).isNotEmpty &&
    infones.error == null && infones.data != null && infones.data is List && (infones.data as List).isNotEmpty &&
    gastos.error == null && gastos.data != null && gastos.data is List && (gastos.data as List).isNotEmpty &&
    classcorridas.error == null && classcorridas.data != null && classcorridas.data is List && (classcorridas.data as List).isNotEmpty
  ) {
    // Dados encontrados, carregue o usuário e prossiga para o dashboard
    getUser();
    getLucroCorrida();
  } else {
    // Redireciona para a tela de login se não houver dados em 'mesLucro'
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()), 
      (route) => false
    );
  }
}



  @override
  void initState() {
    super.initState();
    /* getUser();
    getLucroCorrida(); */
    checkUserData();
  }
  @override
  Widget build(BuildContext context) {
final size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    debugInvertOversizedImages = true;
      // Verificação de nulidade
    if (lucroCorrida == null || lucroCorrida!.isEmpty) {
      

      return loading ?
      Scaffold(
        backgroundColor: Color(0xFF171f20),
        body: Center(
              child: CircularProgressIndicator(
              color: Color(0xFF00ff75),
              backgroundColor: Color(0xFF171f20),
            )),
      )
      
      : Scaffold(
      backgroundColor: Color(0xFF171f20),
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding:  EdgeInsets.all(8.0),
          child: Image(
            image: CachedNetworkImageProvider(
            maxWidth: 100,
            maxHeight: 100,
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

           title: Align(
          alignment: Alignment.centerRight,
          child: Text(
             user != null 
      ? (user!.username!.contains(' ') 
          ? '${user!.username!.split(' ').first} ${user!.username!.split(' ').last}' 
          : '${user!.username!.split(' ').first}'
        )
      : '',
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
                     user?.username != null && user!.username!.isNotEmpty
    ? user!.username!.contains(' ')
        ? '${user!.username!.split(' ')[0][0]}${user!.username!.split(' ').last[0]}'
        : '${user!.username![0]}'
    : '',
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Color(0xFF171f20),
        child: ListView(
          children: [
            Container(
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
                        "R\$ 0,00",
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
                              MaterialPageRoute(builder: (context) => TelaComBotoes()), 
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
                          color: Color.fromARGB(255, 36, 51, 53),
                          border: Border.all(
                           // Cor da borda
                            width: 0, // Largura da borda
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        
                      ),
                      
                   SizedBox(height: height * 0.01),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
    }

lucroCorridaModel corrida = lucroCorrida![0];
double valorCorrida = double.tryParse(corrida.valor_corrida ?? '0') ?? 0;
    
    return loading ?
      Scaffold(
        backgroundColor: Color(0xFF171f20),
        body: Center(
              child: CircularProgressIndicator(
              color: Color(0xFF00ff75),
              backgroundColor: Color(0xFF171f20),
            )),
      )
      
      : Scaffold(
      backgroundColor: Color(0xFF171f20),
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding:  EdgeInsets.all(8.0),
          child: Image(
            image: CachedNetworkImageProvider(
            maxWidth: 210,
            maxHeight: 210,
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
      
           title: Align(
          alignment: Alignment.centerRight,
          child: Text(
              user != null 
      ? (user!.username!.contains(' ') 
          ? '${user!.username!.split(' ').first} ${user!.username!.split(' ').last}' 
          : '${user!.username!.split(' ').first}'
        )
        : '',
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
                    user?.username != null && user!.username!.isNotEmpty
    ? user!.username!.contains(' ')
        ? '${user!.username!.split(' ')[0][0]}${user!.username!.split(' ').last[0]}'
        : '${user!.username![0]}'
         : '',
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Color(0xFF171f20),
        child: ListView(
          children: [
            Container(
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
                              MaterialPageRoute(builder: (context) => TelaComBotoes()), 
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
                          color: Color.fromARGB(255, 34, 46, 48),
                          border: Border.all(
                           // Cor da borda
                            width: 0, // Largura da borda
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        
                      ),
                      
                   SizedBox(height: height * 0.01),
                    ],
                  ),
                ),
          ],
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
