import 'package:flutter/material.dart';

class EmergencyFund extends StatefulWidget {
  const EmergencyFund({super.key});

  @override
  State<EmergencyFund> createState() => _EmergencyFundState();
}

class _EmergencyFundState extends State<EmergencyFund> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency', style: TextStyle(color: Colors.white)),
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
