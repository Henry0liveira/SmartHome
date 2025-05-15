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
  Map<String, double> dispositivos = {};
  List<double> consumoMensal = [];

  late DatabaseReference userRef;
  late Stream<DatabaseEvent> dataStream;

  @override
  void initState() {
    super.initState();
    _initDatabaseListener();
  }

  void _initDatabaseListener() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Usuário não logado, limpar dados
      setState(() {
        dispositivos = {};
        consumoMensal = [];
      });
      return;
    }

    userRef = FirebaseDatabase.instance.ref('relatorio/${user.uid}');

    // Escuta alterações em tempo real no banco para o usuário atual
    dataStream = userRef.onValue;

    dataStream.listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        // Para garantir que os tipos sejam corretos e chaves trocadas
        Map<String, double> dispositivosData = {};
        if (data['dispositivos'] != null) {
          Map<dynamic, dynamic> original = data['dispositivos'] as Map;
          original.forEach((key, value) {
            String newKey = key.toString();
            if (newKey == 'Cam') newKey = 'Luz';
            else if (newKey == 'Xbox') newKey = 'Som';

            dispositivosData[newKey] = (value as num).toDouble();
          });
        }

        List<double> consumoData = [];
        if (data['consumo_mensal'] != null) {
          consumoData = List<dynamic>.from(data['consumo_mensal'])
              .map((e) => (e as num).toDouble())
              .toList();
        }

        setState(() {
          dispositivos = dispositivosData;
          consumoMensal = consumoData;
        });
      } else {
        // Dados não existem, limpar gráficos
        setState(() {
          dispositivos = {};
          consumoMensal = [];
        });
      }
    });
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

              dispositivos.isEmpty
                  ? const Text(
                      'Nenhum dado disponível',
                      style: TextStyle(color: Colors.white54),
                    )
                  : SizedBox(
                      height: 350,
                      width: 350,
                      child: PieChart(
                        PieChartData(
                          sections: dispositivos.entries.map((e) {
                            return PieChartSectionData(
                              title: '${e.key}\n${e.value.toInt()}%',
                              value: e.value,
                              color: _getColorForDevice(e.key),
                              radius: 150,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),

              const SizedBox(height: 40),
              const Text(
                'Uso em Kva',
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

  Color _getColorForDevice(String device) {
    switch (device) {
      case 'Tv':
        return Colors.lightBlue;
      case 'Luz':
        return Colors.orange;
      case 'Ar-Condicionado':
        return Colors.blueAccent;
      case 'Som':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
