import 'package:flutter/material.dart';
import 'settings.dart';
import 'user.dart';

// pages import
import 'pages/luz_page.dart';
import 'pages/tv_page.dart';
import 'pages/ac_page.dart';
import 'pages/som_page.dart';


class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0D0D0D),
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context),
                _buildDevicesGrid(context),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.13,
      color: const Color(0xFF2A2A2A),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        'Dispositivos',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: MediaQuery.of(context).size.width * 0.075,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDevicesGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              _buildResponsiveDeviceRow(
                "Luz", Icons.lightbulb, () => _navigateTo(context, LuzPage()),
                "TV", Icons.tv, () => _navigateTo(context, TvPage()),
              ),
              SizedBox(height: screenHeight * 0.03),
              _buildResponsiveDeviceRow(
                "AC", Icons.ac_unit, () => _navigateTo(context, AcPage()),
                "Som", Icons.speaker, () => _navigateTo(context, SomPage()),
              ),
              SizedBox(height: screenHeight * 0.03),
              _buildAddButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveDeviceRow(
    String name1, IconData icon1, VoidCallback onTap1,
    String name2, IconData icon2, VoidCallback onTap2,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSize = screenWidth * 0.4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDeviceItem(name1, icon1, itemSize, onTap1),
        _buildDeviceItem(name2, icon2, itemSize, onTap2),
      ],
    );
  }

  Widget _buildDeviceItem(String name, IconData icon, double size, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF777777),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                icon,
                size: size * 0.4,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: size * 0.05),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: size * 0.12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.2;

    return Column(
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: const Color(0xFF777777),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: buttonSize * 0.5,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: buttonSize * 0.05),
        Text(
          "Adicionar",
          style: TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: buttonSize * 0.12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenHeight * 0.03;

    return Container(
      height: screenHeight * 0.1,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.home, size: iconSize),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: Icon(Icons.devices, size: iconSize),
            color: const Color(0xFF1E90FF),
            onPressed: () {},
          ),
          _buildCentralMicButton(context),
          IconButton(
            icon: Icon(Icons.settings, size: iconSize),
            color: Colors.black,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfiguracoesScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person, size: iconSize),
            color: Colors.black,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          )
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
        icon: Icon(Icons.mic, size: buttonSize * 0.4),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }
}
