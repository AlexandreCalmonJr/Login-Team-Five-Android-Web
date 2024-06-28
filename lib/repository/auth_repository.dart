import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login/datasources/firebase_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository(this._authService);

  Future<User?> signUp(String email, String password) async {
    return await _authService.signUp(email, password);
  }

  Future<User?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<void> signOut() async {
    return await _authService.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _authService.isSignedIn();
  }

  Future<User?> getUser() async {
    return await _authService.getUser();
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // Obtain auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with Google credentials
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        return userCredential.user;
      } else {
        throw FirebaseAuthException(message: 'Google sign in aborted by user', code: 'ERROR_ABORTED_BY_USER');
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      // Handle other exceptions
      throw FirebaseAuthException(code: 'ERROR_UNKNOWN', message: e.toString());
    }
  }
}
