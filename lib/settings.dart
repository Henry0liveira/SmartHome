import 'package:flutter/material.dart';
import 'home.dart';
import 'devices.dart';
import 'user.dart';
import './pages/dashboard_page.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  _ConfiguracoesScreenState createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool modoEscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(
        children: [
          // Cabeçalho
          Container(
            width: double.infinity,
            height: 93,
            color: const Color(0xFF2A2A2A),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12),
            child: const Text(
              'Configurações',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ListView(
                children: [
                  const SizedBox(height: 82),

                  // Relatório de Rendimento
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    ),
                    child: Container(
                      height: 81,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Relatório de Rendimento',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          Icon(Icons.article, size: 46, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Sobre
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SobreScreen(),
                      ),
                    ),
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sobre',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 38,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 21),

                  // Suporte
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SuporteScreen(),
                      ),
                    ),
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suporte',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 38,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de navegação inferior
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            iconSize: 28,
            color: Colors.black,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResponsiveHomeScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.devices),
            iconSize: 28,
            color: Colors.black,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DevicesScreen(),
              ),
            ),
          ),
          _buildCentralMicButton(),
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 28,
            color: const Color(0xFF1E90FF), // Tela ativa
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            iconSize: 28,
            color: Colors.black,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralMicButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF1E90FF),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.mic, size: 30),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }
}

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Sobre', style: TextStyle(color: Colors.white)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'SmartHome é um aplicativo moderno que permite controlar e monitorar seus dispositivos domésticos de forma simples e intuitiva.',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class SuporteScreen extends StatelessWidget {
  const SuporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Suporte', style: TextStyle(color: Colors.white)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Entre em contato: suporte@smarthome.com',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
