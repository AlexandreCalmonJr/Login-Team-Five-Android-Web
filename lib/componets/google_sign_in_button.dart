// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_login/blocs/auth/auth_bloc.dart';
// import 'package:firebase_login/blocs/auth/auth_event.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleSignInButton extends StatelessWidget {
//   const GoogleSignInButton({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final authBloc = context.read<AuthBloc>(); // Obtém o AuthBloc do contexto

//     return OutlinedButton(
//       onPressed: () async {
//         final GoogleSignIn _googleSignIn = GoogleSignIn(
//           clientId: 'SEU_ID_DE_CLIENTE_AQUI', // Substitua pelo seu ID de cliente
//           scopes: [
//             'email',
//             'profile',
//             'openid',
//             'https://www.googleapis.com/auth/userinfo.profile',
//             'https://www.googleapis.com/auth/userinfo.email',
//           ],
//         );

//         try {
//           // Verificar se já existe uma sessão ativa do Google Sign-In
//           final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
//           if (googleUser != null) {
//             // Usuário já está autenticado, emitir evento para processamento adicional se necessário
//             authBloc.add(SignUpWithGoogle());
//           } else {
//             // Renderizar o botão de login do Google caso não haja sessão ativa
//             await _googleSignIn.renderButton(
//               onSuccess: (GoogleSignInAccount googleUser) async {
//                 // Autenticar usuário com o Firebase usando o GoogleSignInAccount
//                 // Aqui você pode adicionar lógica para autenticar o usuário no Firebase
//                 print('Usuário autenticado com sucesso: ${googleUser.displayName}');
//                 authBloc.add(SignUpWithGoogle());
//               },
//               onFailure: (error) {
//                 // Tratar falhas de login aqui
//                 print('Erro ao autenticar com Google: $error');
//               },
//               clientId: 'SEU_ID_DE_CLIENTE_AQUI', // Substitua pelo seu ID de cliente
//             );
//           }
//         } catch (e) {
//           // Tratar erros gerais aqui
//           print('Erro ao autenticar com Google: $e');
//         }
//       },
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: const <Widget>[
//           Image.asset(
//             'assets/google_logo.png', // Caminho para o ícone do Google
//             height: 24.0,
//           ),
//           SizedBox(width: 12),
//           Text('Sign in with Google', style: TextStyle(color: Colors.black)),
//         ],
//       ),
//     );
//   }
// }
