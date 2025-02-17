import 'package:flutter/material.dart';
import 'dart:math';

class DreamCar extends StatefulWidget {
  const DreamCar({Key? key}) : super(key: key);

  @override
  State<DreamCar> createState() => _DreamCarState();
}

class _DreamcarState extends State<Dreamcar> {
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
                    loanAmount = targetAmount; // Sync loan amount with target amount
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
                      });
                    },
                    child: const Text('Ready Cash'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEMISelected = true; // Switch to EMI
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
              // Display EMI fields when EMI is selected
              if (isEMISelected) ...[
                const SizedBox(height: 20),
                const Text(
                  'Loan Amount (₹)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: loanAmount,
                  min: 50000,
                  max: 1000000, // max slider value based on targetAmount
                  divisions: 19,
                  label: '₹${loanAmount.toStringAsFixed(0)}',
                  onChanged: (double value) {
                    setState(() {
                      loanAmount = value;
                    });
                    calculateEMI(); // Recalculate EMI
                  },
                ),
                Text('₹${loanAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 20),
                const Text(
                  'Interest Rate (%)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: interestRate,
                  min: 0,
                  max: 20,
                  divisions: 40,
                  label: '${interestRate.toStringAsFixed(1)}%',
                  onChanged: (double value) {
                    setState(() {
                      interestRate = value;
                    });
                    calculateEMI(); // Recalculate EMI
                  },
                ),
                Text('${interestRate.toStringAsFixed(1)}%'),
                const SizedBox(height: 20),
                const Text(
                  'Loan Tenure (Months)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: loanTenure.toDouble(),
                  min: 6,
                  max: 72,
                  divisions: 66,
                  label: '$loanTenure months',
                  onChanged: (double value) {
                    setState(() {
                      loanTenure = value.toInt();
                    });
                    calculateEMI(); // Recalculate EMI
                  },
                ),
                Text('$loanTenure months'),
                const SizedBox(height: 20),
                // Display the EMI result
                if (emi > 0)
                  Center(
                    child: Text(
                      'EMI: ₹${emi.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
