import 'package:flutter/material.dart';
import 'dart:math'; // Add this import for the 'pow()' function

class DreamcarPage extends StatefulWidget {
  @override
  _DreamcarPageState createState() => _DreamcarPageState();
}

class _DreamcarPageState extends State<DreamcarPage> {
  // Controllers
  TextEditingController _targetAmountController = TextEditingController();
  TextEditingController _currentSavingsController = TextEditingController();
  TextEditingController _yearsToGoalController = TextEditingController();

  // Variables for storing user input
  double targetAmount = 0;
  double loanAmount = 0;
  double currentSavings = 0;
  int yearsToGoal = 0;
  bool isEMISelected = false;
  bool showDownPaymentFields = false;
  double interestRate = 0;
  int loanTenure = 0;
  double emi = 0;

  // Calculate Monthly Savings Method
  double calculateMonthlySavings() {
    if (targetAmount > 0 && yearsToGoal > 0) {
      return (targetAmount - currentSavings) / (yearsToGoal * 12);
    }
    return 0;
  }

  // Calculate Progress Method
  double calculateProgress() {
    if (targetAmount > 0) {
      return (currentSavings / targetAmount) * 100;
    }
    return 0;
  }

  // Calculate EMI Method
  void calculateEMI() {
    if (loanAmount > 0 && interestRate > 0 && loanTenure > 0) {
      double monthlyInterestRate = interestRate / 100 / 12;
      double emiAmount = loanAmount *
          monthlyInterestRate /
          (1 - pow((1 + monthlyInterestRate), -loanTenure));
      setState(() {
        emi = emiAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dream Car Calculator'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _targetAmountController,
              decoration: InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  targetAmount = double.tryParse(value) ?? 0;
                });
              },
            ),
            TextField(
              controller: _currentSavingsController,
              decoration: InputDecoration(labelText: 'Current Savings'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  currentSavings = double.tryParse(value) ?? 0;
                });
              },
            ),
            TextField(
              controller: _yearsToGoalController,
              decoration: InputDecoration(labelText: 'Years to Goal'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  yearsToGoal = int.tryParse(value) ?? 0;
                });
              },
            ),
            if (!isEMISelected && showDownPaymentFields) ...[
              TextField(
                decoration: InputDecoration(labelText: 'Down Payment'),
                keyboardType: TextInputType.number,
              ),
            ],
            SwitchListTile(
              title: Text('EMI Option'),
              value: isEMISelected,
              onChanged: (bool value) {
                setState(() {
                  isEMISelected = value;
                  showDownPaymentFields = !value;
                });
              },
            ),
            if (isEMISelected) ...[
              TextField(
                decoration: InputDecoration(labelText: 'Loan Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    loanAmount = double.tryParse(value) ?? 0;
                  });
                  calculateEMI(); // Recalculate EMI on value change
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Interest Rate (%)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    interestRate = double.tryParse(value) ?? 0;
                  });
                  calculateEMI(); // Recalculate EMI on value change
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Loan Tenure (Months)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    loanTenure = int.tryParse(value) ?? 0;
                  });
                  calculateEMI(); // Recalculate EMI on value change
                },
              ),
            ],
            Text('Monthly Savings Required: ₹${calculateMonthlySavings().toStringAsFixed(2)}'),
            Text('Progress: ${calculateProgress().toStringAsFixed(2)}%'),
            if (isEMISelected) ...[
              Text('EMI: ₹${emi.toStringAsFixed(2)}'),
            ],
            ElevatedButton(
              onPressed: () {
                // Handle the final calculations or navigation
              },
              child: Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }
}
