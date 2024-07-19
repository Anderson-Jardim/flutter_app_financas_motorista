import 'package:app_fingo/constant.dart';
import 'package:app_fingo/models/gastos_model.dart';
import 'package:app_fingo/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/api_response.dart';
import '../../services/user_service.dart';
import '../welcome.dart';

class Balanco extends StatefulWidget {
  @override
  _BalancoState createState() => _BalancoState();
}

class _BalancoState extends State<Balanco> {
  List<Gastos> getgastos = [];
  bool loading = true;
  double totalGastos = 0.0;
   final MoneyMaskedTextController moneyController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

   void getAmount() async {
    ApiResponse response = await getExpensesDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          getgastos = response.data as List<Gastos>;
          loading = false;

          // Calcular o total dos gastos
          if (getgastos.isNotEmpty) {
            totalGastos = getgastos.fold(0.0, (sum, item) {
              // Converter amount para double e somar ao total
              double amount = double.tryParse(item.amount ?? "0") ?? 0.0;
              return sum + amount;
            });
            moneyController.updateValue(totalGastos);
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

  @override
  void initState() {
    super.initState();
    getAmount();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

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
        padding:
            EdgeInsets.symmetric(horizontal: width * 0.1, vertical: height * 0.05),
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
             _buildInfoCard(width, 'Gastos', moneyController.text, Colors.grey[200]!),
            SizedBox(height: height * 0.02),
            _buildInfoCard(width, 'Lucro', 'R\$359', Colors.grey[200]!),
            SizedBox(height: height * 0.04),
            _buildExpenseItem(width, 'Internet', 'R\$100'),
            _buildExpenseItem(width, 'Internet', 'R\$100'),
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
                  // Ação de adicionar saída
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

  Widget _buildExpenseItem(double width, String name, String amount) {
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
            name,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Text(
            amount,
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
