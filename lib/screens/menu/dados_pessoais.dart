import 'package:app_fingo/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../login/login.dart';
import '../login/welcome.dart';


class InfoPessoais extends StatefulWidget {
  @override
  _InfoPessoaisState createState() => _InfoPessoaisState();
}

class _InfoPessoaisState extends State<InfoPessoais> {
  User? user;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  bool loadingupdate = true;
  TextEditingController nameController = TextEditingController(),
      usernameController = TextEditingController(),
      contactController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  

  void _updateUser() async {
    ApiResponse response = await updateUser(nameController.text, usernameController.text, contactController.text, passwordController.text);
    if (mounted) {
      setState(() {
        loadingupdate = false;
      });
      if (response.error == null) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.data}')
        ));
      } else if (response.error == unauthorized) {
        logout().then((value) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (route) => false);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}')
        ));
      }
    }
  }

  // Save and redirect to home
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
    }
  }

  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          user = response.data as User;
          loading = false;
          nameController.text = user!.name ?? '';
          usernameController.text = user!.username ?? '';
          contactController.text = user!.contact ?? '';
        });
      }
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (mounted) {
         // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}')
        ));
      }
    }
  }

  @override
  void initState() {
    getUser();
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
        'Dados Cadastrais',
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
    ),
      backgroundColor: Color(0xFF171f20),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.06),
                Container(
                  width: width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 45,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'Precisamos\n'),
                            TextSpan(
                              text: 'conhecer\nvocê.',
                              style: TextStyle(color: Color(0xFF00ff75)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ), */
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: contactController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um número ou e-mail válido';
                          }

                          // Regular expression for phone number (10 to 15 digits)
                          final phoneRegex = RegExp(r'^[0-9]{10,15}$');

                          // Check if the value is a valid email
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) && !phoneRegex.hasMatch(value)) {
                            return 'Insira um número ou e-mail válido';
                          }
                          return null;
                        },
                        decoration: kInputDecoration('Número ou e-mail'),
                      ),
                      SizedBox(height: height * 0.04),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: nameController,
                        validator: (val) => val!.isEmpty ? 'Nome inválido' : null,
                        decoration: kInputDecoration('Nome completo'),
                      ),
                      SizedBox(height: height * 0.04),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: usernameController,
                        validator: (val) => val!.isEmpty ? 'Nome de usuário inválido' : null,
                        decoration: kInputDecoration('Nome de usuário'),
                      ),
                      SizedBox(height: height * 0.04),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: passwordController,
                        obscureText: true,
                        validator: (val) => val!.length < 6 ? 'Senha inferior a 6 digitos' : null,
                        decoration: kInputDecoration('Senha'),
                      ),
                      SizedBox(height: height * 0.04),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: passwordConfirmController,
                        obscureText: true,
                        validator: (val) => val != passwordController.text ? 'A senha não é a mesma' : null,
                        decoration: kInputDecoration('Confirmar senha'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                kTextButton('Salvar', () async {
                  if (formKey.currentState!.validate()) {
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    bool isAuthenticated = pref.getString('token') != null;
                    if (mounted) {
                      setState(() {
                        loading = true;
                      });
                    }
                    if (isAuthenticated) {
                      _updateUser();
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (route) => false);
                    }
                  }
                },
                  EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: width * 0.30,
                  ),
                  height * 0.025,
                ),
                SizedBox(height: height * 0.02),
                SizedBox(height: height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
