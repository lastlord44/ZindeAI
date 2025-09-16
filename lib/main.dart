// main.dart - ZindeAI Flutter App Entry Point
// TODO: Firebase initialization ve app routing

import 'package:flutter/material.dart';

void main() {
  runApp(const ZindeAIApp());
}

class ZindeAIApp extends StatelessWidget {
  const ZindeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZindeAI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZindeAI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Türk mutfağına özel akıllı beslenme planlama sistemi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Text(
              'TODO: Firebase konfigürasyonu ve ekranları eklenecek',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Kamera ekranına geçiş
        },
        tooltip: 'Fotoğraf Çek',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}