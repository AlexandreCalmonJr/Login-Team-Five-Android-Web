import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_login/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginWithEmailPassword>((event, emit) async {
      try {
        emit(AuthLoading());

        await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpWithEmailPassword>((event, emit) async {
      try {
        emit(AuthLoading());

        await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      try {
        emit(GoogleAuthLoading());

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(Unauthenticated()); // Usuário cancelou o fluxo de login do Google
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          emit(LoginWithGoogleSuccess()); // Emite o evento de sucesso de login com Google
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpWithGoogle>((event, emit) async {
      try {
        emit(GoogleAuthLoading());

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(Unauthenticated()); // Usuário cancelou o fluxo de login do Google
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          emit(Authenticated());
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateUserProfile>((event, emit) async {
      try {
        emit(AuthLoading());

        // Implemente sua lógica para atualização do perfil do usuário
        emit(Authenticated()); // Supondo atualização de perfil bem-sucedida
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<Logout>((event, emit) async {
      try {
        emit(AuthLoading());
        await _auth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }

}
