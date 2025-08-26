
import 'package:app_fingo/models/valorKM_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:convert'; // Para usar JSON
import '../../constant.dart';
import '../../services/user_service.dart';
import '../dashboard.dart';

import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:notification_permissions/notification_permissions.dart' as np;
import 'package:permission_handler/permission_handler.dart';
class ganhoPorKm extends StatefulWidget {
  @override
  _ganhoPorKmState createState() => _ganhoPorKmState();
}

class _ganhoPorKmState extends State<ganhoPorKm> with WidgetsBindingObserver{
static const platform = MethodChannel('com.example.app_fingo/accessibility');
  late Future<String> notificationPermissionFuture;
  late Future<String> overlayPermissionFuture;
  late Future<String> accessibilityPermissionFuture;
  String accessibilityStatus = 'Carregando...';
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        notificationPermissionFuture = getCheckNotificationPermStatus();
        overlayPermissionFuture = getOverlayPermissionStatus();
        accessibilityPermissionFuture = getAccessibilityPermissionStatus();
        _checkAccessibilityStatus();
      });
    }
  }

  Future<String> getCheckNotificationPermStatus() async {
    return np.NotificationPermissions.getNotificationPermissionStatus().then((status) {
      switch (status) {
        case np.PermissionStatus.denied:
          return 'Não ativada ❌';
        case np.PermissionStatus.granted:
          return 'Ativada ✅';
        case np.PermissionStatus.unknown:
          return 'Status desconhecido ❓';
        case np.PermissionStatus.provisional:
          return 'Permissão provisória ⚠️';
        default:
          return 'Erro ao verificar';
      }
    });
  }

  Future<String> getOverlayPermissionStatus() async {
    bool isGranted = await Permission.systemAlertWindow.isGranted;
    return isGranted ? 'Ativada ✅' : 'Não ativada ❌';
  }

  Future<void> requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
      setState(() {
        overlayPermissionFuture = getOverlayPermissionStatus();
      });
    }
  }

  Future<String> getAccessibilityPermissionStatus() async {
    bool isEnabled = await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    return isEnabled ? 'Ativada ✅' : 'Não ativada ❌';
  }

  Future<void> requestAccessibilityPermission() async {
    await FlutterAccessibilityService.requestAccessibilityPermission();
    setState(() {
      accessibilityPermissionFuture = getAccessibilityPermissionStatus();
      _checkAccessibilityStatus();
    });
  }

  Future<void> _checkAccessibilityStatus() async {
    try {
      final bool isEnabled = await platform.invokeMethod('isAccessibilityEnabled');
      setState(() {
        accessibilityStatus = isEnabled ? 'Ativada ✅' : 'Não ativada ❌';
      });
    } on PlatformException catch (e) {
      print("Erro ao verificar acessibilidade: ${e.message}");
      setState(() {
        accessibilityStatus = 'Erro ao verificar status';
      });
    }
  }



@override
  void initState() {
    super.initState();
    getValorKM();
    notificationPermissionFuture = getCheckNotificationPermStatus();
    overlayPermissionFuture = getOverlayPermissionStatus();
    accessibilityPermissionFuture = getAccessibilityPermissionStatus();
    _checkAccessibilityStatus();
    WidgetsBinding.instance.addObserver(this);
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
        'Valor por KM',
        style: TextStyle(color: Colors.black),
      ),
    ),
    backgroundColor: Colors.grey[200],
    body: Center(
      child: Column(
        children: [
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 20),
            padding: EdgeInsets.only(top: 20, bottom: 20),
            
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15), // Borda arredondada
              boxShadow: [
                /* BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(4, 4), // Sombra
                ), */
              ],
            ),
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
                    backgroundColor: Colors.black,
                  ),
                  child: Text("SALVAR"),
                ),
              ],
            ),
          ),

            SizedBox(height: 20),
          Container(
            height: height * 0.46,
            width: width * 0.9,
            /* margin: EdgeInsets.only(left: 15, right: 15, bottom: 20), */
            /* padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30), */
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15), // Borda arredondada
              boxShadow: [
                /* BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(4, 4), // Sombra
                ), */
              ],
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<String>(
                  future: notificationPermissionFuture,
                  builder: (context, snapshot) {
                    return Text(
                      "Permissão de Notificação: ${snapshot.data ?? 'Erro'}",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await np.NotificationPermissions.requestNotificationPermissions(
                        iosSettings: const np.NotificationSettingsIos(
                            sound: true, badge: true, alert: true));
                    setState(() {
                      notificationPermissionFuture = getCheckNotificationPermStatus();
                    });
                  },
                  child: Text("Solicitar Permissão de Notificação"),
                ),
                SizedBox(height: 30),
                FutureBuilder<String>(
                  future: overlayPermissionFuture,
                  builder: (context, snapshot) {
                    return Text(
                      "Permissão de Sobreposição: ${snapshot.data ?? 'Erro'}",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: requestOverlayPermission,
                  child: Text("Solicitar Permissão de Sobreposição"),
                ),
                SizedBox(height: 30),
                Text(
                  "Permissão de Acessibilidade: $accessibilityStatus",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: requestAccessibilityPermission,
                  child: Text("Ativar Serviço de Acessibilidade"),
                ),
              ],
            ),




          )
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
