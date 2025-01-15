import 'package:flutter/material.dart';

class Dreamcar extends StatefulWidget {
  const Dreamcar({super.key});

  @override
  State<Dreamcar> createState() => _DreamcarState();
}

class _DreamcarState extends State<Dreamcar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Car', style: TextStyle(color: Colors.white)),
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
