import 'package:flutter/material.dart';

class AcPage extends StatelessWidget {
  const AcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ar-condicionado')),
      body: const Center(child: Text('Controle de Ar-condicionado')),
    );
  }
}
