import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Uri _url = Uri.parse('');

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    Future<void> abrirUrl() async {
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(26, 93, 26, 100)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Última atualização: 05/12/2023',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Esta Política de Privacidade descreve como FastList coleta, usa e compartilha informações sobre você quando você utiliza nosso aplicativo FastList.',
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Informações Coletadas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Dados de Cadastro',
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Ao se cadastrar no aplicativo, solicitamos que você forneça seu endereço de e-mail para criar e acessar sua conta.',
            ),
            const SizedBox(height: 16.0),
            // Adicione mais seções conforme necessário

            const Text(
              'Uso das Informações',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Utilizamos seu endereço de e-mail para:',
            ),
            const SizedBox(height: 8.0),
            // Adicione mais detalhes sobre o uso das informações

            // Adicione mais seções conforme necessário

            const Text(
              'Compartilhamento de Informações',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Não compartilhamos seu endereço de e-mail com terceiros, exceto quando necessário para fornecer os serviços do aplicativo.',
            ),
            const SizedBox(height: 16.0),
            // Adicione mais seções conforme necessário

            const Text(
              'Segurança',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Implementamos medidas de segurança para proteger seu endereço de e-mail contra acesso não autorizado ou divulgação.',
            ),
            const SizedBox(height: 16.0),
            // Adicione mais seções conforme necessário

            const Text(
              'Seus Direitos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
                'Você tem o direito de acessar, corrigir ou excluir suas informações. Para exercer esses direitos, entre em contato conosco.'),
            const SizedBox(height: 16.0),
            // Adicione mais seções conforme necessário

            const Text(
              'Alterações nesta Política',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Podemos atualizar esta Política de Privacidade ocasionalmente. Recomendamos que você reveja periodicamente as alterações.',
            ),
            const SizedBox(height: 16.0),
            // Adicione mais seções conforme necessário

            const Text(
              'Contato',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Se você tiver dúvidas sobre esta Política de Privacidade, entre em contato conosco em:',
            ),
            TextButton(
                onPressed: () => {
                      setState(
                        () => _url = Uri.parse("https://github.com/Victor-Drt"),
                      ),
                      abrirUrl()
                    },
                child: const Text("GitHub")),
            TextButton(
                onPressed: () => {
                      setState(
                        () => _url = Uri.parse("https://www.linkedin.com/in/victorduarte2/"),
                      ),
                      abrirUrl()
                    },
                child: const Text("LinkedIn")),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
