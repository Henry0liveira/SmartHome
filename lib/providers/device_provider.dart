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

  void _initUserListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      _devices = []; // Clear devices when user changes or logs out
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
            _devices.add(Device.fromJson(Map<String, dynamic>.from(value)));
          } catch (e) {
            print('Error parsing device data for $key: $e');
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
    device.id = newDeviceRef.key!; // Assign the Firebase generated key as the device ID
    await newDeviceRef.set(device.toJson());
    // The listener will automatically update _devices and notify listeners
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    if (_currentUser == null) return;
    await _databaseRef.child('users/${_currentUser!.uid}/devices/$deviceId/isOn').set(newStatus);
    // The listener will automatically update _devices and notify listeners
  }
}