// auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginWithEmailPassword>((event, emit) async {
      try {
        emit(AuthLoading());

        await _auth.signInWithEmailAndPassword(email: event.email, password: event.password);

        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpWithEmailPassword>((event, emit) async {
      try {
        emit(AuthLoading());

        await _auth.createUserWithEmailAndPassword(email: event.email, password: event.password);

        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          'email': event.email,
        });

        emit(Authenticated()); // Emitir Authenticated ao se inscrever com sucesso
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateUserProfile>((event, emit) async {
      try {
        emit(AuthLoading());

        await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
          'name': event.name,
          'email': event.email,
          'phone': event.phone,
          'linkedin': event.linkedin,
          'imageUrl': event.imageUrl,
        });

        emit(Authenticated());
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

  
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is SignUpSuccess) {
      yield Authenticated();
    }
  }
}
