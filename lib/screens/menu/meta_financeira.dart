import 'dart:convert';
import 'package:app_fingo/screens/register/finalcad.dart';
import 'package:app_fingo/screens/register/infoone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/meslucro_model.dart';
import '../../services/meslucro_service.dart';
import '../../services/user_service.dart';
import '../dashboard.dart';
import '../login/welcome.dart';

class MetaFinanceira extends StatefulWidget {
  @override
  _MetaFinanceiraState createState() => _MetaFinanceiraState();
}

class _MetaFinanceiraState extends State<MetaFinanceira> {
  List<meslucroModel> meslucromodel = [];
  bool loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final MoneyMaskedTextController _meslucrosController = MoneyMaskedTextController(
    leftSymbol: 'R\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  Future<void> _submitMesLucro() async {
    final url = Uri.parse(meslucrosURL); // Substitua com o seu URL de API Laravel
    String token = await getToken();

    // Dados para enviar
    final Map<String, dynamic> data = {
      'qtd_mes_lucros': _meslucrosController.numberValue,
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
          final updateUrl = Uri.parse('$meslucrosURL/${existingData[0]['id']}');
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Dashboard()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dados atualizados com sucesso')),
              );
            }
          } else {
            print('Falha ao atualizar Mês Lucro: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao atualizar dados: ${updateResponse.statusCode}')),
              );
            }
          }
        } 
      } else {
        print('Falha ao verificar Mes Lucros: ${checkResponse.statusCode}');
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

  void getMesLucro() async {
    ApiResponse response = await getMeslucroDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          List<meslucroModel> meslucromodel = response.data as List<meslucroModel>;
          loading = false;

          if (meslucromodel.isNotEmpty) {
            meslucroModel firstItem = meslucromodel[0];
            _meslucrosController.text = 'R\$${firstItem.qtd_mes_lucros ?? ''}';
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
      String errorMessage = 'Erro ao obter meslucro: ${response.error}';
      if (response.errorDetail != null) {
        errorMessage += '\nDetalhes do erro: ${response.errorDetail}';
      }

      // Log do erro detalhado (somente no console do desenvolvedor)
      print('Erro detalhado ao obter meslucro: ${response.error}');
      if (response.errorDetail != null) {
        print('Detalhes do erro: ${response.errorDetail}');
      }
      if (response.statusCode != null) {
        print('Código de status HTTP: ${response.statusCode}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao obter meslucro: ${response.error}'),
        ));
      }
    }
  }

  @override
  void initState() {
    getMesLucro();
    super.initState();
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
        'Meta Financeira',
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
                
                SizedBox(height: height * 0.2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Quanto quer lucrar no mês?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: _meslucrosController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (val) {
                           if (val!.isEmpty) {
                          return 'Campo Vazio';
                           } else if (val == 'R\$0,00') {
                              return 'Valor inválido';
                            }
                            return null;
                        },
                        decoration: kInputDecoration(''),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.10),
                kTextButton(
                  'Salvar',
                  () async {
                    if (_formKey.currentState!.validate()) {
                      _submitMesLucro();
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
