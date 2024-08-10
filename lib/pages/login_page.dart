import 'package:fast_list/pages/home_page.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/pages/recovery_page.dart';
import 'package:fast_list/pages/register_page.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationService _authenticationService = AuthenticationService();
  var _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    void nextPage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }

    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        child: Image.asset('assets/images/logo.png',
                            width: 250, height: 250),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
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
                            const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                        child: TextFormField(
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(26, 93, 26, 100))),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(26, 93, 26, 100))),
                              prefixIcon: const Icon(
                                Icons.key_outlined,
                                color: Color.fromRGBO(26, 93, 26, 100),
                              ),
                              suffixIcon: IconButton(
                                  onPressed: () => {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        })
                                      },
                                  icon: _obscurePassword
                                      ? const Icon(
                                          Icons.remove_red_eye_outlined,
                                          color:
                                              Color.fromRGBO(26, 93, 26, 100),
                                        )
                                      : const Icon(
                                          Icons.remove_red_eye,
                                          color:
                                              Color.fromRGBO(26, 93, 26, 100),
                                        )),
                              hintText: 'Password'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo não pode estar vazio';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Row(
                            //   children: [
                            //     Checkbox(
                            //       checkColor:
                            //           const Color.fromRGBO(26, 93, 26, 100),
                            //       shape: const CircleBorder(
                            //           side: BorderSide(
                            //               color:
                            //                   Color.fromRGBO(26, 93, 26, 100),
                            //               width: 1)),
                            //       value: isChecked,
                            //       onChanged: ((bool? value) {
                            //         setState(() {
                            //           isChecked = value!;
                            //         });
                            //       }),
                            //     ),
                            //     const Text("Mantenha-me conectado"),
                            //   ],
                            // ),
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RecoveryPasswordPage()),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "Esqueci a senha",
                                    style: TextStyle(
                                        color: Color.fromRGBO(26, 93, 26, 100),
                                        fontStyle: FontStyle.italic),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  50.0, 8.0, 50.0, 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(26, 93, 26, 100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Ajuste o raio conforme necessário.
                                  ),
                                ),
                                child: const Text('LOGIN'),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final mcontext =
                                        ScaffoldMessenger.of(context);
                                    setState(() => isLoading = true);

                                    final email = _emailController.text;
                                    final password = _passwordController.text;

                                    final successLogin =
                                        await _login(email, password);

                                    if (successLogin) {
                                      nextPage();
                                    } else {
                                      setState(() => isLoading = false);
                                      mcontext.showSnackBar(const SnackBar(
                                          content: Text(
                                              'E-mail ou senha incorretos.')));
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const Text("ou"),
                          SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  50.0, 8.0, 50.0, 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(26, 93, 26, 100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('REGISTRE-SE'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<bool> _login(String email, String password) async {
    try {
      final resultSignin =
          await _authenticationService.signIn(email: email, password: password);
      return resultSignin == null;
    } catch (e) {
      return false;
    }
  }
}
