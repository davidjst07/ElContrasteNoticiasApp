import 'package:flutter/material.dart';

class ScreenRadio extends StatelessWidget {
  const ScreenRadio ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio'),
      ),
      body: const Center(
        child: Text('Radio'),
      ),
    );
  }
}