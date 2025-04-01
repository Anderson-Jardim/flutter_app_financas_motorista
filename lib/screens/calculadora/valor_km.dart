import 'package:app_fingo/models/api_response.dart';
import 'package:app_fingo/models/valorKM_model.dart';
import 'package:app_fingo/services/valor_KM_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para usar JSON
import '../../constant.dart';
import '../../services/user_service.dart';
import '../dashboard.dart';
import '../login/welcome.dart';

class ganhoPorKm extends StatefulWidget {
  @override
  _ganhoPorKmState createState() => _ganhoPorKmState();
}

class _ganhoPorKmState extends State<ganhoPorKm> {

List<valorKM_Model> valorkm_model = [];
 final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    bool loading = false;


final TextEditingController _valorkm_ruim_Controller = TextEditingController();
final TextEditingController _valorkm_bom_Controller = TextEditingController();



Future<void> atualizaValorKM() async {
  final url = Uri.parse(valorKM_URL);
  String token = await getToken();
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
        final updateURL = Uri.parse('$valorKM_URL/${existingData[0]['id']}');
        double ruimValue = double.tryParse(_valorkm_ruim_Controller.text) ?? 0.0;
        double bomValue = double.tryParse(_valorkm_bom_Controller.text) ?? 0.0;

        final updateResponse = await http.put(
          updateURL,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'ruim': ruimValue,
            'bom': bomValue,
          }),
        );

        if (updateResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Valores atualizados com sucesso!'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar valores.'),
          ));
        }
      }
    }
  } catch (e) {
    // Em caso de erro na requisição
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro de conexão: $e')),
    );
  }
}


Future<void> getValorKM() async {
  try {
    final url = Uri.parse(valorKM_URL); // Substitua pelo endpoint correto da sua API
    String token = await getToken(); // Obter o token de autenticação

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Token de autenticação
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data.isNotEmpty) {
        double ruim = double.tryParse(data[0]['ruim'].toString()) ?? 0.0;
        double bom = double.tryParse(data[0]['bom'].toString()) ?? 0.0;

        // Atualiza os controladores de texto com os valores 'ruim' e 'bom'
        setState(() {
          _valorkm_ruim_Controller.text = ruim.toString();
          _valorkm_bom_Controller.text = bom.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Dados carregados com sucesso!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nenhum dado encontrado.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao obter dados: ${response.statusCode}'),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erro de conexão: $e'),
    ));
  }
}



@override
  void initState() {
    super.initState();
    getValorKM();
  }

  @override
Widget build(BuildContext context) {
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
        'Permissões do App',
        style: TextStyle(color: Colors.black),
      ),
    ),
    backgroundColor: Colors.white,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              campoValor(
                "Ruim",
                double.tryParse(_valorkm_ruim_Controller.text) ?? 0.0,
                Colors.black,
                (value) {
                  setState(() {
                    _valorkm_ruim_Controller.text = value.toString();
                  });
                },
                limite: double.tryParse(_valorkm_bom_Controller.text) ?? 0.0, // Passando o valor de "bom" como limite
  isRuim: true, // Identificando que é o campo "ruim"
              ),
              SizedBox(width: 20),
              campoValor(
                "Bom",
                double.tryParse(_valorkm_bom_Controller.text) ?? 0.0,
                Colors.black,
                (value) {
                  setState(() {
                    _valorkm_bom_Controller.text = value.toString();
                  });
                },
                   limite: double.tryParse(_valorkm_ruim_Controller.text) ?? 0.0, // Passando o valor de "ruim" como limite
  isRuim: false, // Identificando que é o campo "bom"
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Chama a função para enviar os dados
              atualizaValorKM();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
            ),
            child: Text("SALVAR"),
          ),
        ],
      ),
    ),
  );
}


Widget campoValor(
    String titulo, double valor, Color cor, Function(double) onChanged, {double? limite, bool isRuim = false}) {
  return Column(
    children: [
      Text(
        titulo,
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: cor),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: cor),
              onPressed: () {
                double newValue = (valor - 0.05).clamp(0.0, double.infinity);
                // Validação para o campo "ruim"
                if (isRuim) {
                  if (limite != null && newValue <= limite) {
                    onChanged(newValue); // Permite diminuir se não ultrapassar o limite
                  }
                } else {
                  // Validação para o campo "bom"
                  if (limite != null && newValue >= limite) {
                    onChanged(newValue); // Permite diminuir se não ficar abaixo do limite
                  } else if (limite == null) {
                    onChanged(newValue); // Permite diminuir sem restrição
                  }
                }
              },
            ),
            Text(
              valor.toStringAsFixed(2),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            IconButton(
              icon: Icon(Icons.add, color: cor),
              onPressed: () {
                double newValue = (valor + 0.05).clamp(0.0, double.infinity);
                // Validação para o campo "ruim"
                if (isRuim) {
                  if (limite != null && newValue <= limite) {
                    onChanged(newValue); // Permite aumentar se não ultrapassar o limite
                  }
                } else {
                  // Validação para o campo "bom"
                  if (limite != null && newValue >= limite) {
                    onChanged(newValue); // Permite aumentar se não ficar abaixo do limite
                  } else if (limite == null) {
                    onChanged(newValue); // Permite aumentar sem restrição
                  }
                }
              },
            ),
          ],
        ),
      ),
    ],
  );
}





}
