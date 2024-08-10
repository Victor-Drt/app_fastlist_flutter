import 'package:fast_list/pages/privacy_terms_page.dart';
import 'package:fast_list/pages/surprise_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Logger logger = Logger();
  int contador = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sobre o App",
          style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(26, 93, 26, 100)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Sobre o App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 100),
              const Text(
                'O app FastList foi criado com a intenção de ajudar no registro de pequenas atividades e afazeres. Desenvolvido como parte dos meus estudos sobre Flutter utilizando Firebase como banco de dados.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Desenvolvido por Victor Duarte',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                      onPressed: () async => {
                            setState(
                              () => contador++,
                            ),
                            contador == 10
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        // ignore: prefer_const_constructors
                                        builder: (context) => SurprisePage()))
                                : logger.d(
                                    "nada de interessante aqui, circulando..."),
                          },
                      child: const Text("🤓"))
                ],
              ),
              TextButton(
                child: const Text("Termos de Privacidade"),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => const PrivacyPolicyPage()),
                  )
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
