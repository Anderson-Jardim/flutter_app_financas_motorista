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
import '../login/welcome.dart';


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
    if (_saidas == null || _saidas!.isEmpty) {

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF00ff75),),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Dashboard()),
                  (route) => false);
            },
          ),
        ),
        backgroundColor: Color(0xFF171f20),
        body: Center(

          child: Text(
            "Você ainda não possui histórico \n (Realize a sua primeira corrida para contabilizar)", 
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white),
            ),
        ),
      );
    } 

    
      
      


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
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Text(
                'Todas as corridas.',
                style: GoogleFonts.poppins(fontSize: 33, fontWeight: FontWeight.bold),
              ),
              Text(
                'Todos os ganhos.',
                style: GoogleFonts.poppins(fontSize: 33, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Cada card mostra o valor total da corrida e classificação de lucro.',
                style: GoogleFonts.poppins(fontSize: 18, color: Color(0xFF171F20)),
              ),
              
              SizedBox(height: height * 0.03),
              
              

              SizedBox(height: height * 0.02,),
              // Substituição pela nova lista de saídas
              _buildSaidasList(width,height),
              SizedBox(height: height * 0.05),
             
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
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Container(
   padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.001),
                  decoration: BoxDecoration(
                    color: Colors.black,
      border: Border.all(
        color: Colors.black,
        width: 1.2
      ),
      borderRadius: BorderRadius.circular(45),
  ),
                  child: Text(_saidas[index].tipo_corrida.toString(), 
                  style: GoogleFonts.poppins(
                    color: Colors.white, 
                    fontSize: 17, 
                    fontWeight: FontWeight.w500,
                    )
                  ),
                ),
                SizedBox(height: height * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.001),
                  child: Text(_saidas[index].createdAt.toString(), 
                  style: GoogleFonts.poppins(
                    color: Colors.grey, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                    )
                  ),
                ),

              ],
            ),
            Column(
              children: [
                
                Text("Valor total", style: GoogleFonts.poppins(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500,)),
                Text("R\$${_saidas[index].valor.toString()}", style: GoogleFonts.poppins(color: Color(0xFF157A31), fontSize: 19, fontWeight: FontWeight.w500,)),
             
              ],
            ),
          
          ],
        ),
        
      ),
    );
    },
  );
}

}
