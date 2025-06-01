// lib/models/device.dart
import 'package:flutter/material.dart';

class Device {
  String id; // Unique identifier for the device
  String name;
  IconData icon;
  bool isOn;
  // You can add more properties here if needed, e.g., deviceType, room, etc.

  Device({
    required this.id,
    required this.name,
    required this.icon,
    this.isOn = false, // Default to off
  });

  // Convert a Device object to a Map for storage (e.g., in Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint, // Store icon as its code point
      'isOn': isOn,
    };
  }

  // Create a Device object from a Map (e.g., when retrieving from Firebase)
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      isOn: json['isOn'] ?? false,
    );
  }
}