// auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmailPassword extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailPassword(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailPassword extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailPassword(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class UpdateUserProfile extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String linkedin;
  final String imageUrl;

  const UpdateUserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [name, email, phone, linkedin, imageUrl];
}

class Logout extends AuthEvent {}

class SignUpSuccess extends AuthEvent {}

class LoginWithGoogle extends AuthEvent {}

class SignUpWithGoogle extends AuthEvent {} // Certifique-se que SignUpWithGoogle está definido aqui
