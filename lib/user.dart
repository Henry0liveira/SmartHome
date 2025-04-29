import 'package:flutter/material.dart';
import 'home.dart';
import 'devices.dart';
import 'settings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              // Foto do perfil
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 77),
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://cdn-icons-png.flaticon.com/512/9187/9187532.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Nome do usuário
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: const Text(
                  '{NOME USUÁRIO}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
              ),

         
              // Botões inferiores
              _buildActionButtons(),
            ],
          ),

          // Barra de navegação inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevice(String deviceName) {
    return Container(
      width: 298,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          deviceName,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 61, vertical: 20),
      child: Column(
        children: [
          _buildButton('Alterar dados', Icons.edit, 477),
          const SizedBox(height: 20),
          _buildButton('Sair', Icons.exit_to_app, 577),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, double top) {
    return Container(
      width: 306,
      height: 81,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(icon, size: 50),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.height * 0.035;

    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.home, size: iconSize),
            color: Colors.black,
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResponsiveHomeScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.devices, size: iconSize),
            color: Colors.black,
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DevicesScreen()),
            ),
          ),
          _buildCentralMicButton(context),
          IconButton(
            icon: Icon(Icons.settings, size: iconSize),
            color: Colors.black,
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ConfiguracoesScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person, size: iconSize),
            color: const Color(0xFF1E90FF), // Ícone do usuário em azul
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCentralMicButton(BuildContext context) {
    final buttonSize = MediaQuery.of(context).size.height * 0.07;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: const BoxDecoration(
        color: Color(0xFF1E90FF),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.mic, size: buttonSize * 0.5),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }
}