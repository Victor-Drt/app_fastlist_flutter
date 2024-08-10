// Modelo de usuário
class User {
  String? id;
  String username;
  String email;
  List<String> friends; // Lista de IDs de amigos

  User({
    this.id,
    required this.username,
    required this.email,
    required this.friends,
  });

  @override
  String toString() {
    return '$id, $username, $email, $friends';
  }
}

// Modelo de Lista
class Lista {
  String? id;
  String title;
  String creatorId;
  int doneItens;
  int lengthList;

  DateTime? lastChange;

  Lista({
    this.id,
    required this.title,
    required this.creatorId,
    this.doneItens = 0,
    this.lengthList = 0,
    this.lastChange,
  });

  @override
  String toString() {
    return '$id, $title, $creatorId, $doneItens $lengthList $lastChange';
  }
}

// Modelo de Item
class Item {
  String? id;
  String name;
  String listId;
  bool isDone;

  Item(
      {this.id, required this.name, required this.listId, this.isDone = false});

  @override
  String toString() {
    return '$id, $name, $listId, $isDone';
  }
}

// Modelo de Compartilhamento
class Sharing {
  String? id;
  String creatorId;
  String guestId;
  String listId;

  Sharing({
    this.id,
    required this.creatorId,
    required this.guestId,
    required this.listId,
  });

  @override
  String toString() {
    return '$id, $creatorId, $guestId, $listId';
  }
}
