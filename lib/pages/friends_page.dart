import 'package:fast_list/models/models.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key, required this.title, this.usuario, this.lista});

  final String title;
  final User? usuario;
  final Lista? lista;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // database
  final FirebaseService _firebaseService = FirebaseService();
  List<User?> amigos = [];

  // search
  TextEditingController searchController = TextEditingController();
  final myGreenColor = const Color.fromRGBO(26, 93, 26, 100);

  ScaffoldMessengerState? contextoSnack;

  bool isLoading = false;

  List<SelectedUser> usuarios = [];
  List<String> compartilharCom = [];
  List<SelectedUser> listaFiltrada = List.empty();

  @override
  void initState() {
    super.initState();
    _getUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var usersIsSelected = usuarios.any((u) => u.isSelected);
    contextoSnack = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: myGreenColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: myGreenColor),
        actions: [
          IconButton(
              onPressed: usersIsSelected
                  ? () => {
                        _compartilharLista(compartilharCom),
                      }
                  : null,
              icon: Icon(
                Icons.check,
                color: usersIsSelected ? myGreenColor : Colors.grey,
              ))
        ],
      ),
      body: isLoading
          ? const LoadingPage()
          : usuarios.isEmpty
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Voce pode adicionar um novo amigo clicando no icone: ",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.group_add_outlined,
                            color: Colors.grey,
                          )
                        ],
                      )),
                )
              : Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Pesquisar...",
                              suffixIcon: const Icon(Icons.search_outlined),
                              suffixIconColor: myGreenColor,
                              hintStyle: const TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.0, color: myGreenColor))),
                          onChanged: (value) => {
                            setState(
                              () {
                                listaFiltrada = usuarios
                                    .where((item) => item.username
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                              },
                            )
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: listaFiltrada.isEmpty
                                ? usuarios.length
                                : listaFiltrada.length,
                            itemBuilder: (BuildContext context, index) {
                              return listaFiltrada.isEmpty
                                  ? widgetUsuario(usuarios[index])
                                  : widgetUsuario(listaFiltrada[index]);
                            }),
                      )
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: myGreenColor,
          child: const Icon(Icons.group_add_outlined),
          onPressed: () => {_mostrarDialogAdicionarAmigo(context)}),
    );
  }

  Widget widgetUsuario(SelectedUser usuario) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          children: [
            ListTile(
              selected: usuario.isSelected,
              onTap: () => {
                widget.title != "Amigos"
                    ? () => {
                          compartilharCom.isEmpty
                              ? compartilharCom.add(usuario.id!)
                              : null,
                          _compartilharLista(compartilharCom)
                        }
                    : () => {}
              },
              onLongPress: () => {
                widget.title != "Amigos"
                    ? setState(() {
                        usuario.isSelected = !usuario.isSelected;
                        usuario.isSelected
                            ? compartilharCom.add(usuario.id!)
                            : compartilharCom.remove(usuario.id);
                      })
                    : () => {},
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 32.0, 8.0, 32.0),
                    child: IconButton(
                      icon: const Icon(Icons.account_circle_outlined),
                      color: myGreenColor,
                      onPressed: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 40.0),
                    child: Text(
                      usuario.username,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 32.0, 16.0, 32.0),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: myGreenColor,
                      onPressed: () {
                        setState(() {
                          _mostrarDialogRemoverAmigo(context, usuario.id!);
                          // usuarios.remove(usuario);
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogAdicionarAmigo(BuildContext context) {
    TextEditingController emailFriendController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar amigo'),
          content: TextFormField(
            controller: emailFriendController,
            decoration: InputDecoration(
              hintText: 'Insira o email do seu amigo',
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: myGreenColor)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: myGreenColor)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo não pode estar vazio';
              }
              final emailRegExp =
                  RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
              if (!emailRegExp.hasMatch(value)) {
                return 'Digite um e-mail válido.';
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: myGreenColor),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => isLoading = true);

                String textoDigitado = emailFriendController.text;

                _adicionarAmigo(textoDigitado);

                setState(() => isLoading = false);

                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text(
                'Salvar',
                style: TextStyle(color: myGreenColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogRemoverAmigo(BuildContext context, String idAmigo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Remover Amigo?"),
            content: const Text(
                "Voce estará removendo este usuario de sua lista de amigos. Deseja continuar?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: myGreenColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  setState(() => isLoading = true);

                  _removeFriend(idAmigo);

                  setState(() => isLoading = false);

                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                child: Text(
                  'Confimar',
                  style: TextStyle(color: myGreenColor),
                ),
              ),
            ],
          );
        });
  }

  void _getUsuario() async {
    setState(() => isLoading = true);

    try {
      var usuario = widget.usuario;

      if (usuario != null) {
        final amigosEncontrados =
            await _firebaseService.listarAmigos(usuario.friends);

        setState(() {
          if (amigosEncontrados.isNotEmpty) {
            usuarios = amigosEncontrados
                .map((e) => SelectedUser(
                    id: e?.id,
                    username: e!.username,
                    email: e.email,
                    friends: e.friends,
                    isSelected: false))
                .toList();
          } else {
            usuarios = [];
          }

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      contextoSnack?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }

  void _removeFriend(String idAmigo) async {
    setState(() => isLoading = true);

    widget.usuario?.friends.remove(idAmigo);

    try {
      await _firebaseService.atualizarUsuario(widget.usuario!);

      _getUsuario();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      contextoSnack?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }

  void _adicionarAmigo(String email) async {
    try {
      User? usuarioEncontrado =
          await _firebaseService.listarUsuarioByEmail(email);

      widget.usuario?.friends.add(usuarioEncontrado!.id!);

      await _firebaseService.atualizarUsuario(widget.usuario!);

      _getUsuario();
    } catch (e) {
      contextoSnack?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }

  void _compartilharLista(List<String> enviarPara) async {
    setState(() => isLoading = true);

    for (String amigoId in enviarPara) {
      Sharing sharedList = Sharing(
          creatorId: widget.usuario!.id!,
          guestId: amigoId,
          listId: widget.lista!.id!);

      try {
        await _firebaseService.cadastrarCompartilhamento(sharedList);
      } catch (e) {
        setState(() => isLoading = false);
        contextoSnack?.showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Falha ao compartilhar lista!')));
      }
    }
    nextPage();
    setState(() => isLoading = false);
  }

  void nextPage() {
    Navigator.pop(
      context,
    );
  }
}

class SelectedUser extends User {
  bool isSelected;

  SelectedUser(
      {required super.id,
      required super.username,
      required super.email,
      required super.friends,
      this.isSelected = false});
}
