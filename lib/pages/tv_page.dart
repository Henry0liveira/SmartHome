import 'package:flutter/material.dart';

class TvPage extends StatelessWidget {
  const TvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TV')),
      body: const Center(child: Text('Controle de TV')),
    );
  }
}
