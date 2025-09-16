// home_screen.dart - Timeline ekranı
// TODO: Günlük liste, toplam kalori

import 'package:flutter/material.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Timeline'),
      ),
      body: const Center(
        child: Text(
          'TODO: Günlük meal listesi ve toplam kalori gösterimi',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}