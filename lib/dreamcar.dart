import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DreamCar extends StatefulWidget {
  const DreamCar({super.key});

  @override
  State<DreamCar> createState() => _DreamCarState();
}

class _DreamCarState extends State<DreamCar> {
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentSavingsController =
      TextEditingController();
  final TextEditingController _yearsToGoalController = TextEditingController();

  double targetAmount = 0;
  double currentSavings = 0;
  int yearsToGoal = 0;
  bool showDownPaymentFields = false;
  bool showEMIFields = false; // To track which section to show
  bool isEMISelected = false; // Track whether EMI is selected

  double calculateMonthlySavings() {
    double remainingAmount = targetAmount - currentSavings;
    return remainingAmount > 0 ? remainingAmount / (yearsToGoal * 12) : 0;
  }

  double calculateProgress() {
    return targetAmount > 0 ? (currentSavings / targetAmount) * 100 : 0;
  }

  void addSavingsToFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('dream_car').add({
        'targetAmount': targetAmount,
        'currentSavings': currentSavings,
        'yearsToGoal': yearsToGoal,
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

  void showEMICalculatorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        double principal = targetAmount -
            currentSavings; // Adjusted to reflect current savings
        double tenure = 12.0;

        // EMI calculation without interest rate
        double calculateEMI(double P, double N) {
          return P / N; // Simple division for EMI calculation
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              double emi = calculateEMI(principal, tenure);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'EMI Calculator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('Principal: ₹${principal.toStringAsFixed(0)}'),
                  Slider(
                    value: principal,
                    min: 50000,
                    max: 2000000,
                    divisions: 39,
                    label: principal.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() => principal = value);
                    },
                  ),
                  // Removed interest rate calculation
                  Text('Duration: ${tenure.toStringAsFixed(0)} months'),
                  Slider(
                    value: tenure,
                    min: 6,
                    max: 120,
                    divisions: 20,
                    label: tenure.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() => tenure = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'EMI: ₹${emi.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              TextField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (₹)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    targetAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'How do you want to buy the car?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEMISelected = false; // Switch to Ready Cash
                        showDownPaymentFields = true;
                        showEMIFields = false;
                      });
                    },
                    child: const Text('Ready Cash'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEMISelected = true; // Switch to EMI
                        showEMIFields = true;
                        showDownPaymentFields = false;
                      });
                    },
                    child: const Text('EMI'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Display the Ready Cash fields when selected
              if (!isEMISelected && showDownPaymentFields) ...[
                TextField(
                  controller: _currentSavingsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Savings (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _yearsToGoalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Years to Goal',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentSavings =
                          double.tryParse(_currentSavingsController.text) ?? 0;
                      yearsToGoal =
                          int.tryParse(_yearsToGoalController.text) ?? 0;
                    });
                    addSavingsToFirebase();
                  },
                  child: const Text('Save Plan'),
                ),
                const SizedBox(height: 20),
                if (targetAmount > 0 && yearsToGoal > 0)
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
              // Display the EMI fields when selected
              if (isEMISelected && showEMIFields) ...[
                TextField(
                  controller: _currentSavingsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Savings (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentSavings =
                          double.tryParse(_currentSavingsController.text) ?? 0;
                    });
                    showEMICalculatorBottomSheet();
                  },
                  child: const Text('Enter'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
