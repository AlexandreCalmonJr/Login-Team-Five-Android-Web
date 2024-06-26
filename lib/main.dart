import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login/blocs/auth/auth_bloc.dart';
import 'package:firebase_login/configurations.dart';
import 'package:firebase_login/repository/auth_repository.dart';
import 'package:firebase_login/screens/home_page.dart';
import 'package:firebase_login/screens/login_page.dart';
import 'package:firebase_login/screens/profile_page.dart';
import 'package:firebase_login/screens/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/datasources/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: Configurations.apiKey,
      authDomain: Configurations.authDomain,
      databaseURL: Configurations.databaseUrl,
      projectId: Configurations.projectId,
      storageBucket: Configurations.storageBucket,
      messagingSenderId: Configurations.messagingSenderId,
      appId: Configurations.appId,
      measurementId: Configurations.measurementId,
    ),
  );

  final authService = FirebaseAuthService(FirebaseAuth.instance);
  final authRepository = AuthRepository(authService);

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: authRepository),
      child: MaterialApp(
        title: 'Team Five 5',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(), // Definindo a HomePage como página inicial
        routes: {
          '/profile': (context) => const ProfilePage(
            username: '',
            email: '',
            phoneNumber: '',
            address: '',
            profileImage: '',
          ),
          '/login': (context) => const LoginPage(), // Adicionando rota para a LoginPage
          '/sign_up': (context) => const SignUpPage(),
        },
      ),
    );
  }
}
