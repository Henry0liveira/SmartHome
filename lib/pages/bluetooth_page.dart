import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  bool isBluetoothEnabled = false;
  bool isScanning = false;
  BluetoothDevice? connectedDevice;
  List<ScanResult> scanResults = [];
  List<BluetoothDevice> connectedDevices = [];

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    // Verifica o estado do Bluetooth
    await _checkBluetoothState();
    
    // Carrega dispositivos já conectados
    await _loadConnectedDevices();
    
    // Escuta mudanças no estado do Bluetooth
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      setState(() {
        isBluetoothEnabled = state == BluetoothAdapterState.on;
      });
    });
  }

  Future<void> _checkBluetoothState() async {
    final state = await FlutterBluePlus.adapterState.first;
    setState(() {
      isBluetoothEnabled = state == BluetoothAdapterState.on;
    });
  }

  Future<void> _loadConnectedDevices() async {
    try {
      connectedDevices = await FlutterBluePlus.connectedDevices;
      setState(() {});
    } catch (e) {
      print('Erro ao carregar dispositivos conectados: $e');
    }
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
    try {
      await FlutterBluePlus.turnOn();
      await _checkBluetoothState();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ativar Bluetooth: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startScan() async {
    if (!isBluetoothEnabled) {
      await _enableBluetooth();
      return;
    }

    await _requestPermissions();

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    try {
      // Para o scan se já estiver rodando
      await FlutterBluePlus.stopScan();
      
      // Escuta os resultados do scan
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          scanResults = results;
        });
      });

      // Inicia o scan por 10 segundos
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      setState(() {
        isScanning = false;
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
      // Mostra indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await device.connect(timeout: const Duration(seconds: 10));
      
      setState(() {
        connectedDevice = device;
      });

      // Fecha o indicador de carregamento
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conectado a ${device.platformName.isNotEmpty ? device.platformName : 'Dispositivo'}'),
          backgroundColor: Colors.green,
        ),
      );

      // Retorna para a tela anterior após 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });

    } catch (e) {
      // Fecha o indicador de carregamento
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      
      setState(() {
        if (connectedDevice == device) {
          connectedDevice = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Desconectado de ${device.platformName.isNotEmpty ? device.platformName : 'Dispositivo'}'),
          backgroundColor: Colors.orange,
        ),
      );

      await _loadConnectedDevices();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao desconectar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
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
            onPressed: isScanning ? null : _startScan,
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
                      if (connectedDevice != null)
                        Text(
                          'Conectado: ${connectedDevice!.platformName.isNotEmpty ? connectedDevice!.platformName : 'Dispositivo'}',
                          style: const TextStyle(
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

          // Dispositivos Conectados
          if (connectedDevices.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dispositivos Conectados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...connectedDevices.map((device) => _buildDeviceCard(device, true)),
          ],

          // Dispositivos Encontrados
          if (scanResults.isNotEmpty) ...[
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
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final result = scanResults[index];
                  return _buildDeviceCard(result.device, false, result.rssi);
                },
              ),
            ),
          ] else if (!isScanning && isBluetoothEnabled) ...[
            const Expanded(
              child: Center(
                child: Text(
                  'Nenhum dispositivo encontrado\nToque em "Escanear" para procurar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],

          // Botão para escanear
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isScanning || !isBluetoothEnabled ? null : _startScan,
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

  Widget _buildDeviceCard(BluetoothDevice device, bool isConnected, [int? rssi]) {
    final deviceName = device.platformName.isNotEmpty 
        ? device.platformName 
        : 'Dispositivo Desconhecido';

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isConnected 
            ? const Color(0xFF1B4332) 
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: isConnected 
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          deviceName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.remoteId.toString(),
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
          onPressed: () => isConnected 
              ? _disconnectDevice(device) 
              : _connectToDevice(device),
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            isConnected ? 'Desconectar' : 'Conectar',
            style: const TextStyle(fontSize: 12),
          ),
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