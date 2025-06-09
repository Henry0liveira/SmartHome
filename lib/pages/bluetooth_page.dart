import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  bool isBluetoothEnabled = false;
  bool isScanning = false;
  BluetoothConnection? connection;
  List<BluetoothDiscoveryResult> discoveredDevices = [];
  List<BluetoothDevice> pairedDevices = [];

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    // Verifica se o Bluetooth está habilitado
    isBluetoothEnabled = await bluetooth.isEnabled ?? false;
    
    if (isBluetoothEnabled) {
      // Carrega dispositivos pareados
      await _loadPairedDevices();
    }
    
    setState(() {});
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissões de Bluetooth são necessárias'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enableBluetooth() async {
    await _requestPermissions();
    
    if (!isBluetoothEnabled) {
      await bluetooth.requestEnable();
      isBluetoothEnabled = await bluetooth.isEnabled ?? false;
      
      if (isBluetoothEnabled) {
        await _loadPairedDevices();
      }
      setState(() {});
    }
  }

  Future<void> _loadPairedDevices() async {
    try {
      pairedDevices = await bluetooth.getBondedDevices();
      setState(() {});
    } catch (e) {
      print('Erro ao carregar dispositivos pareados: $e');
    }
  }

  Future<void> _startDiscovery() async {
    if (!isBluetoothEnabled) {
      await _enableBluetooth();
      return;
    }

    await _requestPermissions();

    setState(() {
      isScanning = true;
      discoveredDevices.clear();
    });

    try {
      bluetooth.startDiscovery().listen((result) {
        setState(() {
          // Evita duplicatas
          if (!discoveredDevices.any((d) => d.device.address == result.device.address)) {
            discoveredDevices.add(result);
          }
        });
      }).onDone(() {
        setState(() {
          isScanning = false;
        });
      });
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao escanear: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      if (connection != null) {
        await connection!.close();
      }

      connection = await BluetoothConnection.toAddress(device.address);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conectado a ${device.name ?? 'Dispositivo'}'),
          backgroundColor: Colors.green,
        ),
      );

      // Retorna para a tela anterior após conexão
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    if (connection != null) {
      await connection!.close();
      connection = null;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desconectado'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (connection != null) {
      connection!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Dispositivos Bluetooth',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isScanning ? Icons.bluetooth_searching : Icons.refresh,
              color: Colors.white,
            ),
            onPressed: isScanning ? null : _startDiscovery,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status do Bluetooth
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bluetooth,
                  color: isBluetoothEnabled ? Colors.blue : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBluetoothEnabled
                            ? (isScanning ? 'Procurando dispositivos...' : 'Bluetooth Ativo')
                            : 'Bluetooth Desabilitado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (connection != null)
                        const Text(
                          'Dispositivo Conectado',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isBluetoothEnabled)
                  ElevatedButton(
                    onPressed: _enableBluetooth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Ativar', style: TextStyle(color: Colors.white)),
                  ),
                if (isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
              ],
            ),
          ),

          // Dispositivos Pareados
          if (pairedDevices.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dispositivos Pareados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...pairedDevices.map((device) => _buildDeviceCard(device, true)),
          ],

          // Dispositivos Descobertos
          if (discoveredDevices.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dispositivos Encontrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: discoveredDevices.length,
                itemBuilder: (context, index) {
                  final result = discoveredDevices[index];
                  return _buildDeviceCard(result.device, false, result.rssi);
                },
              ),
            ),
          ],

          // Botão para escanear
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isScanning || !isBluetoothEnabled ? null : _startDiscovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isScanning) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else
                    const Icon(Icons.search, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isScanning ? 'Escaneando...' : 'Escanear Dispositivos',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device, bool isPaired, [int? rssi]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPaired ? Colors.green : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPaired ? Icons.bluetooth_connected : Icons.bluetooth,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          device.name ?? 'Dispositivo Desconhecido',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.address,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (rssi != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    color: _getSignalColor(rssi),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$rssi dBm',
                    style: TextStyle(
                      color: _getSignalColor(rssi),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _connectToDevice(device),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Conectar', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -50) return Colors.green;
    if (rssi > -70) return Colors.orange;
    return Colors.red;
  }
}