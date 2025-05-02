import 'package:flutter/material.dart';

class SomPage extends StatelessWidget {
  const SomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Som')),
      body: const Center(child: Text('Controle de Som')),
    );
  }
}
