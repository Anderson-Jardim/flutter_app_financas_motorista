import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/gastos_model.dart';
import '../../models/ler_corrida_model.dart';
import '../../models/lucro_corrida_model.dart';
import '../../models/saida_lucro_model.dart';
import '../../services/ler_corrida_service.dart';
import '../../services/lucro_saidas_service.dart';
import '../../services/user_service.dart';
import '../../services/lucro_corrida.dart';
import '../dashboard.dart';
import '../welcome.dart';


class HistCorridas extends StatefulWidget {
  @override
  _HistCorridasState createState() => _HistCorridasState();
}

class _HistCorridasState extends State<HistCorridas> {
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



  bool loading = true;
 
    List<LerCorridaModel> _saidas = [];
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    moneyController.dispose();
    amountController.dispose();
    super.dispose();
  }


void getlerCorrida() async {
    try {
      ApiResponse response = await getlerCorridaDetail();
      if (response.error == null) {
        setState(() {
          _saidas = response.data as List<LerCorridaModel>;
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
    getlerCorrida();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    if (_saidas == null || _saidas.isEmpty) {
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
          child: Text("Você ainda não possui lucro", style: TextStyle(color: Colors.white)),
        ),
      );
    }

   
      
      

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
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'descomplicadas.',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00ff75)),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Veja a divisão completa dos seus ganhos.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: height * 0.04), /*
              _buildInfoCard(width, 'Gastos', currencyFormat.format(gastoAtual), Colors.grey[200]!),
              SizedBox(height: height * 0.02),
              _buildInfoCard(width, 'Lucro', currencyFormat.format(lucroAtual), Colors.grey[200]!),
              SizedBox(height: height * 0.04), */
              // Substituição pela nova lista de saídas
              _buildSaidasList(width),
              SizedBox(height: height * 0.04),
              Center(
                
              ),
            ],
          ),
        ),
      );
  
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
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Novo método para construir a lista de saídas
Widget _buildSaidasList(double width) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: _saidas.length,
    itemBuilder: (context, index) {
      print('Exibindo saída: ${_saidas[index].tipo_corrida}'); // Log da saída exibida
      return ListTile(
        title: Text(_saidas[index].tipo_corrida.toString()),
        subtitle: Text(
          'Lucro: ${_saidas[index].valor} | Data: ${_saidas[index].createdAt}',
        ),
      );
    },
  );
}

}
