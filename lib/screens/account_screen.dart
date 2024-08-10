import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_list/models/models.dart';
import 'package:fast_list/pages/friends_page.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/pages/login_page.dart';
import 'package:fast_list/pages/recovery_page.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final FirebaseService _firebaseService = FirebaseService();
  ScaffoldMessengerState? meuScaffoldContext;

  Logger logger = Logger();
  User? usuario;

  bool isLoading = false;

  int qtdListas = 0;
  int qtdAmigos = 0;
  String username = "";

  @override
  void initState() {
    super.initState();
    _getUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.all(34)),
                    const Icon(
                      Icons.account_circle_outlined,
                      color: Color.fromRGBO(26, 93, 26, 100),
                      size: 160,
                    ),
                    Text(
                      usuario != null ? usuario!.username : "",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 64.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.group,
                                color: Color.fromRGBO(26, 93, 26, 100),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    usuario != null
                                        ? qtdAmigos.toString()
                                        : "0",
                                    style: const TextStyle(fontSize: 16),
                                  )),
                              const Icon(
                                Icons.list,
                                color: Color.fromRGBO(26, 93, 26, 100),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  usuario != null ? qtdListas.toString() : "0",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.key),
                              title: const Text('Redefinir Senha'),
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RecoveryPasswordPage()),
                                )
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.group),
                              title: const Text('Amigos'),
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FriendsPage(
                                            title: "Amigos",
                                            usuario: usuario,
                                          )),
                                )
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.close),
                              title: const Text('Encerrar Sessão'),
                              onTap: () async {
                                setState(() => isLoading = true);

                                final logoutResult = await _logout();

                                if (logoutResult) {
                                  setState(() => isLoading = false);

                                  nextPage();
                                } else {
                                  setState(() => isLoading = false);
                                  errorSnackBar(Colors.redAccent,
                                      'Não foi possivel fazer logout.');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? errorSnackBar(
      Color? background, String msg) {
    return meuScaffoldContext?.showSnackBar(
        SnackBar(backgroundColor: background, content: Text(msg)));
  }

  void nextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<bool> _logout() async {
    try {
      final resultLogout = await _authenticationService.signOut();
      return resultLogout == null;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  void _getUsuario() async {
    try {
      String email = _authenticationService.getCurrentUserEmail();

      User? usuarioEncontrado =
          await _firebaseService.listarUsuarioByEmail(email);

      if (usuarioEncontrado != null) {
        setState(() => usuario = usuarioEncontrado);

        QuerySnapshot querySnapshot =
            await _firebaseService.listarListas(usuario!.id!);

        setState(() {
          username = usuarioEncontrado.username;
          qtdAmigos = usuarioEncontrado.friends.length;
          qtdListas = querySnapshot.docs.length;
        });
      }
    } catch (e) {
      errorSnackBar(Colors.redAccent, 'Não foi possivel fazer logout.');
    }
  }
}
