import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/device_provider.dart'; // Mantenha este caminho relativo

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, int> deviceUsageData = {};
  List<double> consumoMensal = []; // Mantido para o BarChart
  int totalUsageSum = 0;

  late DatabaseReference _devicesRef;
  late Stream<DatabaseEvent> _deviceDataStream;

  @override
  void initState() {
    super.initState();
    _initDeviceUsageListener();
  }

  void _initDeviceUsageListener() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('Usuário não logado. Limpando dados do dashboard.');
      setState(() {
        deviceUsageData = {};
        totalUsageSum = 0;
        consumoMensal = [];
      });
      return;
    }

    _devicesRef = FirebaseDatabase.instance.ref('users/${user.uid}/devices');
    debugPrint('Escutando o caminho do Firebase: ${_devicesRef.path}');

    _deviceDataStream = _devicesRef.onValue;

    _deviceDataStream.listen((event) {
      final snapshot = event.snapshot;
      debugPrint('Dados do Snapshot recebidos: ${snapshot.value}');

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        Map<String, int> newDeviceUsageData = {};
        int newTotalUsageSum = 0;

        data.forEach((key, value) {
          try {
            final deviceMap = Map<String, dynamic>.from(value);
            final deviceName = deviceMap['name'] as String;
            final usage = (deviceMap['totalUsage'] as num?)?.toInt() ?? 0;

            newDeviceUsageData[deviceName] = usage;
            newTotalUsageSum += usage;
            debugPrint('Dispositivo: $deviceName, Uso: $usage segundos');
          } catch (e) {
            debugPrint('Erro ao processar o dispositivo $key no dashboard: $e');
          }
        });

        setState(() {
          deviceUsageData = newDeviceUsageData;
          totalUsageSum = newTotalUsageSum;
          consumoMensal = [];
        });
        debugPrint('Estado do dashboard atualizado. TotalUsageSum: $totalUsageSum');
      } else {
        debugPrint('Nenhum snapshot de dados encontrado para o usuário.');
        setState(() {
          deviceUsageData = {};
          totalUsageSum = 0;
          consumoMensal = [];
        });
      }
    }, onError: (error) {
      debugPrint('Erro no stream do Firebase: $error');
      setState(() {
        deviceUsageData = {};
        totalUsageSum = 0;
        consumoMensal = [];
      });
    });
  }

  // Helper para formatar segundos em um formato mais legível (hh:mm:ss)
  String _formatSeconds(int seconds) {
    if (seconds == 0) return "0s";
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
    } else if (duration.inMinutes > 0) {
      return "${twoDigitMinutes}m ${twoDigitSeconds}s";
    } else {
      return "${twoDigitSeconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        title: const Text(
          'Relatório de Rendimento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Dispositivos mais utilizados',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),

              totalUsageSum == 0 || deviceUsageData.isEmpty
                  ? const Text(
                      'Nenhum dado disponível',
                      style: TextStyle(color: Colors.white54),
                    )
                  : SizedBox(
                      height: 350,
                      width: 350,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (totalUsageSum > 0 && deviceUsageData.isNotEmpty)
                _buildLegend(),

              const SizedBox(height: 40),
              const Text(
                'Uso em Kva (Dados de Exemplo/Antigos)',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),

              consumoMensal.isEmpty
                  ? const Text(
                      'Nenhum dado disponível',
                      style: TextStyle(color: Colors.white54),
                    )
                  : SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          barGroups: consumoMensal.asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: Colors.blueAccent,
                                  width: 20,
                                ),
                              ],
                            );
                          }).toList(),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                        ),
                      ),
                    ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.arrow_back, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (totalUsageSum == 0) return [];

    List<Color> pieColors = [
      Colors.lightBlue,
      Colors.orange,
      Colors.blueAccent,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.yellow,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      // Adicione mais cores se você espera ter muitos dispositivos personalizados
    ];
    int colorIndex = 0;

    return deviceUsageData.entries.map((entry) {
      final deviceName = entry.key;
      final usageSeconds = entry.value;
      final percentage = (usageSeconds / totalUsageSum) * 100;

      // Atribui a cor da lista 'pieColors' de forma cíclica
      // O _getColorForDevice agora só retornará a cor padrão
      final color = _getColorForDevice(deviceName, pieColors[colorIndex % pieColors.length]);
      colorIndex++; // Avança para a próxima cor para o próximo dispositivo

      return PieChartSectionData(
        title: '$deviceName\n${percentage.toStringAsFixed(1)}%',
        value: percentage,
        color: color,
        radius: 120,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: _buildBadge(deviceName, percentage),
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  Widget _buildBadge(String deviceName, double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getColorForDevice(deviceName, Colors.grey).withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$deviceName: ${_formatSeconds(deviceUsageData[deviceName]!)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    List<Color> pieColors = [
      Colors.lightBlue,
      Colors.orange,
      Colors.blueAccent,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.yellow,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
    ];
    int colorIndex = 0;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: deviceUsageData.entries.map((entry) {
        final deviceName = entry.key;
        final usageSeconds = entry.value;
        final percentage = (usageSeconds / totalUsageSum) * 100;
        final color = _getColorForDevice(deviceName, pieColors[colorIndex % pieColors.length]);
        colorIndex++;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$deviceName: ${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Esta função agora simplesmente retorna a cor padrão que é passada para ela.
  // A lógica de atribuição de cores cíclica acontece em _buildPieChartSections e _buildLegend.
  Color _getColorForDevice(String deviceName, Color defaultColor) {
    // Se você ainda quiser ter cores fixas para alguns nomes específicos,
    // pode manter um switch aqui ANTES de retornar a defaultColor.
    // Exemplo:
    /*
    switch (deviceName) {
      case 'TV Sala': // Exemplo de nome personalizado fixo
        return Colors.blue;
      case 'Luz Cozinha':
        return Colors.yellow;
      default:
        return defaultColor; // Retorna a cor padrão do ciclo
    }
    */
    // Para nomes totalmente personalizados e desconhecidos, simplesmente retornamos a defaultColor.
    return defaultColor;
  }
}