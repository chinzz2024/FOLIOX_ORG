import 'package:flutter/material.dart';

class Marriage extends StatefulWidget {
  const Marriage({super.key});

  @override
  State<Marriage> createState() => _MarriageState();
}

class _MarriageState extends State<Marriage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marriage', style: TextStyle(color: Colors.white)),
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
