import 'package:fast_list/pages/friends_page.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:fast_list/widgets/expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fast_list/models/models.dart';

class NewListaPage extends StatefulWidget {
  const NewListaPage({super.key, this.usuario});

  final User? usuario;
  final Item? item = null;

  @override
  State<NewListaPage> createState() => _NewListaPageState();
}

class _NewListaPageState extends State<NewListaPage> {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController tituloListController = TextEditingController();
  final TextEditingController itemTituloController = TextEditingController();

  bool isSaveItemEnabled = false;
  bool isListAlreadySaved = false;
  bool isLoading = false;
  ScaffoldMessengerState? meuScaffoldContext;

  Lista? novaLista;
  List<Item> listaItensCompleta = [];
  List<Item> itensSalvos = [];
  List<Item> itensNaoSalvos = [];
  Item? itemAtualizar;
  int indice = 0;

  Widget widgetItem(Item item, index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
      child: Card(
        color: const Color(0xFFFFF176),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center, // Centraliza verticalmente
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Checkbox(
                  value: item.isDone,
                  onChanged: (value) {
                    setState(() {
                      item.isDone = value!;
                    });

                    item.id != null ? _atualizarItem(item) : null;
                  },
                ),
              ),
            ],
          ),
          onLongPress: () => {
            setState(
              () {
                itensSalvos.contains(item)
                    ? _deleteItem(item)
                    : listaItensCompleta.remove(item);
              },
            )
          },
          onTap: () => {
            setState(
              () {
                itemTituloController.text = item.name;

                if (listaItensCompleta.contains(item)) {
                  itemAtualizar = item;
                  indice = index;
                }
              },
            ),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    meuScaffoldContext = ScaffoldMessenger.of(context);

    var formatter = DateFormat('dd-MM-yyyy - HH:mm');
    var now = DateTime.now().toLocal();
    var formattedDate = formatter.format(now);
    String hoje = formattedDate;

    bool isTitleListNotEmpty = tituloListController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nova Lista",
          style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(26, 93, 26, 100)),
      ),
      body: isLoading
          ? const LoadingPage()
          : Center(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(34.0),
                  child: Card(
                    color: const Color(0xFFFFF176),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: tituloListController,
                            enableInteractiveSelection: false,
                            autofocus: false,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                                hintText: "Titulo da Lista",
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFF57F17))),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFF57F17)))),
                            onChanged: (value) => {
                              setState(() {
                                now = DateTime.now().toLocal();
                                hoje = formatter.format(now);

                                tituloListController.text = value;
                              })
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(hoje),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${listaItensCompleta.length} itens"),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(34.0, 0.0, 34.0, 0.0),
                  child: Card(
                    color: const Color(0xFFFFF176),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                                controller: itemTituloController,
                                autofocus: false,
                                enableInteractiveSelection: false,
                                textAlign: TextAlign.center,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (value) {
                                  setState(() {
                                    itemTituloController.text.isEmpty
                                        ? isSaveItemEnabled = false
                                        : isSaveItemEnabled = true;
                                    itemTituloController.text = value;
                                  });
                                },
                                decoration: const InputDecoration.collapsed(
                                  hintText: "Novo Item",
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                            child: ElevatedButton(
                              onPressed: isSaveItemEnabled &
                                      itemTituloController.text.isNotEmpty
                                  ? () => {
                                        setState(
                                          () {
                                            if (itemAtualizar != null) {
                                              if (itemAtualizar?.id != null) {
                                                itemAtualizar!.name =
                                                    itemTituloController.text;

                                                _atualizarItem(itemAtualizar!);
                                                listaItensCompleta[indice]
                                                        .name =
                                                    itemTituloController.text;
                                              } else {
                                                listaItensCompleta[indice]
                                                        .name =
                                                    itemTituloController.text;
                                              }
                                            } else {
                                              var novoItem = Item(
                                                  name:
                                                      itemTituloController.text,
                                                  listId: "");
                                              itensNaoSalvos.add(novoItem);

                                              listaItensCompleta.add(novoItem);
                                            }

                                            itemTituloController.clear();

                                            itemAtualizar = null;
                                            indice = 0;
                                          },
                                        )
                                      }
                                  : null,
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      isSaveItemEnabled
                                          ? Colors.green
                                          : Colors.grey),
                                  shape: const MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))))),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: listaItensCompleta.length,
                        itemBuilder: (BuildContext context, index) {
                          return widgetItem(listaItensCompleta[index], index);
                        }))
              ]),
            ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () => isTitleListNotEmpty
                ? _saveList(widget.usuario, novaLista, itensNaoSalvos)
                : null,
            icon: const Icon(Icons.save_outlined),
            color: isTitleListNotEmpty
                ? const Color.fromRGBO(26, 93, 26, 100)
                : Colors.grey,
          ),
          ActionButton(
            onPressed: () =>
                isListAlreadySaved ? deleteList(novaLista!.id!) : null,
            icon: const Icon(Icons.delete_outlined),
            color: isListAlreadySaved
                ? const Color.fromRGBO(26, 93, 26, 100)
                : Colors.grey,
          ),
          ActionButton(
            onPressed: () => isListAlreadySaved
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FriendsPage(
                            title: "Compartilhar com",
                            usuario: widget.usuario,
                            lista: novaLista)),
                  )
                : null,
            icon: const Icon(Icons.share_outlined),
            color: isListAlreadySaved
                ? const Color.fromRGBO(26, 93, 26, 100)
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _saveList(User? usuario, Lista? lista, List<Item> itensASalvar) async {
    setState(() => isLoading = true);

    if (isListAlreadySaved) {
      novaLista?.title = tituloListController.text;
      int doneItens = itensASalvar.where((element) => element.isDone).length;
      int tamanhoLista = itensASalvar.length;

      novaLista!.doneItens += doneItens;
      novaLista!.lengthList += tamanhoLista;

      try {
        await _firebaseService.atualizarLista(novaLista!);

        if (itensASalvar.isNotEmpty) {
          listaItensCompleta = [];

          for (Item item in itensASalvar) {
            item.listId = novaLista!.id!;
            item.id = await _firebaseService.cadastrarItem(item);
            itensSalvos.add(item);
          }

          itensNaoSalvos = [];

          setState(() {
            listaItensCompleta = itensSalvos;
          });
        }

        setState(() => isLoading = false);

        meuScaffoldContext?.showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Salvo com sucesso!")));
      } catch (e) {
        setState(() => isLoading = false);

        meuScaffoldContext?.showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent, content: Text(e.toString())));
      }
    } else {
      int doneItens = itensASalvar.where((element) => element.isDone).length;
      lista = Lista(
          title: "",
          creatorId: "",
          lastChange: DateTime.now(),
          doneItens: doneItens,
          lengthList: listaItensCompleta.length);

      lista.creatorId = usuario!.id!;
      lista.title = tituloListController.text;

      try {
        lista.id = await _firebaseService.cadastrarLista(lista);

        if (itensASalvar.isNotEmpty) {
          listaItensCompleta = [];

          for (Item item in itensASalvar) {
            item.listId = lista.id!;
            item.id = await _firebaseService.cadastrarItem(item);
            itensSalvos.add(item);
          }

          itensNaoSalvos = [];
        }

        setState(() {
          isSaveItemEnabled = true;
          isListAlreadySaved = true;
          novaLista = lista;
          listaItensCompleta = itensSalvos + itensNaoSalvos;
        });

        setState(() => isLoading = false);

        meuScaffoldContext?.showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Salvo com sucesso!")));
      } catch (e) {
        setState(() => isLoading = false);

        meuScaffoldContext?.showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent, content: Text(e.toString())));
      }
    }
  }

  void deleteList(String listId) async {
    try {
      await _firebaseService.excluirLista(listId);
      setState(() {
        tituloListController.clear();
        itemTituloController.clear();
        listaItensCompleta.clear();
        itensSalvos.clear();
        itensNaoSalvos.clear();

        novaLista = null;
        indice = 0;
        itemAtualizar = null;

        isSaveItemEnabled = false;
        isListAlreadySaved = false;
      });
    } catch (e) {
      meuScaffoldContext?.showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Falha ao excluir lista")));
    }
  }

  void _atualizarItem(Item item) async {
    try {
      novaLista?.doneItens = listaItensCompleta.where((e) => e.isDone).length;
      novaLista?.lengthList = listaItensCompleta.length;

      await _firebaseService.atualizarItem(item);

      await _firebaseService.atualizarLista(novaLista!);
    } catch (e) {
      meuScaffoldContext?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }

  void _deleteItem(Item item) async {
    try {
      await _firebaseService.excluirItem(item.id!);

      setState(() {
        listaItensCompleta.remove(item);
      });

      novaLista!.doneItens = listaItensCompleta.where((e) => e.isDone).toList().length;
      novaLista!.lengthList = listaItensCompleta.length;
      await _firebaseService.atualizarLista(novaLista!);
      
    } catch (e) {
      meuScaffoldContext?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }
}
