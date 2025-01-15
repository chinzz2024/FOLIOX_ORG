import 'package:flutter/material.dart';

class DreamHome extends StatefulWidget {
  const DreamHome({super.key});

  @override
  State<DreamHome> createState() => _DreamHomeState();
}

class _DreamHomeState extends State<DreamHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Home', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
    );
  }
}
