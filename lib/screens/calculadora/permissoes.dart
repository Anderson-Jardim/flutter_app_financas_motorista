import 'dart:async';
import 'package:app_fingo/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:notification_permissions/notification_permissions.dart' as np;
import 'package:flutter/services.dart';

class Permissoes extends StatefulWidget {
  @override
  _PermissoesState createState() => _PermissoesState();
}

class _PermissoesState extends State<Permissoes> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.app_fingo/accessibility');
  late Future<String> notificationPermissionFuture;
  late Future<String> overlayPermissionFuture;
  late Future<String> accessibilityPermissionFuture;
  String accessibilityStatus = 'Carregando...';

  @override
  void initState() {
    super.initState();
    notificationPermissionFuture = getCheckNotificationPermStatus();
    overlayPermissionFuture = getOverlayPermissionStatus();
    accessibilityPermissionFuture = getAccessibilityPermissionStatus();
    _checkAccessibilityStatus();
    WidgetsBinding.instance.addObserver(this);
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
          title: const Text('Permissões do App', style: TextStyle(color: Colors.black),)),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<String>(
                  future: notificationPermissionFuture,
                  builder: (context, snapshot) {
                    return Text(
                      "Permissão de Notificação: ${snapshot.data ?? 'Erro'}",
                      style: TextStyle(fontSize: 18),
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
                      style: TextStyle(fontSize: 18),
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
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: requestAccessibilityPermission,
                  child: Text("Ativar Serviço de Acessibilidade"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
