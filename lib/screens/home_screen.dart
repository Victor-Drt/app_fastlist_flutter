import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_list/models/models.dart';
import 'package:fast_list/pages/details_list_page.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/pages/new_list_page.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  ScaffoldMessengerState? meuScaffoldContext;

  bool isLoading = false;

  final FirebaseService _firebaseService = FirebaseService();
  final AuthenticationService _authenticationService = AuthenticationService();
  User? usuario;
  Lista? listaVazia =
      Lista(title: "", creatorId: "", lastChange: DateTime.now());
  List<Lista> listas = [];

  @override
  void initState() {
    super.initState();
    _getListas();
  }

  List<Lista> listaFiltrada = List.empty();

  @override
  Widget build(BuildContext context) {
    meuScaffoldContext = ScaffoldMessenger.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                    hintText: "Pesquisar...",
                    suffixIcon: Icon(Icons.search_outlined),
                    suffixIconColor: Color.fromRGBO(26, 93, 26, 100),
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromRGBO(26, 93, 26, 100)))),
                onChanged: (value) => {
                  setState(
                    () {
                      listaFiltrada = listas
                          .where((item) => item.title
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    },
                  )
                },
              ),
            ),
            Expanded(
                child: RefreshIndicator(
              onRefresh: () async => _getListas(),
              child: isLoading
                  ? const LoadingPage()
                  : listas.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Você ainda não possui Listas. Você pode criar uma clicando no botão de:",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: listaFiltrada.isEmpty
                              ? listas.length
                              : listaFiltrada.length,
                          itemBuilder: (BuildContext context, index) {
                            return listaFiltrada.isEmpty
                                ? widgetListas(context, listas[index])
                                : widgetListas(context, listaFiltrada[index]);
                          }),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Nova Lista",
        backgroundColor: const Color.fromRGBO(26, 93, 26, 100),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewListaPage(usuario: usuario)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget widgetListas(dynamic context, Lista lista) {
    var formatter = DateFormat('dd-MM-yyyy - HH:mm');
    var now = lista.lastChange?.toLocal();
    var formattedDate = formatter.format(now!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
      child: Card(
        color: const Color(0xFFFFF176),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListTile(
          title: Text(
            lista.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          onLongPress: () => _abrirDialog(context, lista),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // builder: (context) => const Placeholder(),
                builder: (context) =>
                    DetailListPage(usuario: usuario!, lista: lista),
              ),
            );
          },
          subtitle: Column(
            children: [
              const Divider(
                thickness: 1.0,
                color: Colors.green,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (lista.doneItens == lista.lengthList)
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  Text(
                    'Concluidos ${lista.doneItens} de ${lista.lengthList}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const Divider(
                thickness: 1.0,
                color: Colors.green,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedDate.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getListas() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = _authenticationService.getCurrentUserEmail();

      User? usuarioEncontrado =
          await _firebaseService.listarUsuarioByEmail(email);

      if (usuarioEncontrado != null) {
        setState(() {
          usuario = usuarioEncontrado;
        });

        QuerySnapshot querySnapshot =
            await _firebaseService.listarListas(usuario!.id!);

        setState(() {
          listas = querySnapshot.docs.map((e) {
            var data = e.data() as Map<String, dynamic>;
            return Lista(
                id: e.id,
                title: data['title'],
                doneItens: data['doneItens'],
                lengthList: data['lengthList'],
                creatorId: usuario!.id!,
                lastChange: data['lastChange'].toDate());
          }).toList();
        });

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      meuScaffoldContext?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }

  void _deletarLista(Lista lista) async {
    String id = lista.id!;

    setState(
      () => isLoading = true,
    );
    try {
      await _firebaseService.excluirLista(id);
      setState(() {
        listas.remove(lista);
      });
    } catch (e) {
      setState(
        () => isLoading = false,
      );

      meuScaffoldContext?.showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Falha ao excluir lista")));
    }

    setState(
      () => isLoading = false,
    );
  }

  void _abrirDialog(context, Lista lista) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Lista?"),
          content: const Text("Esta ação não poderá ser desfeita."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                _deletarLista(lista);
                Navigator.of(context).pop();
              },
              child: const Text('CONFIRMAR'),
            ),
          ],
        );
      },
    );
  }
}
