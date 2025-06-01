import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'devices.dart';
import 'settings.dart';
import 'user.dart';
import 'models/device.dart';
import 'providers/device_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
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
      debugPrint("Erro ao obter localização: $e");
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
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
      debugPrint("Erro na requisição: $e");
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
                Expanded(
                  child: Consumer<DeviceProvider>(
                    builder: (context, deviceProvider, child) {
                      if (deviceProvider.devices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Nenhum dispositivo adicionado.',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              SizedBox(height: 20),
                              _buildPlusButton(),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: deviceProvider.devices.length + 1,
                        itemBuilder: (context, index) {
                          if (index < deviceProvider.devices.length) {
                            final device = deviceProvider.devices[index];
                            return _buildDeviceCard(device, deviceProvider);
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Center(child: _buildPlusButton()),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
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

  Widget _buildDeviceCard(Device device, DeviceProvider deviceProvider) {
  // Função auxiliar para formatar o tempo de uso
  String formatUsageTime(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds s';
    } else if (totalSeconds < 3600) {
      int minutes = totalSeconds ~/ 60;
      int remainingSeconds = totalSeconds % 60;
      return '$minutes min ${remainingSeconds > 0 ? '$remainingSeconds s' : ''}';
    } else {
      int hours = totalSeconds ~/ 3600;
      int remainingMinutes = (totalSeconds % 3600) ~/ 60;
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF777777),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(device.icon, size: 40, color: Colors.white),
        SizedBox(width: 15),
        Expanded(
          child: Column( // Alterado para Column para exibir nome e uso
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4), // Pequeno espaço entre nome e uso
              Text(
                'Uso total: ${formatUsageTime(device.totalUsage)}', // Exibe o tempo de uso
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: device.isOn,
          onChanged: (_) {
            deviceProvider.toggleDeviceState(device.id);
          },
          activeThumbColor: Colors.white,
          activeTrackColor: Color(0xFF1E90FF),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade600,
        ),
      ],
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
    final user = FirebaseAuth.instance.currentUser;
    final nomeUsuario = user?.displayName ?? "Usuário sem nome";
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        children: [
          Text(
            'Bem Vindo, $nomeUsuario !',
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DevicesScreen()),
        );
      },
      child: Container(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevicesScreen()),
              );
            },
          ),
          _buildCentralMicButton(),
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
