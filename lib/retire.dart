import 'package:flutter/material.dart';

class RetireEarly extends StatefulWidget {
  const RetireEarly({super.key});

  @override
  State<RetireEarly> createState() => _RetireEarlyState();
}

class _RetireEarlyState extends State<RetireEarly> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Early Retire', style: TextStyle(color: Colors.white)),
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
