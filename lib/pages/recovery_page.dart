import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/pages/login_page.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:flutter/material.dart';

class RecoveryPasswordPage extends StatefulWidget {
  const RecoveryPasswordPage({super.key});

  @override
  State<RecoveryPasswordPage> createState() => _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends State<RecoveryPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ScaffoldMessengerState? meuScaffoldContext;

  bool isLoading = false;
  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {

    ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? errorSnackBar(
        Color? background, String msg) {
      return meuScaffoldContext?.showSnackBar(
          SnackBar(backgroundColor: background, content: Text(msg)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recuperar Senha",
          style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(26, 93, 26, 100)),
      ),
      body: isLoading
          ? const LoadingPage()
          : Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 120.0),
                        child: Text(
                          "Um link para redefinição de senha será enviado. Insira o e-mail cadastrado.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 8.0),
                        child: TextFormField(
                          controller: _emailController,
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(26, 93, 26, 100))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(26, 93, 26, 100))),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color.fromRGBO(26, 93, 26, 100),
                              ),
                              hintText: 'E-mail'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo não pode estar vazio';
                            }
                            final emailRegExp = RegExp(
                                r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                            if (!emailRegExp.hasMatch(value)) {
                              return 'Digite um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 250.0, 32.0, 16.0),
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _authenticationService
                                      .recoveryPassword(_emailController.text);

                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                  );
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  errorSnackBar(Colors.redAccent, 'Erro ao tentar recuperar senha.');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(26, 93, 26, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Ajuste o raio conforme necessário.
                              ),
                            ),
                            child: const Text('ENVIAR LINK'),
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
