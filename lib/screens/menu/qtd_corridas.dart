import 'dart:convert';

import 'package:app_fingo/screens/dashboard.dart';
import 'package:app_fingo/screens/register/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/infoone_model.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../login/welcome.dart';


class Qtd_Corrida extends StatefulWidget {
  @override
  _Qtd_CorridaState createState() => _Qtd_CorridaState();
}

class _Qtd_CorridaState extends State<Qtd_Corrida> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<InfooneModel> infooneList = [];
  bool loading = false;

  TextEditingController diasTrabController = TextEditingController();
  TextEditingController qtdCorridasController = TextEditingController();

  Future<void> _submitInfoone() async {
    final url = Uri.parse(InfooneURL); // Substitua com o seu URL de API Laravel
    String token = await getToken();

    // Dados para enviar
    final Map<String, dynamic> data = {
      /* 'valor_gasolina': _valorGasolinaController.numberValue, */
      'dias_trab': int.parse(diasTrabController.text),
      'qtd_corridas': int.parse(qtdCorridasController.text),
      /* 'km_litro': _kmLitroController.numberValue, */
    };

    try {
      // Verifique se o registro já existe
      final checkResponse = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (checkResponse.statusCode == 200) {
        final List<dynamic> existingData = json.decode(checkResponse.body);
        if (existingData.isNotEmpty) {
          // Atualize o registro existente
          final updateUrl = Uri.parse('$InfooneURL/${existingData[0]['id']}');
          final updateResponse = await http.put(
            updateUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          );

          if (updateResponse.statusCode == 200) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dados atualizados com sucesso')),
              );
            }
          } else {
            print('Falha ao atualizar infoone: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao atualizar dados: ${updateResponse.statusCode}')),
              );
            }
          }
        } 
      } else {
        print('Falha ao verificar infoone: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao verificar dados: ${checkResponse.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer requisição')),
        );
      }
    }
  }

  void _fetchInfooneData() async {
    ApiResponse response = await getInfooneDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          infooneList = response.data as List<InfooneModel>;
          loading = false;

          // Preenchendo os controladores de texto com dados do primeiro item da lista, se houver
          if (infooneList.isNotEmpty) {
            InfooneModel firstItem = infooneList[0];
            /* _valorGasolinaController.text = 'R\$${firstItem.valorGasolina ?? ''}'; */
            diasTrabController.text = firstItem.diasTrab?.toString() ?? '';
            qtdCorridasController.text = firstItem.qtdCorridas?.toString() ?? '';
            /* _kmLitroController.text = firstItem.kmLitro ?? ''; */
          }
        });
      }
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.error}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInfooneData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
      title: const Text(
        'Corrida e Dias',
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
    ),
      backgroundColor: Color(0xFF171f20),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.1),
               
                SizedBox(height: height * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                     
                      SizedBox(height: height * 0.04),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Quantos dias por mês você trabalha?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: diasTrabController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (val) => val!.isEmpty ? 'Campo Vazio' : null,
                        decoration: kInputDecoration(''),
                      ),
                      SizedBox(height: height * 0.04),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Quantas corridas você faz por dia?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: qtdCorridasController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (val) => val!.isEmpty ? 'Campo Vazio' : null,
                        decoration: kInputDecoration(''),
                      ),
                      SizedBox(height: height * 0.04),
                     
                    ],
                  ),
                ),
                SizedBox(height: height * 0.07),
                kTextButton(
                  'Salvar',
                  () async {
                    if (_formKey.currentState!.validate()) {
                      _submitInfoone();
                    }
                  },
                  EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: width * 0.30,
                  ),
                  height * 0.025,
                ),

                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
