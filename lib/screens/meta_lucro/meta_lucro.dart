import 'dart:developer'; // Import para usar o log
import 'package:app_fingo/constant.dart';
import 'package:app_fingo/screens/dashboard.dart';
import 'package:app_fingo/screens/login/welcome.dart';
import 'package:app_fingo/services/lucro_corrida.dart';
import 'package:app_fingo/services/meslucro_service.dart';
import 'package:app_fingo/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/api_response.dart';
import '../../models/lucro_corrida_model.dart';
import '../../models/meslucro_model.dart';

class MetaLucroScreen extends StatefulWidget {
  @override
  State<MetaLucroScreen> createState() => _MetaLucroScreenState();
}

class _MetaLucroScreenState extends State<MetaLucroScreen> {
  List<meslucroModel>? lucroMes;
  List<lucroCorridaModel>? lucroCorrida;
  bool loading = true;

  // Função para buscar os dados de `meslucroModel`
  void getMesLucro() async {
    try {
      ApiResponse response = await getMeslucroDetail(); // Chamada correta para o lucro do mês
      if (response.error == null) {
        setState(() {
          lucroMes = response.data as List<meslucroModel>;
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
      log("Erro ao carregar os dados de meslucro: $e", stackTrace: stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar os dados de meslucro')));
    }
  }

  // Função para buscar os dados de `lucroCorridaModel`
  void getLucroCorrida() async {
    try {
      ApiResponse response = await getlucroCorridaDetail(); // Chamada para o lucro por corrida
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
    getMesLucro(); // Buscar os dados do lucro do mês
    getLucroCorrida(); // Buscar os dados do lucro por corrida
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    
    if (loading) {
      return Scaffold(
        backgroundColor: Color(0xFF171f20),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      );
    }

    // Verifique se `lucroMes` e `lucroCorrida` não são nulos e contêm elementos
    if (lucroCorrida == null || lucroCorrida!.isEmpty) {
    meslucroModel primeiroLucro = lucroMes![0];
        double lucroDesejado = double.tryParse(primeiroLucro.qtd_mes_lucros ?? '0') ?? 0;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF00ff75)),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Dashboard()),
                  (route) => false);
            },
          ),
        ),
        backgroundColor: Color(0xFF171f20),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            SizedBox(height: height * 0.04),
                Text(
                  textAlign: TextAlign.center,
                  'Visualize sua\nmeta de lucro.',
                  style: GoogleFonts.poppins(
                              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: height * 0.08),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo de progresso
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: 0,
                        strokeWidth: 15,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                    // Texto no centro do círculo
                    Text(
                      '0%',
                      style: GoogleFonts.poppins(
                              fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.08),
                // Texto indicando quanto falta para atingir a meta
                Text(
                  textAlign: TextAlign.center,
                  'Falta R\$${lucroDesejado.toStringAsFixed(2)} para\natingir a meta',
                  style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                SizedBox(height: height * 0.02),
                // Valor da meta de lucro
                Text(
                  'R\$${lucroDesejado.toStringAsFixed(2)}',
                   style: GoogleFonts.poppins(
                              fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Certifique-se de que a lista contém pelo menos um item antes de acessar o primeiro
    if (lucroMes!.isNotEmpty && lucroCorrida!.isNotEmpty) {
      meslucroModel primeiroLucro = lucroMes![0];
      lucroCorridaModel segundoLucro = lucroCorrida![0];

      double lucroDesejado = double.tryParse(primeiroLucro.qtd_mes_lucros ?? '0') ?? 0;
      double lucroAtual = double.tryParse(segundoLucro.total_lucro ?? '0') ?? 0;

      // Cálculo da porcentagem de progresso
      double porcentagemProgresso = (lucroAtual / lucroDesejado) * 100;
      double valorRestante = lucroDesejado - lucroAtual;

      return Scaffold(
        backgroundColor: Color(0xFF171f20),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF00ff75)),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Dashboard()),
                  (route) => false);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               SizedBox(height: height * 0.04),
                Text(
                  textAlign: TextAlign.center,
                  'Visualize sua\nmeta de lucro.',
                  style: GoogleFonts.poppins(
                                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: height * 0.08),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo de progresso
                    SizedBox(
                       width: 250,
                        height: 250,
                      child: CircularProgressIndicator(
                        value: porcentagemProgresso / 100,
                        strokeWidth: 15,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                    // Texto no centro do círculo
                    Text(
                      '${porcentagemProgresso.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                                fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.08),
                // Texto indicando quanto falta para atingir a meta
                Text(
                  textAlign: TextAlign.center,
                  'Falta R\$${valorRestante.toStringAsFixed(2)} para\natingir a meta',
                  style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                SizedBox(height: height * 0.02),
                // Valor da meta de lucro
                Text(
                  'R\$${lucroDesejado.toStringAsFixed(2)}',
                   style: GoogleFonts.poppins(
                                fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Color(0xFF171f20),
        body: Center(
          child: Text(
            'Nenhum dado disponível.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
