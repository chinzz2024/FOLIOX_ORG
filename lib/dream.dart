import 'package:flutter/material.dart';
import 'dart:math';

class DreamHome extends StatefulWidget {
  const DreamHome({Key? key}) : super(key: key);

  @override
  State<DreamHome> createState() => _DreamHomeState();
}

class _DreamHomeState extends State<DreamHome> {
  double loanAmount = 100000;
  double interestRate = 7.0;
  int loanTenure = 12;
  double emi = 0;
  double targetAmount = 0;
  double currentSavings = 0;
  int yearsToGoal = 0;
  bool isEMISelected = false;

  void calculateEMI() {
    double monthlyInterestRate = (interestRate / 100) / 12;
    int months = loanTenure;
    emi = (loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, months)) /
        (pow(1 + monthlyInterestRate, months) - 1);
    setState(() {});
  }

  double calculateMonthlySavings() {
    double remainingAmount = targetAmount - currentSavings;
    return remainingAmount > 0 ? remainingAmount / (yearsToGoal * 12) : 0;
  }

  @override
  void initState() {
    super.initState();
    calculateEMI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How do you want to build your home?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEMISelected = false;
                    });
                  },
                  child: const Text('Ready Cash'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEMISelected = true;
                    });
                  },
                  child: const Text('EMI'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!isEMISelected) ...[
              const Text('Target Amount (₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {
                    targetAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Current Savings (₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {
                    currentSavings = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Years to Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {
                    yearsToGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (targetAmount > 0 && yearsToGoal > 0)
                Text('Monthly Savings Required: ₹${calculateMonthlySavings().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
            if (isEMISelected) ...[
              const Text('Loan Amount (₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Slider(
                value: loanAmount,
                min: 50000,
                max: 5000000,
                divisions: 99,
                label: '₹${loanAmount.toStringAsFixed(0)}',
                onChanged: (double value) {
                  setState(() {
                    loanAmount = value;
                  });
                  calculateEMI();
                },
              ),
              Text('₹${loanAmount.toStringAsFixed(0)}'),
              const SizedBox(height: 20),
              const Text('Interest Rate (%)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Slider(
                value: interestRate,
                min: 1,
                max: 20,
                divisions: 38,
                label: '${interestRate.toStringAsFixed(1)}%',
                onChanged: (double value) {
                  setState(() {
                    interestRate = value;
                  });
                  calculateEMI();
                },
              ),
              Text('${interestRate.toStringAsFixed(1)}%'),
              const SizedBox(height: 20),
              const Text('Loan Tenure (Months)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Slider(
                value: loanTenure.toDouble(),
                min: 6,
                max: 360,
                divisions: 59,
                label: '$loanTenure months',
                onChanged: (double value) {
                  setState(() {
                    loanTenure = value.toInt();
                  });
                  calculateEMI();
                },
              ),
              Text('$loanTenure months'),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'EMI: ₹${emi.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
