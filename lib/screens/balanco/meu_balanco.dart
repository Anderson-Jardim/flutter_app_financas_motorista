import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/gastos_model.dart';
import '../../models/lucro_corrida_model.dart';
import '../../models/saida_lucro_model.dart';
import '../../services/lucro_saidas_service.dart';
import '../../services/user_service.dart';
import '../../services/lucro_corrida.dart';
import '../dashboard.dart';
import '../login/welcome.dart';
import 'balanco_saidas.dart';

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
  List<saidaLucroModel> _saidas = [];
  bool loading = true;
  List<lucroCorridaModel>? lucroCorrida;
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    moneyController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void getAmount() async {
    ApiResponse response = await getExpensesDetail();
    if (response.error == null && mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao obter despesas: ${response.error}'),
        ));
      }
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
  void getSaidas() async {
  ApiResponse response = await getSaidasDetail(); // Supondo que você tenha uma função que busca as saídas
  if (response.error == null && mounted) {
    setState(() {
      _saidas = response.data as List<saidaLucroModel>; // Converta os dados corretamente para a lista de saídas
      loading = false;
    });
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao obter saídas: ${response.error}'),
      ));
    }
  }
}


  @override
  void initState() {
    super.initState();
    getAmount();
    getLucroCorrida();
    getSaidas();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    if (lucroCorrida == null || lucroCorrida!.isEmpty) {
      return loading ?
      Scaffold(
        backgroundColor: Colors.white,
        body: Center(
              child: CircularProgressIndicator(
              color: Color(0xFF00ff75),
              backgroundColor: Color(0xFF171f20),
            )),
      )
      : Scaffold(
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
        body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.1, vertical: height * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suas finanças',
                        style: GoogleFonts.poppins(
                            fontSize: 33, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'descomplicadas.',
                        style: GoogleFonts.poppins(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00ff75)),
                      ),
                      SizedBox(height: height * 0.02),
                      Text(
                        'Veja a divisão completa dos seus ganhos.',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: height * 0.04),
                      _buildInfoCard(
                          width, 'Gastos', currencyFormat.format(0), Colors.grey[200]!),
                      SizedBox(height: height * 0.02),
                      _buildInfoCard(
                          width, 'Lucro', currencyFormat.format(0), Colors.grey[200]!),
                      SizedBox(height: height * 0.05),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      SizedBox(height: height * 0.02),
                      _buildSaidasList(width, height),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: height * 0.02),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                        vertical: height * 0.02, horizontal: width * 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => AdicionarSaida()),
                        (route) => false);
                  },
                  child: Text(
                    'Adicionar saída',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 19),
                  ),
                ),
              ),
            ],
          ),
      );
    }

    if (totalExpense == null || lucroCorrida!.isNotEmpty) {
      lucroCorridaModel segundoLucro = lucroCorrida![0];
      double lucroAtual = double.tryParse(segundoLucro.total_lucro ?? '0') ?? 0;
      double gastoAtual = double.tryParse(segundoLucro.total_gasto ?? '0') ?? 0;

return loading ?
      Scaffold(
        backgroundColor: Colors.white,
        body: Center(
              child: CircularProgressIndicator(
              color: Color(0xFF00ff75),
              backgroundColor: Color(0xFF171f20),
            )),
      )
      : Scaffold(
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
        body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.1, vertical: height * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suas finanças',
                        style: GoogleFonts.poppins(
                            fontSize: 33, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'descomplicadas.',
                        style: GoogleFonts.poppins(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00ff75)),
                      ),
                      SizedBox(height: height * 0.02),
                      Text(
                        'Veja a divisão completa dos seus ganhos.',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: height * 0.04),
                      _buildInfoCard(
                          width, 'Gastos', currencyFormat.format(gastoAtual), Colors.grey[200]!),
                      SizedBox(height: height * 0.02),
                      _buildInfoCard(
                          width, 'Lucro', currencyFormat.format(lucroAtual), Colors.grey[200]!),
                      SizedBox(height: height * 0.05),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      SizedBox(height: height * 0.02),
                      _buildSaidasList(width, height),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: height * 0.02),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                        vertical: height * 0.02, horizontal: width * 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => AdicionarSaida()),
                        (route) => false);
                  },
                  child: Text(
                    'Adicionar saída',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 19),
                  ),
                ),
              ),
            ],
          ),
      );
    } else {
      return Scaffold(
        backgroundColor: Color(0xFF171f20),
        body: Center(
          child: Text(
            "Sem dados", 
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white),
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
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            amount,
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 27, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Novo método para construir a lista de saídas
Widget _buildSaidasList(double width, double height) {
  return ListView.builder(
   
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: _saidas.length,
    itemBuilder: (context, index) {
      
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Container(
   padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: height * 0.01),
      decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black,
        width: 1.2
      ),
      borderRadius: BorderRadius.circular(45),
  ),
  
        child: Row(
          
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_saidas[index].nome_saida.toString(), 
                style: GoogleFonts.poppins(
                  color: Colors.black, 
                  fontSize: 20, 
                  fontWeight: FontWeight.w400,
                  )
                ),
                Text(_saidas[index].createdAt.toString(), 
                style: GoogleFonts.poppins(
                  color: Colors.grey, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w400,
                  )
                ),

              ],
            ),
            Row(
              
              children: [
                Text("R\$${_saidas[index].saida_lucro.toString()}", style: GoogleFonts.poppins(color: Colors.red, fontSize: 19, fontWeight: FontWeight.w400,)),
              ],
            )
          ],
        ),
        
      ),
    );
    },
  );
}

}
