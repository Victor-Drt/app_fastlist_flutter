import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para se inscrever com email e senha
  Future signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null; // Retorna null se a inscrição for bem-sucedida
    } catch (e) {
      return e.toString(); // Retorna uma mensagem de erro em caso de falha
    }
  }

  // Método para fazer login com email e senha
  Future signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Retorna null se o login for bem-sucedido
    } catch (e) {
      return e.toString(); // Retorna uma mensagem de erro em caso de falha
    }
  }

  // Método para fazer logout
  Future signOut() async {
    await _auth.signOut();
  }

  Future<void> recoveryPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw const RecoveryPasswordException('Este e-mail não está cadastrado.');
    }
  }

  // Verifica se o usuário está logado
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Retorna o ID do usuário atual
  String getCurrentUserID() {
    return _auth.currentUser!.uid;
  }

  // Retorna o email do usuário atual
  String getCurrentUserEmail() {
    return _auth.currentUser!.email!;
  }
}

class RecoveryPasswordException implements Exception {
  final String message;

  const RecoveryPasswordException(this.message);

  @override
  String toString() {
    return 'Erro: $message';
  }
}
