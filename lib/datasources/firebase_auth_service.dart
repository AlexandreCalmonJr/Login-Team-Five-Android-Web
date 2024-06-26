import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  Future<User> signUp(String email, String password) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user!;
  }

  Future<User> login(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return result.user!;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<User> getUser() async {
    return _firebaseAuth.currentUser!;
  }
}

