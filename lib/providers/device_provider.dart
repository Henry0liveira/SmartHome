// lib/providers/device_provider.dart
import 'package:flutter/material.dart';
import '../models/device.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceProvider with ChangeNotifier {
  List<Device> _devices = [];
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  User? _currentUser;

  DeviceProvider() {
    _initUserListener();
  }

  List<Device> get devices => _devices;

  DatabaseReference get db => _databaseRef;

  void _initUserListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      _devices = [];
      if (_currentUser != null) {
        _listenToDevices();
      }
      notifyListeners();
    });
  }

  void _listenToDevices() {
    _databaseRef.child('users/${_currentUser!.uid}/devices').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        _devices = [];
        data.forEach((key, value) {
          try {
            final deviceMap = Map<String, dynamic>.from(value);
            deviceMap['id'] = key; // garante que o ID seja atribuído
            _devices.add(Device.fromJson(deviceMap));
          } catch (e) {
            print('Erro ao processar o dispositivo $key: $e');
          }
        });
        notifyListeners();
      } else {
        _devices = [];
        notifyListeners();
      }
    });
  }

  Future<void> addDevice(Device device) async {
    if (_currentUser == null) return;
    final newDeviceRef = _databaseRef.child('users/${_currentUser!.uid}/devices').push();
    device.id = newDeviceRef.key!;
    await newDeviceRef.set(device.toJson());
  }

  // Método para ligar/desligar o dispositivo (toggle)
  Future<void> toggleDeviceState(String deviceId) async {
    if (_currentUser == null) return;

    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return;

    final currentDevice = _devices[index];
    final newState = !currentDevice.isOn;
    
    // Obtenha o timestamp atual em milissegundos desde a época
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    try {
      if (newState) { // Dispositivo está sendo LIGADO
        // Define o lastOnTimestamp no banco de dados
        await _databaseRef
            .child('users/${_currentUser!.uid}/devices/$deviceId/lastOnTimestamp')
            .set(currentTimestamp);
        // Atualiza localmente o lastOnTimestamp
        currentDevice.lastOnTimestamp = currentTimestamp;
      } else { // Dispositivo está sendo DESLIGADO
        if (currentDevice.lastOnTimestamp != null) {
          // Calcula o tempo de uso desde o último "ligar"
          final duration = currentTimestamp - currentDevice.lastOnTimestamp!;
          // Atualiza o totalUsage no banco de dados
          await _databaseRef
              .child('users/${_currentUser!.uid}/devices/$deviceId/totalUsage')
              .set(currentDevice.totalUsage + (duration ~/ 1000)); // Armazenar em segundos
          // Remove o lastOnTimestamp do banco de dados (opcional, pode manter se quiser histórico)
          await _databaseRef
              .child('users/${_currentUser!.uid}/devices/$deviceId/lastOnTimestamp')
              .remove();
          // Atualiza localmente o totalUsage
          currentDevice.totalUsage += (duration ~/ 1000);
          currentDevice.lastOnTimestamp = null; // Limpa o timestamp de início
        }
      }

      // Atualiza o estado `isOn` no Firebase Realtime Database
      await _databaseRef
          .child('users/${_currentUser!.uid}/devices/$deviceId/isOn')
          .set(newState);

      // Atualiza localmente o estado `isOn` e notifica os listeners
      currentDevice.isOn = newState;
      notifyListeners();
    } catch (e) {
      print('Erro ao alternar estado do dispositivo: $e');
    }
  }
}