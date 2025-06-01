import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, int> deviceUsageData =
      {}; // Tempo de uso em segundos (para o gráfico de pizza)
  List<double> consumoMensal =
      []; // Dados antigos/exemplo para o BarChart Kva (não será preenchido aqui)

  // Novo Map para armazenar o gasto em Watts-hora por dispositivo
  Map<String, double> devicePowerConsumption = {};

  int totalUsageSum = 0; // Soma total do tempo de uso para o gráfico de pizza

  late DatabaseReference _devicesRef;
  late Stream<DatabaseEvent> _deviceDataStream;

  // Mapa de gastos médios em Watts por tipo de dispositivo.
  // Ajuste esses valores conforme o consumo real dos seus dispositivos.
  // Use nomes em minúsculas para facilitar a comparação na inferência do tipo.
  final Map<String, double> _averageWattsPerDeviceType = {
    'lâmpada': 60.0, // Ex: Lâmpada incandescente. Para LED, seria 10-20W.
    'tv': 100.0,
    'ar-condicionado': 1500.0,
    'som': 80.0,
    'geladeira': 150.0,
    'computador': 300.0,
    'xbox': 150.0, // Exemplo com base na imagem anterior
    'camera': 10.0, // Exemplo com base na imagem anterior (Cam)
    // Adicione mais tipos e seus gastos médios aqui.
  };

  // Map para manter a consistência dos índices dos dispositivos no BarChart (eixo X)
  final Map<String, int> _deviceToIndexMap = {};
  int _nextDeviceIndex = 0; // Próximo índice disponível

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
        devicePowerConsumption = {}; // Limpa dados de Watts também
        _deviceToIndexMap.clear(); // Limpa o mapa de índices
        _nextDeviceIndex = 0;
      });
      return;
    }

    _devicesRef = FirebaseDatabase.instance.ref('users/${user.uid}/devices');
    debugPrint('Escutando o caminho do Firebase: ${_devicesRef.path}');

    _deviceDataStream = _devicesRef.onValue;

    _deviceDataStream.listen(
      (event) {
        final snapshot = event.snapshot;
        debugPrint('Dados do Snapshot recebidos: ${snapshot.value}');

        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);

          Map<String, int> newDeviceUsageData = {};
          int newTotalUsageSum = 0;
          Map<String, double> newDevicePowerConsumption = {};
          // Limpar o mapa de índices a cada nova leitura para reatribuir corretamente
          _deviceToIndexMap.clear();
          _nextDeviceIndex = 0;

          data.forEach((key, value) {
            try {
              final deviceMap = Map<String, dynamic>.from(value);
              final deviceName = deviceMap['name'] as String;
              final usageSeconds =
                  (deviceMap['totalUsage'] as num?)?.toInt() ?? 0;

              newDeviceUsageData[deviceName] = usageSeconds;
              newTotalUsageSum += usageSeconds;
              debugPrint(
                'Dispositivo: $deviceName, Uso: $usageSeconds segundos',
              );

              // --- Cálculo do gasto em Watts-hora (Wh) ---
              double averageWatts = _getAverageWattsForDevice(deviceName);
              double usageHours =
                  usageSeconds / 3600.0; // Converter segundos para horas
              double totalWatts =
                  usageHours * averageWatts; // Gasto em Watts-hora (Wh)
              newDevicePowerConsumption[deviceName] = totalWatts;
              debugPrint(
                'Dispositivo: $deviceName, Gasto em Watts: ${totalWatts.toStringAsFixed(2)} Wh (Média: $averageWatts W)',
              );
            } catch (e) {
              debugPrint(
                'Erro ao processar o dispositivo $key no dashboard: $e',
              );
              // Se houver um erro, defina o uso e consumo para zero para evitar falhas
              newDeviceUsageData[key] = 0;
              newDevicePowerConsumption[key] = 0.0;
            }
          });

          setState(() {
            deviceUsageData = newDeviceUsageData;
            totalUsageSum = newTotalUsageSum;
            consumoMensal =
                []; // Manter vazio, a menos que você preencha em outro lugar
            devicePowerConsumption =
                newDevicePowerConsumption; // Atualiza os dados de gasto
          });
          debugPrint('Estado do dashboard atualizado.');
          debugPrint('TotalUsageSum (pizza): $totalUsageSum');
          debugPrint(
            'Dados de consumo em Watts (barras): $devicePowerConsumption',
          );
        } else {
          debugPrint('Nenhum snapshot de dados encontrado para o usuário.');
          setState(() {
            deviceUsageData = {};
            totalUsageSum = 0;
            consumoMensal = [];
            devicePowerConsumption = {};
            _deviceToIndexMap.clear();
            _nextDeviceIndex = 0;
          });
        }
      },
      onError: (error) {
        debugPrint('Erro no stream do Firebase: $error');
        setState(() {
          deviceUsageData = {};
          totalUsageSum = 0;
          consumoMensal = [];
          devicePowerConsumption = {};
          _deviceToIndexMap.clear();
          _nextDeviceIndex = 0;
        });
      },
    );
  }

  // Função para inferir o gasto médio com base no nome do dispositivo.
  double _getAverageWattsForDevice(String deviceName) {
    String lowerCaseName = deviceName.toLowerCase();
    if (lowerCaseName.contains('lâmpada') ||
        lowerCaseName.contains('lampada') ||
        lowerCaseName.contains('luz')) {
      return _averageWattsPerDeviceType['lâmpada'] ?? 60.0;
    } else if (lowerCaseName.contains('tv') ||
        lowerCaseName.contains('televisão')) {
      return _averageWattsPerDeviceType['tv'] ?? 100.0;
    } else if (lowerCaseName.contains('ar') ||
        lowerCaseName.contains('ar-condicionado')) {
      return _averageWattsPerDeviceType['ar-condicionado'] ?? 1500.0;
    } else if (lowerCaseName.contains('som') ||
        lowerCaseName.contains('caixa') ||
        lowerCaseName.contains('radio')) {
      return _averageWattsPerDeviceType['som'] ?? 80.0;
    } else if (lowerCaseName.contains('geladeira') ||
        lowerCaseName.contains('refrigerador')) {
      return _averageWattsPerDeviceType['geladeira'] ??
          150.0; // Adicionado valor padrão
    } else if (lowerCaseName.contains('computador') ||
        lowerCaseName.contains('pc') ||
        lowerCaseName.contains('notebook')) {
      return _averageWattsPerDeviceType['computador'] ??
          300.0; // Adicionado valor padrão
    } else if (lowerCaseName.contains('xbox') ||
        lowerCaseName.contains('console')) {
      return _averageWattsPerDeviceType['xbox'] ?? 150.0;
    } else if (lowerCaseName.contains('cam') ||
        lowerCaseName.contains('câmera') ||
        lowerCaseName.contains('camera')) {
      return _averageWattsPerDeviceType['camera'] ?? 10.0;
    }
    debugPrint(
      'Aviso: Tipo de dispositivo para "$deviceName" não reconhecido. Usando valor padrão de 50W.',
    );
    return 50.0;
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

              // GRÁFICO DE PIZZA
              totalUsageSum == 0 || deviceUsageData.isEmpty
                  ? const Text(
                    'Nenhum dado disponível para o gráfico de pizza',
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
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            PieTouchResponse? pieTouchResponse,
                          ) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                return;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              if (totalUsageSum > 0 && deviceUsageData.isNotEmpty)
                _buildLegend(),

              // SEÇÃO DO NOVO GRÁFICO DE GASTOS EM WATTS
              const SizedBox(height: 40),
              const Text(
                'Gasto Estimado por Dispositivo (Wh)',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),

              devicePowerConsumption.isEmpty ||
                      devicePowerConsumption.values.every((value) => value == 0)
                  ? const Text(
                    'Nenhum dado de gasto disponível para o gráfico de barras',
                    style: TextStyle(color: Colors.white54),
                  )
                  : SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            devicePowerConsumption.values.reduce(
                              (a, b) => a > b ? a : b,
                            ) *
                            1.2, // 20% a mais do maior valor
                        minY: 0,
                        barGroups:
                            devicePowerConsumption.entries.map((entry) {
                              return BarChartGroupData(
                                x: _getDeviceIndex(entry.key),
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value,
                                    color: _getColorForDevice(
                                      entry.key,
                                      Colors.deepOrange,
                                    ),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                                // Esta linha foi REMOVIDA para ocultar os tooltips
                                // showingTooltipIndicators: [0],
                              );
                            }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget:
                                  (value, meta) =>
                                      _getBottomTitles(value, meta),
                              reservedSize: 42,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget:
                                  (value, meta) => _getLeftTitles(value, meta),
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Colors.white12,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: false, // Border around the chart
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (spot) => Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (groupIndex <
                                  devicePowerConsumption.keys.length) {
                                final deviceName = devicePowerConsumption.keys
                                    .elementAt(groupIndex);
                                return BarTooltipItem(
                                  '$deviceName\n${rod.toY.toStringAsFixed(2)} Wh',
                                  const TextStyle(color: Colors.white),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
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

  // --- Funções Auxiliares para o Gráfico de Barras ---

  int _getDeviceIndex(String deviceName) {
    // Atribui um índice único para cada nome de dispositivo
    if (!_deviceToIndexMap.containsKey(deviceName)) {
      _deviceToIndexMap[deviceName] = _nextDeviceIndex++;
    }
    return _deviceToIndexMap[deviceName]!;
  }

  // Títulos do eixo X (nomes dos dispositivos)
  Widget _getBottomTitles(double value, TitleMeta meta) {
    // Converte o valor do eixo X (índice) de volta para o nome do dispositivo
    final index = value.toInt();
    String? deviceName;
    // Percorre o mapa para encontrar o nome do dispositivo pelo índice
    _deviceToIndexMap.forEach((key, val) {
      if (val == index) {
        deviceName = key;
      }
    });

    if (deviceName != null) {
      return SideTitleWidget(
        meta: meta,
        space: 10,
        child: Text(
          deviceName!,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      );
    }

    return const SizedBox.shrink(); // Retorna um widget vazio se não encontrar
  }

  // Títulos do eixo Y (valores em Wh)
  Widget _getLeftTitles(double value, TitleMeta meta) {
    // Meta é recebido mas pode não ser usado explicitamente
    if (value == 0) {
      return const Text(
        '0 Wh',
        style: TextStyle(color: Colors.white70, fontSize: 10),
      );
    }
    return Text(
      '${value.toInt()} Wh', // Mostra valores inteiros em Wh
      style: const TextStyle(color: Colors.white70, fontSize: 10),
      textAlign: TextAlign.left,
    );
  }

  // Funções para o Gráfico de Pizza (mantidas do código anterior)

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
    ];
    int colorIndex = 0;

    return deviceUsageData.entries.map((entry) {
      final deviceName = entry.key;
      final usageSeconds = entry.value;
      final percentage = (usageSeconds / totalUsageSum) * 100;

      // Atribui uma cor com base no nome do dispositivo, se houver um padrão, ou uma cor da lista.
      final color = _getColorForDevice(
        deviceName,
        pieColors[colorIndex % pieColors.length],
      );
      colorIndex++; // Incrementa para a próxima cor da lista padrão

      return PieChartSectionData(
        title: '$deviceName\n${percentage.toStringAsFixed(1)}%',
        value: percentage,
        color: color,
        radius: 120,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
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
      children:
          deviceUsageData.entries.map((entry) {
            final deviceName = entry.key;
            final usageSeconds = entry.value;
            final percentage = (usageSeconds / totalUsageSum) * 100;
            final color = _getColorForDevice(
              deviceName,
              pieColors[colorIndex % pieColors.length],
            );
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

  // Função para obter cores consistentes para dispositivos
  Color _getColorForDevice(String deviceName, Color defaultColor) {
    String lowerCaseName = deviceName.toLowerCase();
    if (lowerCaseName.contains('lâmpada') ||
        lowerCaseName.contains('lampada') ||
        lowerCaseName.contains('luz')) {
      return Colors.orange;
    } else if (lowerCaseName.contains('tv') ||
        lowerCaseName.contains('televisão')) {
      return Colors.lightBlue;
    } else if (lowerCaseName.contains('ar') ||
        lowerCaseName.contains('ar-condicionado')) {
      return Colors.blueAccent;
    } else if (lowerCaseName.contains('som') ||
        lowerCaseName.contains('caixa') ||
        lowerCaseName.contains('radio')) {
      return Colors.green;
    } else if (lowerCaseName.contains('geladeira') ||
        lowerCaseName.contains('refrigerador')) {
      return Colors.teal;
    } else if (lowerCaseName.contains('computador') ||
        lowerCaseName.contains('pc') ||
        lowerCaseName.contains('notebook')) {
      return Colors.deepPurple;
    } else if (lowerCaseName.contains('xbox') ||
        lowerCaseName.contains('console')) {
      return Colors.purple;
    } else if (lowerCaseName.contains('cam') ||
        lowerCaseName.contains('câmera') ||
        lowerCaseName.contains('camera')) {
      return Colors.brown;
    }
    return defaultColor; // Retorna a cor padrão se nenhum padrão for encontrado
  }
}
