import 'package:app_fingo/constant.dart';
import 'package:app_fingo/screens/balanco/meu_balanco.dart';
import 'package:app_fingo/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdicionarSaida extends StatefulWidget {
  @override
  State<AdicionarSaida> createState() => _AdicionarSaidaState();
}

class _AdicionarSaidaState extends State<AdicionarSaida> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isGastoChecked = false;
  bool isLucroChecked = false;
  bool loading = false;

  // Controlador de texto para o valor da saída
  final MoneyMaskedTextController _valorSaidaController = MoneyMaskedTextController(
    leftSymbol: 'R\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  // Controlador para o tipo de saída
  final TextEditingController tipoSaidaController = TextEditingController();
  final TextEditingController nomeSaidaController = TextEditingController();

  // Função para enviar os dados da saída
 /*  Future<void> enviarSaida() async {
    final url = Uri.parse(saidaLucro); // URL da API
    String token = await getToken(); // Recuperar o token de autenticação

    // Verifica se o formulário está validado corretamente
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true; // Mostra o estado de carregamento
      });

      try {
        final Map<String, dynamic> data = {
          'nome_saida': nomeSaidaController.text,
          'saida_lucro': _valorSaidaController.numberValue,
          'tipo': isGastoChecked ? 'Gasto' : 'Lucro',
        };

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Adiciona o token no cabeçalho
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          // Dados enviados com sucesso
          print('Saída enviada com sucesso');
          /* Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Balanco()),
            (route) => false,
          ); */
          ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saída Adicionada')),
              );
        } else {
          // Algo deu errado
          print('Erro ao enviar saída: ${response.body}');
        }
      } catch (error) {
        print('Erro na solicitação: $error');
      } finally {
        setState(() {
          loading = false; // Para o estado de carregamento
        });
      }
    }
  } */

  Future<void> enviarSaidaAdd() async {
    final url = Uri.parse(saidaLucroAdd); // URL da API
    String token = await getToken(); // Recuperar o token de autenticação

    // Verifica se o formulário está validado corretamente
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true; // Mostra o estado de carregamento
      });

      try {
        final Map<String, dynamic> data = {
          'nome_saida': nomeSaidaController.text,
          'saida_lucro': _valorSaidaController.numberValue,
          'tipo': isGastoChecked ? 'Gasto' : 'Lucro',
        };

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Adiciona o token no cabeçalho
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          // Dados enviados com sucesso
          print('Saída enviada com sucesso');
          ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saída Adicionada 2')),
              );
        } else {
          // Algo deu errado
          print('Erro ao enviar saída: ${response.body}');
        }
      } catch (error) {
        print('Erro na solicitação: $error');
      } finally {
        setState(() {
          loading = false; // Para o estado de carregamento
        });
      }
    }
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
              MaterialPageRoute(builder: (context) => Balanco()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.05),
                RichText(
                  text: TextSpan(
                    text: 'Adicione tudo\n',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'o que sair.',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00ff75),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
                TextField(
                  controller: nomeSaidaController,
                  decoration: InputDecoration(
                    labelText: 'Tipo de saída',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: height * 0.02),
                TextField(
                  controller: _valorSaidaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Valor da saída',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: height * 0.04),
                // Opções Gasto ou Lucro
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Gasto',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        value: isGastoChecked,
                        onChanged: (newValue) {
                          setState(() {
                            isGastoChecked = newValue ?? false;
                            if (isGastoChecked) {
                              isLucroChecked = false;
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Lucro',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        value: isLucroChecked,
                        onChanged: (newValue) {
                          setState(() {
                            isLucroChecked = newValue ?? false;
                            if (isLucroChecked) {
                              isGastoChecked = false;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.02,
                        horizontal: width * 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: loading
                        ? null
                        : () {
                          enviarSaidaAdd();
                            /* enviarSaida(); */
                          },
                    child: loading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Adicionar',
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
        ),
      ),
    );
  }
}
