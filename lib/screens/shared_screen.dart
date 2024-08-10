import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_list/models/models.dart';
import 'package:fast_list/pages/details_list_page.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SharedScreen extends StatefulWidget {
  const SharedScreen({
    super.key,
  });

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  // database
  final FirebaseService _firebaseService = FirebaseService();
  final AuthenticationService _authenticationService = AuthenticationService();

  ScaffoldMessengerState? meuScaffoldContext;

  // data
  User? usuario;
  List<Lista?> listasCompartilhadas = [];
  List<Lista?> listas = [];
  List<Sharing> shareds = [];
  List<Lista?> listaFiltrada = List.empty();

  // ui
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getShareds();
  }

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
                          .where((item) => item!.title
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
              onRefresh: () async => _getShareds(),
              child: isLoading
                  ? const LoadingPage()
                  : listas.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Seus amigos ainda não compartilharam uma lista com você.",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: listaFiltrada.isEmpty
                              ? listas.length
                              : listaFiltrada.length,
                          itemBuilder: (BuildContext context, index) {
                            return listaFiltrada.isEmpty
                                ? widgetListas(context, listas[index]!)
                                : widgetListas(context, listaFiltrada[index]!);
                          }),
            )),
          ],
        ),
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
                    'Concluidas ${lista.doneItens} de ${lista.lengthList}',
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailListPage(usuario: usuario!, lista: lista),
              ),
            );
          },
        ),
      ),
    );
  }

  void _getShareds() async {
    setState(() => isLoading = true);
    try {
      String email = _authenticationService.getCurrentUserEmail();

      User? usuarioEncontrado =
          await _firebaseService.listarUsuarioByEmail(email);

      if (usuarioEncontrado != null) {
        setState(() {
          usuario = usuarioEncontrado;
        });

        QuerySnapshot querySnapshot = await _firebaseService
            .listarCompartilhamentos(usuarioEncontrado.id!);

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            shareds = querySnapshot.docs.map((e) {
              var data = e.data() as Map<String, dynamic>;
              return Sharing(
                  id: e.id,
                  creatorId: data['creatorId'],
                  guestId: usuarioEncontrado.id!,
                  listId: data['listId']);
            }).toList();
          });
        }

        listasCompartilhadas =
            await _firebaseService.listarListasCompartilhadas(shareds);

        setState(() {
          listas.addAll(listasCompartilhadas);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);

      meuScaffoldContext?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }
}
