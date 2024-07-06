import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/blocs/auth/auth_bloc.dart';
import 'package:firebase_login/app/configurations.dart';
import 'package:firebase_login/models/profile_viewmodel.dart';
import 'package:firebase_login/repository/auth_repository.dart';
import 'package:firebase_login/screens/home_page.dart';
import 'package:firebase_login/screens/login_page.dart';
import 'package:firebase_login/screens/profile_page.dart';
import 'package:firebase_login/screens/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_login/datasources/firebase_auth_service.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '458530444305-lvm3a868sieuemsjukkde0f5pc1qh2i7.apps.googleusercontent.com',
  );

  final authService = FirebaseAuthService(firebaseAuth, googleSignIn);
  final authRepository = AuthRepository(authService);

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Team Five 5',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          '/profile': (context) => const ProfilePage(),
          '/login': (context) => const LoginPage(),
          '/sign_up': (context) => const SignUpPage(),
        },
      ),
    );
  }
}
