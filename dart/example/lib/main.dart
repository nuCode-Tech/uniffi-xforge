import 'package:flutter/material.dart';
import 'package:uniffi_xforge/uniffi_xforge.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PingScreen(),
    );
  }
}

class PingScreen extends StatefulWidget {
  const PingScreen({super.key});

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  String _message = 'Loading...';

  @override
  void initState() {
    super.initState();
    _callPing();
  }

  void _callPing() {
    try {
      ensureInitialized();
      final result = ping('world');
      setState(() {
        _message = result;
      });
    } catch (error) {
      setState(() {
        _message = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UniFFI Example')),
      body: Center(child: Text(_message)),
    );
  }
}
