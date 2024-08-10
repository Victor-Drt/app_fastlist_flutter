import 'package:fast_list/models/models.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/pages/login_page.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _obscurePassword = true;
  var _obscurePasswordConfirm = true;

  bool isLoading = false;

  // database
  final FirebaseService _firebaseService = FirebaseService();
  User? usuario;

  var msgError = 'Ocorreu um erro ao completar cadastro';

  Future<bool> _cadastrarUsuario(User u, String password) async {
    try {
      await _firebaseService.cadastrarUsuario(u, password);

      return true;
    } catch (e) {
      setState(() {
        msgError = e.toString();
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registre-se",
            style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100))),
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
                      const Icon(
                        Icons.account_circle_outlined,
                        color: Color.fromRGBO(26, 93, 26, 100),
                        size: 124,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
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
                          controller: _usernameController,
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
                                Icons.person_2_outlined,
                                color: Color.fromRGBO(26, 93, 26, 100),
                              ),
                              hintText: 'Username'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo não pode estar vazio';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
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
                                Icons.lock_outline,
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
                            const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 64.0),
                        child: TextFormField(
                          obscureText: _obscurePasswordConfirm,
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
                                Icons.lock_outline,
                                color: Color.fromRGBO(26, 93, 26, 100),
                              ),
                              suffixIcon: IconButton(
                                  onPressed: () => {
                                        setState(() {
                                          _obscurePasswordConfirm =
                                              !_obscurePasswordConfirm;
                                        })
                                      },
                                  icon: _obscurePasswordConfirm
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
                              hintText: 'Confirm Password'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo não pode estar vazio';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            if (value != _passwordController.text) {
                              return 'Senhas não conferem';
                            }
                            return null;
                          },
                          controller: _passwordConfirmController,
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => isLoading = true);

                                usuario = User(
                                    username: _usernameController.text,
                                    email: _emailController.text,
                                    friends: []);

                                try {
                                  final registroBemSucedido =
                                      await _cadastrarUsuario(
                                          usuario!, _passwordController.text);

                                  if (registroBemSucedido) {
                                    setState(() => isLoading = false);

                                    // ignore: use_build_context_synchronously
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  } else {
                                    setState(() => isLoading = false);

                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(msgError)));
                                  }
                                } catch (e) {
                                  setState(() {
                                    msgError = e.toString();
                                  });
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
                            child: const Text('REGISTRAR'),
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
