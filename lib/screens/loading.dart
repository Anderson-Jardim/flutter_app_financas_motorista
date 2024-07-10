import 'package:app_fingo/screens/welcome.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import '../models/api_response.dart';
import '../services/user_service.dart';
import 'login.dart';
import 'register/gastos.dart';
import 'register/infoone.dart';
import 'register/register.dart';


class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  void _loadUserInfo() async {
    String token = await getToken();
    if(token == ''){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
    }
    else {
      ApiResponse response = await getUserDetail();
      if (response.error == null){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>GastosPage()), (route) => false);
      }
      else if (response.error == unauthorized){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
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
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}