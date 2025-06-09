import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class AcPage extends StatefulWidget {
  const AcPage({super.key});

  @override
  State<AcPage> createState() => _AcPageState();
}

class _AcPageState extends State<AcPage> {
  bool controleIntensidade = false;
  final TextEditingController nomeAcController = TextEditingController();
  String? marcaSelecionada;

  final List<String> marcasAc = [
    'Samsung',
    'LG',
    'Philips',
    'Carrier',
    'Daikin',
    'Mitsubishi',
    'Fujitsu',
    'Panasonic',
    'Hitachi',
    'Toshiba',
    'Springer',
    'Electrolux',
    'Outro'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Device AC', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ac_icon.png',
                height: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: nomeAcController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nome do Ar-Condicionado',
                    hintStyle: TextStyle(color: Colors.white70),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: marcaSelecionada,
                    hint: const Text(
                      'Selecione a Marca',
                      style: TextStyle(color: Colors.white70),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF2A2A2A),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        marcaSelecionada = newValue;
                      });
                    },
                    items: marcasAc.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Controle de Intensidade',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Switch(
                      value: controleIntensidade,
                      onChanged: (value) {
                        setState(() {
                          controleIntensidade = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  // Ação para selecionar imagem
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/placeholder_image.png',
                      height: 60,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (nomeAcController.text.isNotEmpty && marcaSelecionada != null) {
                    final deviceName = marcaSelecionada == 'Outro' 
                        ? nomeAcController.text 
                        : '${marcaSelecionada!} - ${nomeAcController.text}';
                    
                    final newDevice = Device(
                      id: '',
                      name: deviceName,
                      icon: Icons.ac_unit,
                      isOn: false,
                    );
                    Provider.of<DeviceProvider>(context, listen: false).addDevice(newDevice);
                    Navigator.pop(context);
                  } else {
                    String message = '';
                    if (nomeAcController.text.isEmpty) {
                      message = 'Por favor, digite o nome do ar-condicionado.';
                    } else if (marcaSelecionada == null) {
                      message = 'Por favor, selecione uma marca.';
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                child: const Text(
                  'ADICIONAR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}