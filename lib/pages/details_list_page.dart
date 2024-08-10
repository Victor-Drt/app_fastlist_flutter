import 'package:fast_list/models/models.dart';
import 'package:fast_list/pages/friends_page.dart';
import 'package:fast_list/pages/home_page.dart';
import 'package:fast_list/pages/loading_page.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:fast_list/widgets/expandable_fab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class DetailListPage extends StatefulWidget {
  const DetailListPage({super.key, required this.lista, required this.usuario});

  final Lista lista;
  final User usuario;

  @override
  State<DetailListPage> createState() => _DetailListPageState();
}

class _DetailListPageState extends State<DetailListPage> {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController tituloListController = TextEditingController();
  final TextEditingController itemTituloController = TextEditingController();

  List<Item> itens = [];

  bool isSaveItemEnabled = false;
  bool isListAlreadySaved = false;
  bool isLoading = false;
  ScaffoldMessengerState? meuScaffoldContext;

  List<Item> listaItensCompleta = [];
  List<Item> itensSalvos = [];
  List<Item> itensNaoSalvos = [];
  Item? itemAtualizar;
  bool? isTitleListNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _carregarItens(widget.lista.id);
    tituloListController.text = widget.lista.title;
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat('dd-MM-yyyy - HH:mm');
    var formattedDate = formatter.format(widget.lista.lastChange!);
    String hoje = formattedDate;

    isTitleListNotEmpty = tituloListController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalhes da Lista",
          style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromRGBO(26, 93, 26, 100)),
      ),
      body: Center(
          child: Column(
        children: [
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
                        autofocus: false,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.sentences,
                        enableInteractiveSelection: false,
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
                            hoje = formatter.format(DateTime.now().toLocal());

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
                          child: Text("${itens.length} itens"),
                        )
                      ],
                    )
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(34.0, 0.0, 34.0, 0.0),
            child: Card(
              color: const Color(0xFFFFF176),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                      onChanged: (value) => {
                            setState(() {
                              itemTituloController.text.isEmpty
                                  ? isSaveItemEnabled = false
                                  : isSaveItemEnabled = true;
                              itemTituloController.text = value;
                            })
                          },
                      enableInteractiveSelection: false,
                      controller: itemTituloController,
                      autofocus: false,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Novo Item",
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(
                        () {
                          itemTituloController.text.isNotEmpty
                              ? setState(() {
                                  if (itemAtualizar == null) {
                                    var novoItem = Item(
                                        name: itemTituloController.text,
                                        isDone: false,
                                        listId: widget.lista.id!);

                                    _adicionarItem(novoItem);
                                  } else {
                                    itemAtualizar!.name =
                                        itemTituloController.text;
                                    _atualizarItem(itemAtualizar);
                                  }
                                })
                              : ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.yellow,
                                  content: Text(
                                    "Campo não pode estar vazio.",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ));
                          itemTituloController.clear();
                        },
                      )
                    },
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.green),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))))),
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
              child: itens.isEmpty
                  ? const LoadingPage()
                  : ListView.builder(
                      itemCount: itens.length,
                      itemBuilder: (BuildContext context, index) {
                        return widgetItem(itens[index]);
                      }))
        ],
      )),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () => isTitleListNotEmpty!
                ? _atualizarLista(widget.usuario, widget.lista)
                : null,
            icon: const Icon(Icons.save_outlined),
            color: isTitleListNotEmpty!
                ? const Color.fromRGBO(26, 93, 26, 100)
                : Colors.grey,
          ),
          ActionButton(
            onPressed: () async => _deleteList(widget.lista.id!),
            icon: const Icon(Icons.delete_outlined),
            color: const Color.fromRGBO(26, 93, 26, 100),
          ),
          ActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FriendsPage(
                      title: "Compartilhar com",
                      usuario: widget.usuario,
                      lista: widget.lista)),
            ),
            icon: const Icon(Icons.share_outlined),
            color: const Color.fromRGBO(26, 93, 26, 100),
          ),
        ],
      ),
    );
  }

  Widget widgetItem(Item item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
      child: Card(
          color: const Color(0xFFFFF176),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Checkbox(
                    value: item.isDone,
                    onChanged: (value) async {
                      setState(() => item.isDone = value!);

                      await _firebaseService.atualizarItem(item).then((value) =>
                          _atualizarLista(widget.usuario, widget.lista));
                    },
                  ),
                )
              ],
            ),
            onTap: () async => {
              setState(() {
                itemTituloController.text = item.name;
                itemAtualizar = item;
              })
            },
            onLongPress: () => _deleteItem(item),
          )),
    );
  }

  void _deleteList(String listId) async {
    setState(() => isLoading = true);
    try {
      await _firebaseService.excluirLista(listId);

      setState(() {
        tituloListController.clear();
        itemTituloController.clear();
        listaItensCompleta.clear();
        itensSalvos.clear();
        itensNaoSalvos.clear();

        itemAtualizar = null;

        isSaveItemEnabled = false;
        isListAlreadySaved = false;
      });
      setState(() => isLoading = false);

      nextPage();
    } catch (e) {
      setState(() => isLoading = false);

      errorSnackBar(Colors.redAccent, "Erro ao deletar Lista.");
    }
  }

  void nextPage() {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
  }

  void _atualizarLista(User usuario, Lista lista) async {
    try {
      lista.title = tituloListController.text;
      lista.doneItens = itens.where((e) => e.isDone).toList().length;
      lista.lengthList = itens.length;

      await _firebaseService.atualizarLista(lista);
    } catch (e) {
      errorSnackBar(Colors.redAccent, "Erro ao tentar atualizar lista.");
    }
  }

  void _carregarItens(String? id) async {
    QuerySnapshot querySnapshot = await _firebaseService.listarItens(id!);

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        itens = querySnapshot.docs.map((e) {
          var data = e.data() as Map<String, dynamic>;
          return Item(
              id: e.id,
              name: data['name'],
              listId: data['listId'],
              isDone: data['isDone']);
        }).toList();
      });
    }
  }

  void _adicionarItem(Item novoItem) async {
    try {
      novoItem.id = await _firebaseService.cadastrarItem(novoItem);

      widget.lista.lengthList += 1;
      await _firebaseService.atualizarLista(widget.lista);
    } catch (e) {
      errorSnackBar(Colors.redAccent, 'Erro ao adicionar Item.');
    }
    setState(() => itens.add(novoItem));
  }

  void _atualizarItem(Item? updateItem) async {
    try {
      await _firebaseService.atualizarItem(updateItem!);
      setState(() {
        var i = itens.indexOf(updateItem);
        itens[i] = updateItem;
      });

      widget.lista.doneItens = itens.where((e) => e.isDone).toList().length;
      widget.lista.lengthList = itens.length;
      await _firebaseService.atualizarLista(widget.lista);
      
    } catch (e) {
      errorSnackBar(Colors.redAccent, 'Erro ao atualizar Item.');
    }

    setState(() => itemAtualizar = null);
  }

  void _deleteItem(Item item) async {
    try {
      await _firebaseService.excluirItem(item.id!);
      setState(() {
        itens.remove(item);
      });

      widget.lista.doneItens = itens.where((e) => e.isDone).toList().length;
      widget.lista.lengthList = itens.length;
      await _firebaseService.atualizarLista(widget.lista);
    } catch (e) {
      meuScaffoldContext?.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.toString())));
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? errorSnackBar(
      Color? background, String msg) {
    return meuScaffoldContext?.showSnackBar(
        SnackBar(backgroundColor: background, content: Text(msg)));
  }
}
