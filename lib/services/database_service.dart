import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_list/models/models.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthenticationService _authenticationService = AuthenticationService();
  Logger logger = Logger();

  // usuarios
  Future<void> cadastrarUsuario(User user, password) async {
    final email = user.email;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw EmailAlreadyExistsException(
            'Este email já está cadastrado. Por favor, use outro email.');
      } else {
        try {
          final result = await _authenticationService.signUp(
              email: user.email, password: password);

          if (result == null) {
            await _firestore.collection('users').add({
              'username': user.username,
              'email': user.email,
              'friends': user.friends,
            });
          }

          logger.d("Sucesso");
        } catch (e) {
          logger.d(e.toString());
          rethrow;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot> listarUsuarios() async {
    try {
      logger.d("Sucesso");

      return await _firestore.collection('users').get();
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<List<User?>> listarAmigos(List<String> listaIds) async {
    try {
      List<User> amigos = [];

      for (String friendId in listaIds) {
        final amigoEncontrado = await listarUsuarioById(friendId);

        if (amigoEncontrado != null) {
          amigos.add(amigoEncontrado);
        } else {
          logger.w('Lista vazia');
        }
      }
      logger.d("Sucesso");

      return amigos;
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<User?> listarUsuarioById(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return User(
          id: userId,
          username: userData['username'],
          email: userData['email'],
          friends: List<String>.from(userData['friends']),
        );
      }
      logger.d("Sucesso");

      return null;
    } catch (e) {
      logger.d(e.toString());

      rethrow;
    }
  }

  Future<User?> listarUsuarioByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final user = User(
          id: querySnapshot.docs.first.id,
          username: userData['username'],
          email: userData['email'],
          friends: List<String>.from(userData['friends']),
        );

        logger.d("Sucesso");
        return user;
      } else {
        // Retornar null se nenhum usuário for encontrado
        return null;
      }
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<void> atualizarUsuario(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'username': user.username,
        'email': user.email,
        'friends': user.friends,
      });
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<void> excluirUsuario(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());
    }
  }

  // listas
  Future<String> cadastrarLista(Lista lista) async {
    final changeDate = Timestamp.now(); // Obtém o timestamp atual

    try {
      final DocumentReference listRef =
          await _firestore.collection('lists').add({
        'title': lista.title,
        'creatorId': lista.creatorId,
        'doneItens': lista.doneItens,
        'lengthList': lista.lengthList,
        'lastChange': changeDate
      });
      logger.d("Sucesso");
      return listRef.id;
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<QuerySnapshot> listarListas(String creatorId) async {
    try {
      logger.d("Sucesso");
      return await _firestore
          .collection('lists')
          .where('creatorId', isEqualTo: creatorId)
          .orderBy('lastChange', descending: true)
          .get();
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<Lista?> listarListasById(String id) async {
    try {
      final querySnapshot = await _firestore.collection('lists').doc(id).get();

      if (querySnapshot.exists) {
        final listData = querySnapshot.data() as Map<String, dynamic>;
        final list = Lista(
          id: querySnapshot.id,
          title: listData['title'],
          doneItens: listData['doneItens'],
          lengthList: listData['lengthList'],
          creatorId: listData['creatorId'],
          lastChange: (listData['lastChange'] as Timestamp).toDate(),
        );
        logger.d("Sucesso");

        return list;
      } else {
        return null;
      }
    } catch (e) {
      logger.d(e.toString());

      rethrow;
    }
  }

  Future<List<Lista?>> listarListasCompartilhadas(
      List<Sharing> sharings) async {
    try {
      List<Lista> sharedsList = [];

      for (Sharing sharing in sharings) {
        final listaEncontrada = await listarListasById(sharing.listId);

        if (listaEncontrada != null) {
          logger.d('Lista encontrada: ${listaEncontrada.toString()}');
          sharedsList.add(listaEncontrada);
        } else {
          logger.d('Lista vazia');
        }
      }

      logger.d("Sucesso");

      return sharedsList;
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<void> atualizarLista(Lista lista) async {
    final changeDate = Timestamp.now(); // Obtém o timestamp atual

    try {
      await _firestore.collection('lists').doc(lista.id).update({
        'title': lista.title,
        'creatorId': lista.creatorId,
        'doneItens': lista.doneItens,
        'lengthList': lista.lengthList,
        'lastChange': changeDate
      });
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<void> excluirLista(String id) async {
    try {
      await _firestore.collection('lists').doc(id).delete();

      QuerySnapshot itemsSnapshot = await _firestore
          .collection('itens')
          .where('listId', isEqualTo: id)
          .get();
      for (QueryDocumentSnapshot item in itemsSnapshot.docs) {
        await item.reference.delete();
      }

      QuerySnapshot sharingsSnapshot = await _firestore
          .collection('sharings')
          .where('listId', isEqualTo: id)
          .get();
      for (QueryDocumentSnapshot item in sharingsSnapshot.docs) {
        await item.reference.delete();
      }

      logger.d('Lista deletada');
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  // itens
  Future<String> cadastrarItem(Item item) async {
    try {
      final itemRef = await _firestore.collection('itens').add(
          {'name': item.name, 'listId': item.listId, 'isDone': item.isDone});
      logger.d("Sucesso");
      return itemRef.id;
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<void> deleteAllItems() async {
    try {
      QuerySnapshot itemsSnapshot = await _firestore.collection('itens').get();
      for (QueryDocumentSnapshot item in itemsSnapshot.docs) {
        await item.reference.delete();
      }
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());
      rethrow;
      // Trate o erro conforme necessário, como lançar uma exceção.
    }
  }

  Future<QuerySnapshot> listarItens(String listId) async {
    try {
      logger.d("Sucesso");

      return await _firestore
          .collection('itens')
          .where('listId', isEqualTo: listId)
          .get();
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }

  Future<void> atualizarItem(Item item) async {
    try {
      await _firestore.collection('itens').doc(item.id).update(
          {'name': item.name, 'listId': item.listId, 'isDone': item.isDone});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> excluirItem(String id) async {
    try {
      await _firestore.collection('itens').doc(id).delete();
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());

      rethrow;
    }
  }

  // sharings
  Future<void> cadastrarCompartilhamento(Sharing sharing) async {
    try {
      await _firestore.collection('sharings').add({
        'creatorId': sharing.creatorId,
        'guestId': sharing.guestId,
        'listId': sharing.listId
      });
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());

      rethrow;
    }
  }

  Future<QuerySnapshot> listarCompartilhamentos(String guestId) async {
    try {
      logger.d("Sucesso");

      return await _firestore
          .collection('sharings')
          .where('guestId', isEqualTo: guestId)
          .get();
    } catch (e) {
      logger.d(e.toString());

      rethrow;
    }
  }

  Future<void> atualizarCompartilhamento(Sharing sharing) async {
    try {
      await _firestore.collection('sharings').doc(sharing.id).update({
        'creatorId': sharing.creatorId,
        'guestId': sharing.guestId,
        'listId': sharing.listId
      });
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());

      rethrow;
    }
  }

  Future<void> excluirCompartilhamento(String id) async {
    try {
      await _firestore.collection('sharings').doc(id).delete();
      logger.d("Sucesso");
    } catch (e) {
      logger.d(e.toString());
      rethrow;
    }
  }
}

class EmailAlreadyExistsException implements Exception {
  final String message;

  EmailAlreadyExistsException(this.message);

  @override
  String toString() {
    return 'Erro: $message';
  }
}
