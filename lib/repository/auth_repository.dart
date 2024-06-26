// auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login/datasources/firebase_auth_service.dart';


class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository(this._authService);

  Future<User> signUp(String email, String password) async {
    return await _authService.signUp(email, password);
  }

  Future<User> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<void> signOut() async {
    return await _authService.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _authService.isSignedIn();
  }

  Future<User> getUser() async {
    return await _authService.getUser();
  }

  updateUserProfile(String name, String email, String phone, String linkedin, String imageUrl) {}
}
