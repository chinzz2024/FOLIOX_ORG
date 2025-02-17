import 'package:flutter/material.dart';

class DreamCar extends StatefulWidget {
  const DreamCar({super.key});

  @override
  State<DreamCar> createState() => _DreamCarState();
}

 5class _DreamcarState extend+c s State<Dreamcar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Car', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
    );
  }
}
