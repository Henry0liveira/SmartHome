import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart'; // Importando a tela ResponsiveHomeScreen

// Arquivo firebase_config.dart - Configure com seus próprios dados
class FirebaseConfig {
  static Future<void> initializeApp() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyA94ZAj-4a-a-vKRa6qbXKkF6j0x9TPD8k",
            appId: "1:739968553729:android:8a6ddb06f731c549170100",
            messagingSenderId: "SEU_MESSAGING_SENDER_ID",
            projectId: "fodsae-76838",
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
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (user != null && mounted) {
          // Navegação explícita para a tela home depois do login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ResponsiveHomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Nenhum usuário encontrado com esse e-mail.';
        } else if (e.code == 'wrong-password') {
          message = 'Senha incorreta.';
        } else {
          message = 'Erro ao efetuar login: ${e.message}';
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.1,
                    left: screenWidth * 0.1,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Smart',
                        style: TextStyle(
                          fontSize: screenWidth * 0.1,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          letterSpacing: -0.02,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo Principal
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          'Bem vindo!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'IBM Plex Sans',
                            letterSpacing: -0.02,
                          ),
                        ),

                        // Campo de Email
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 500,
                              minHeight: screenHeight * 0.08,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu e-mail';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Por favor, insira um e-mail válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),

                        // Campo de Senha
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.02),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 500,
                              minHeight: screenHeight * 0.08,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Senha',
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),

                        // Link Esqueceu a Senha
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.02),
                          child: const Text(
                            'Esqueceu sua senha?',
                            style: TextStyle(
                              color: Color.fromARGB(255, 10, 54, 97),
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),

                        // Botão de Login
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.07,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        // Botão Criar Conta
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.02),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.07,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 4, 44, 90),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.white),
                                ),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/register'),
                              child: Text(
                                'Criar minha conta',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tela de Cadastro com o novo design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.registerWithEmailAndPassword(
          _nameController.text,
          _emailController.text.trim(),
          _passwordController.text,
        );

        Fluttertoast.showToast(
          msg: 'Cadastro realizado com sucesso!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        if (user != null && mounted) {
          // Navegação explícita para a tela home depois do cadastro
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ResponsiveHomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'A senha é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Este e-mail já está em uso.';
        } else {
          message = 'Erro ao efetuar cadastro: ${e.message}';
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Título
                Center(
                  child: Text(
                    'Smart Home',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                
                // Name Field
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    minHeight: screenHeight * 0.08,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nome completo',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                
                // Email Field
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    minHeight: screenHeight * 0.08,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'E-mail',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu e-mail';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Por favor, insira um e-mail válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                
                // Password Field
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    minHeight: screenHeight * 0.08,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Senha',
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                
                // Confirm Password Field
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    minHeight: screenHeight * 0.08,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureTextConfirm,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Confirmar senha',
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextConfirm = !_obscureTextConfirm;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'CADASTRAR',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                
                // Login Link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Já tem uma conta? Faça login',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}