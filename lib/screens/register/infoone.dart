import 'dart:convert';

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
import 'gastos.dart';
import 'meslucros.dart';

class Infoone extends StatefulWidget {
  @override
  _InfooneState createState() => _InfooneState();
}

class _InfooneState extends State<Infoone> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<InfooneModel> infooneList = [];
  bool loading = false;

  final MoneyMaskedTextController _valorGasolinaController = MoneyMaskedTextController(
    leftSymbol: 'R\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final MoneyMaskedTextController _kmLitroController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
  );
  TextEditingController diasTrabController = TextEditingController();
  TextEditingController qtdCorridasController = TextEditingController();

  Future<void> _submitInfoone() async {
    final url = Uri.parse(InfooneURL); // Substitua com o seu URL de API Laravel
    String token = await getToken();

    // Dados para enviar
    final Map<String, dynamic> data = {
      'valor_gasolina': _valorGasolinaController.numberValue,
      'dias_trab': int.parse(diasTrabController.text),
      'qtd_corridas': int.parse(qtdCorridasController.text),
      'km_litro': _kmLitroController.numberValue,
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
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MesLucros()), (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Infoone atualizado com sucesso')),
              );
            }
          } else {
            print('Falha ao atualizar infoone: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao atualizar infoone: ${updateResponse.statusCode}')),
              );
            }
          }
        } else {
          // Crie um novo registro
          final createResponse = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          );

          if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MesLucros()), (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Infoone adicionado com sucesso')),
              );
            }
          } else {
            print('Falha ao adicionar infoone: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao adicionar infoone: ${createResponse.statusCode}')),
              );
            }
          }
        }
      } else {
        print('Falha ao verificar infoone: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao verificar infoone: ${checkResponse.statusCode}')),
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
            _valorGasolinaController.text = 'R\$${firstItem.valorGasolina ?? ''}';
            diasTrabController.text = firstItem.diasTrab?.toString() ?? '';
            qtdCorridasController.text = firstItem.qtdCorridas?.toString() ?? '';
            _kmLitroController.text = firstItem.kmLitro ?? '';
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
                Container(
                  width: width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quase lá.',
                        style: GoogleFonts.poppins(
                          fontSize: 50,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Qual o preço da gasolina no seu posto?',
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
                        controller: _valorGasolinaController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (val) => val!.isEmpty ? 'Campo vazio' : null,
                        decoration: kInputDecoration(''),
                      ),
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
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Quantos Km seu carro faz com um litro\nde gasolina?',
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
                        controller: _kmLitroController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (val) => val!.isEmpty ? 'Campo Vazio' : null,
                        decoration: kInputDecoration(''),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.07),
                kTextButton(
                  'Próximo',
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
                SizedBox(height: height * 0.02),
                kButtonAnterior(
                  'Anterior',
                  () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => GastosPage()),
                        (route) => false);
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
