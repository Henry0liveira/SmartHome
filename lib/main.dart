import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart'; // Importando a tela ResponsiveHomeScreen
import 'register.dart';
import 'login.dart';

// Arquivo firebase_config.dart - Configure com seus próprios dados
class FirebaseConfig {
  static Future<void> initializeApp() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyA94ZAj-4a-a-vKRa6qbXKkF6j0x9TPD8k",
            appId: "1:739968553729:android:8a6ddb06f731c549170100",
            messagingSenderId: "739968553729",
            projectId: "fodsae-76838",
            databaseURL: "https://fodsae-76838-default-rtdb.firebaseio.com",
          ),
        );
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}

// Arquivo auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fazer login com email e senha
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Registrar novo usuário
  Future<User?> registerWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Atualizar nome do usuário
      await result.user?.updateDisplayName(name);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
 
  // Sair
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verificar estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

// Arquivo main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1E90FF),
          secondary: Color(0xFF1E90FF),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const ResponsiveHomeScreen(),
      },
    );
  }
}

// Verifica se usuário está logado e redireciona para tela adequada
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return ResponsiveHomeScreen(); // Redirecionamento para a nova tela
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1E90FF),
            ),
          ),
        );
      },
    );
  }
}

// Tela de Login com o novo design


