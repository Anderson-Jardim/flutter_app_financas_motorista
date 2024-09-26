import 'dart:developer';

import 'package:app_fingo/constant.dart';
import 'package:app_fingo/models/lucro_corrida_model.dart';
import 'package:app_fingo/screens/balanco/balanco_saidas.dart';
import 'package:app_fingo/services/lucro_corrida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/api_response.dart';
import '../../models/gastos_model.dart';
import '../../services/user_service.dart';
import '../welcome.dart';
import '../dashboard.dart';

class Balanco extends StatefulWidget {
  @override
  _BalancoState createState() => _BalancoState();
}

class _BalancoState extends State<Balanco> {
  
  final MoneyMaskedTextController moneyController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final MoneyMaskedTextController amountController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  List<Map<String, dynamic>> _gastos = [];
  double totalExpense = 0.0;
  List<Gastos> getgastos = [];
  bool loading = true;
  List<lucroCorridaModel>? lucroCorrida;
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  void getAmount() async {
    ApiResponse response = await getExpensesDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          List<Gastos> getgastos = response.data as List<Gastos>;
          loading = false;

          if (getgastos.isNotEmpty) {
            Gastos firstItem = getgastos[0];
            _gastos = List<Map<String, dynamic>>.from(firstItem.gastos ?? []);
            totalExpense = _gastos.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
          } else {
            _gastos = [];
            totalExpense = 0.0;
          }
        });
      }
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        }
      });
    } else {
      // Detalhe o erro
      String errorMessage = 'Erro ao obter despesas: ${response.error}';
      if (response.errorDetail != null) {
        errorMessage += '\nDetalhes do erro: ${response.errorDetail}';
      }

      // Log do erro detalhado (somente no console do desenvolvedor)
      print('Erro detalhado ao obter despesas: ${response.error}');
      if (response.errorDetail != null) {
        print('Detalhes do erro: ${response.errorDetail}');
      }
      if (response.statusCode != null) {
        print('Código de status HTTP: ${response.statusCode}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao obter despesas: ${response.error}'),
        ));
      }
    }
  }

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
    getAmount();
    getLucroCorrida();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

     if ( lucroCorrida == null || lucroCorrida!.isEmpty) {
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
        body: Center(
          child: 
           Text("Você ainda não possui lucro", style: TextStyle(color: Colors.white),)
        ),
      );
    }

if (totalExpense == null || lucroCorrida!.isNotEmpty) {
    lucroCorridaModel segundoLucro = lucroCorrida![0];
    double lucroAtual = double.tryParse(segundoLucro.total_lucro ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
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
        padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: height * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas finanças',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'descomplicadas.',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00ff75),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Veja a divisão completa dos seus ganhos.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: height * 0.04),
            _buildInfoCard(width, 'Gastos', currencyFormat.format(totalExpense), Colors.grey[200]!),
            SizedBox(height: height * 0.02),
            _buildInfoCard(width, 'Lucro',currencyFormat.format(lucroAtual) , Colors.grey[200]!),
            SizedBox(height: height * 0.04),
            // Construindo a lista de gastos
            ..._gastos.map((gasto) {
              return _buildExpenseItem(width, gasto);
            }).toList(),
            SizedBox(height: height * 0.04),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.02, horizontal: width * 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => AdicionarSaida()), 
                          (route) => false);

                },
                child: Text(
                  'Adicionar saída',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}else {
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

  Widget _buildInfoCard(double width, String title, String amount, Color color) {
    return Container(
      width: width,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(double width, Map<String, dynamic> gasto) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            gasto['name'] ?? 'Desconhecido',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Text(
           '${currencyFormat.format(gasto['amount'])}',
            style: GoogleFonts.poppins(
              color: Color(0xFFFF0000),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
