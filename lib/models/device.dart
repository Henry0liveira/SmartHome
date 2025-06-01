import 'package:flutter/material.dart';


class Device {
  String id;
  String name;
  IconData icon;
  bool isOn;
  int totalUsage; // total em segundos
  int? lastOnTimestamp; // timestamp do último "ligar"

  Device({
    required this.id,
    required this.name,
    required this.icon,
    this.isOn = false,
    this.totalUsage = 0,
    this.lastOnTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'isOn': isOn,
      'totalUsage': totalUsage,
      'lastOnTimestamp': lastOnTimestamp,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      isOn: json['isOn'] ?? false,
      totalUsage: json['totalUsage'] ?? 0,
      lastOnTimestamp: json['lastOnTimestamp'],
    );
  }
}
