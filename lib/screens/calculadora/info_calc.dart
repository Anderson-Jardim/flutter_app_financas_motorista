import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CalculadoraLucroScreen extends StatefulWidget {
  @override
  _CalculadoraLucroScreenState createState() =>
      _CalculadoraLucroScreenState();
}

class _CalculadoraLucroScreenState
    extends State<CalculadoraLucroScreen> {
  bool isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      isNotificationEnabled = status.isGranted;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      setState(() {
        isNotificationEnabled = true;
      });
    } else {
      setState(() {
        isNotificationEnabled = false;
      });
    }
  }

  void _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ativar notificações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificações ativadas',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: isNotificationEnabled,
                  onChanged: (value) async {
                    if (value) {
                      await _requestNotificationPermission();
                    } else {
                      _openSettings();
                    }
                  },
                ),
              ],
            ),
            if (!isNotificationEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Notificações não estão ativadas. Por favor, ative-as nas configurações.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
