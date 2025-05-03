import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class LuzPage extends StatefulWidget {
  const LuzPage({super.key});

  @override
  State<LuzPage> createState() => _LuzPageState();
}

class _LuzPageState extends State<LuzPage> {
  final _auth = FirebaseAuth.instance;
  final _luzRef = FirebaseDatabase.instance.ref("luz");

  late DatabaseReference _tempoUsoRef;
  bool _luzLigada = false;
  int _tempoHoje = 0;
  Timer? _timer;
  String get _hoje => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _tempoUsoRef = FirebaseDatabase.instance.ref("tempo_uso/${user.uid}");
      _setupInicial();
    } else {
      // Trate o caso onde o usuário não está logado
      // Por exemplo: redirecione ou exiba uma mensagem
      debugPrint("Usuário não está autenticado.");
    }
  }

  Future<void> _setupInicial() async {
    await _carregarTempoInicial();

    final snapshot = await _luzRef.get();
    final status = snapshot.value as bool? ?? false;

    setState(() {
      _luzLigada = status;
    });

    if (_luzLigada) {
      _iniciarTimer();
    }

    _inicializarListeners(); // Depois de checar estado inicial
  }

  Future<void> _carregarTempoInicial() async {
    final snapshot = await _tempoUsoRef.child(_hoje).get();
    final tempo = snapshot.value;
    if (tempo is int) {
      _tempoHoje = tempo;
    } else {
      _tempoHoje = 0;
    }
    setState(() {}); // Atualiza tempo na tela
  }

  void _inicializarListeners() {
    _luzRef.onValue.listen((event) {
      final status = event.snapshot.value as bool?;
      if (status == null) return;

      if (_luzLigada != status) {
        setState(() => _luzLigada = status);

        if (status) {
          _iniciarTimer();
        } else {
          _pararTimer();
        }
      }
    });
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      setState(() {
        _tempoHoje += 1;
      });
      await _tempoUsoRef.child(_hoje).set(_tempoHoje);
    });
  }

  void _pararTimer() {
    _timer?.cancel();
  }

  Future<void> _toggleLuz() async {
    final snapshot = await _luzRef.get();
    final atual = snapshot.value as bool? ?? false;
    await _luzRef.set(!atual);
  }

  String _formatarTempo(int segundos) {
    final h = (segundos ~/ 3600).toString().padLeft(2, '0');
    final m = ((segundos % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  void dispose() {
    _pararTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Controle da Luz"),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _luzLigada ? "A luz está LIGADA" : "A luz está DESLIGADA",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleLuz,
              style: ElevatedButton.styleFrom(
                backgroundColor: _luzLigada ? Colors.red : Colors.green,
              ),
              child: Text(_luzLigada ? "Desligar Luz" : "Ligar Luz"),
            ),
            const SizedBox(height: 40),
            Text(
              "Tempo de uso hoje:",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              _formatarTempo(_tempoHoje),
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
