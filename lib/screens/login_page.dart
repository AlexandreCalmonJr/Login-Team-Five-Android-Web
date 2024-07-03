import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_login/blocs/auth/auth_bloc.dart';
import 'package:firebase_login/blocs/auth/auth_event.dart';
import 'package:firebase_login/blocs/auth/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>(); // Obtém o AuthBloc do contexto

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Botão de Login com Google
                GoogleSignInButton(authBloc: authBloc),

                const SizedBox(height: 20),

                // Campos de E-mail/Senha e botão de Login
                _buildEmailPasswordFields(context, authBloc),

                const SizedBox(height: 20),

                // BlocListener para reagir às mudanças de estado do AuthBloc
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated || state is LoginWithGoogleSuccess) {
                      Navigator.pushNamed(context, '/profile');
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const CircularProgressIndicator();
                      }
                      return Container(); // Pode retornar um widget vazio ou outra coisa, conforme necessário
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPasswordFields(BuildContext context, AuthBloc authBloc) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Column(
      children: <Widget>[
        TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            authBloc.add(
              LoginWithEmailPassword(
                emailController.text,
                passwordController.text,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Login', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final AuthBloc authBloc;

  const GoogleSignInButton({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        authBloc.add(LoginWithGoogle());
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'assets/google_logo.png', // Substitua pelo caminho correto da sua logo do Google
            height: 24.0,
          ),
          const SizedBox(width: 12),
          const Text(
            'Use sua conta do Google',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
