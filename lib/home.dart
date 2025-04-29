import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'devices.dart'; // Importando a tela de dispositivos
import 'settings.dart'; // Importando a tela de configurações
import 'user.dart';

class ResponsiveHomeScreen extends StatefulWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  State<ResponsiveHomeScreen> createState() => _ResponsiveHomeScreenState();
}

class _ResponsiveHomeScreenState extends State<ResponsiveHomeScreen> {
  bool _lightsOn = false;
  String city = "Cidade";
  String temperature = "0";
  String condition = "clima";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      // Solicitar permissão
      var status = await Permission.location.request();
      if (status.isGranted) {
        // Obter posição atual
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        // Buscar dados de clima com base na localização
        await _fetchWeatherData(position.latitude, position.longitude);
      } else {
        setState(() {
          city = "Permissão negada";
          temperature = "0";
          condition = "Ative a localização";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        city = "Erro";
        temperature = "0";
        condition = "Tente novamente";
        isLoading = false;
      });
      print("Erro ao obter localização: $e");
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    // Substitua API_KEY pela sua chave da OpenWeatherMap
    const apiKey = "b38d9f99ff95800411e4834117aee4d1";
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&lang=pt_br&appid=$apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data["name"];
          temperature = data["main"]["temp"].round().toString();
          condition = data["weather"][0]["description"];
          isLoading = false;
        });
      } else {
        setState(() {
          city = "Erro ao carregar";
          temperature = "0";
          condition = "Tente novamente";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        city = "Sem conexão";
        temperature = "0";
        condition = "Verifique sua internet";
        isLoading = false;
      });
      print("Erro na requisição: $e");
    }
  }

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
                _buildWeatherInfo(context),
                SizedBox(height: 20),
                // Add plus button in the column flow instead of positioned
                _buildPlusButton(),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      color: const Color(0xFF2A2A2A),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'SmartHome',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        children: [
          Text(
            'Bom Dia, Usuário!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: MediaQuery.of(context).size.width * 0.04,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFF726A6A),
                  ),
                )
              : Text(
                  '$city, $temperature°C, $condition',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    color: const Color(0xFF726A6A),
                  ),
                ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // Toggle button for lights
          _buildLightToggleButton(context),
        ],
      ),
    );
  }

  Widget _buildLightToggleButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _lightsOn = !_lightsOn;
        });
      },
      child: Container(
        width: 142,
        height: 42,
        decoration: BoxDecoration(
          color: _lightsOn ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E90FF)),
        ),
        child: Center(
          child: Text(
            _lightsOn ? 'Desligar todas as luzes' : 'Ligar todas as luzes',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _lightsOn ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlusButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 114, 114, 114),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          size: 50,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
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
          // Home (selecionado)
          IconButton(
            icon: Icon(Icons.home),
            iconSize: 28,
            color: const Color(0xFF1E90FF),
            onPressed: () {},
          ),
          
          IconButton(
            icon: Icon(Icons.devices),
            iconSize: 28,
            color: Colors.black,
            onPressed: () {
              print("Navegando para Tela de Dispositivos");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevicesScreen()),
              );
            },
          ),
          // Microfone central
          _buildCentralMicButton(),
          // Settings
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 28,
            color: Colors.black,
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfiguracoesScreen()),
              );
            },
          ),
          // User
          IconButton(
            icon: Icon(Icons.person),
            iconSize: 28,
            color: Colors.black,
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
             },
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