import 'package:flutter/material.dart';

class LuzPage extends StatelessWidget {
  const LuzPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Luz')),
      body: const Center(child: Text('Controle de Luz')),
    );
  }
}
