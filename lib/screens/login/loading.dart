import 'package:app_fingo/screens/login/welcome.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../models/api_response.dart';

import '../../services/classcorridas_service.dart';
import '../../services/meslucro_service.dart';
import '../../services/user_service.dart';
import '../dashboard.dart';


class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
/* List<meslucroModel>? mesLucro;
List<InfooneModel>? infoOne;
List<Gastos>? gastos;
List<classCorridasModel>? classCorrida; */


  void _loadUserInfo() async {
    String token = await getToken();
    if(token == ''){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
    }
    else {
      ApiResponse response = await getUserDetail();
       ApiResponse meslucro = await getMeslucroDetail(); // Função que verifica dados em 'mesLucro'
  ApiResponse infones = await getInfooneDetail(); 
  ApiResponse gastos = await getExpensesDetail(); 
  ApiResponse classcorridas = await getclassCorridasDetail(); 


       /*   bool hasData = 
                   (mesLucro != null && mesLucro!.isNotEmpty) &&
                   (infoOne != null && infoOne!.isNotEmpty) &&
                   (gastos != null && gastos!.isNotEmpty) &&
                   (classCorrida != null && classCorrida!.isNotEmpty);

    bool isUnauthorized = response.error == unauthorized &&
                          (mesLucro == null || mesLucro!.isEmpty) &&
                          (infoOne == null || infoOne!.isEmpty) &&
                          (gastos == null || gastos!.isEmpty) &&
                          (classCorrida == null || classCorrida!.isEmpty); */



      if (
        response.error == null && 
         meslucro.error == null && meslucro.data != null && meslucro.data is List && (meslucro.data as List).isNotEmpty &&
    infones.error == null && infones.data != null && infones.data is List && (infones.data as List).isNotEmpty &&
    gastos.error == null && gastos.data != null && gastos.data is List && (gastos.data as List).isNotEmpty &&
    classcorridas.error == null && classcorridas.data != null && classcorridas.data is List && (classcorridas.data as List).isNotEmpty
        
        ){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
      }
      else if (response.error == unauthorized){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
      }
      else {
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()), 
        (route) => false,
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.error}')),
        );
      });
      }
    }
  }

  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }
 

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color(0xFF171f20),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00ff75),
              backgroundColor: Color(0xFF171f20),
        )
      ),
    );
  }
}