import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Dreamcar extends StatefulWidget {
  const Dreamcar({super.key});

  @override
  State<Dreamcar> createState() => _DreamcarState();
}

class _DreamcarState extends State<Dreamcar> {
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentSavingsController =
      TextEditingController();
  final TextEditingController _monthsToGoalController = TextEditingController();

  double targetAmount = 0;
  double currentSavings = 0;
  int monthsToGoal = 0;

  double calculateMonthlySavings() {
    double remainingAmount = targetAmount - currentSavings;
    return remainingAmount / monthsToGoal;
  }

  double calculateProgress() {
    return (currentSavings / targetAmount) * 100;
  }

  void addSavingsToFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('dream_car').add({
        'targetAmount': targetAmount,
        'currentSavings': currentSavings,
        'monthsToGoal': monthsToGoal,
        'monthlySavingsRequired': calculateMonthlySavings(),
        'progress': calculateProgress(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings plan added to Firebase!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add plan: $e')),
      );
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _currentSavingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Savings (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _monthsToGoalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Months to Goal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    targetAmount =
                        double.tryParse(_targetAmountController.text) ?? 0;
                    currentSavings =
                        double.tryParse(_currentSavingsController.text) ?? 0;
                    monthsToGoal =
                        int.tryParse(_monthsToGoalController.text) ?? 0;
                  });
                  addSavingsToFirebase();
                },
                child: const Text('Add Savings Plan'),
              ),
              const SizedBox(height: 20),
              if (targetAmount > 0 && monthsToGoal > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Savings Required: ₹${calculateMonthlySavings().toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Progress: ${calculateProgress().toStringAsFixed(2)}%',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
