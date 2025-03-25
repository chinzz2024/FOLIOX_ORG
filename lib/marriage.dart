import 'package:flutter/material.dart';
import 'dart:math';

class Marriage extends StatefulWidget {
  const Marriage({super.key});

  @override
  State<Marriage> createState() => _MarriageState();
}

class _MarriageState extends State<Marriage> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _monthlySavingsController = TextEditingController();
  final TextEditingController _weddingDateController = TextEditingController();
  String _inflationResult = '';
  String _sipSuggestion = '';
  String _fdSuggestion = '';

  void _calculateInflation() {
    setState(() {
      double budget = double.tryParse(_budgetController.text) ?? 0;
      int years = int.tryParse(_weddingDateController.text) ?? 0;
      double savings = double.tryParse(_savingsController.text) ?? 0;
      
      if (budget > 0 && years > 0) {
        // Inflation Calculation
        double inflatedAmount = budget * pow(1.07, years);
        _inflationResult = "You would need ₹${inflatedAmount.toStringAsFixed(2)} rupees.";

        // SIP Calculation (Assuming 12% annual return, monthly investment of 10k)
        double sipFutureValue = 10000 * ((pow(1 + 0.01, years * 12) - 1) / 0.01) * (1 + 0.01);
        _sipSuggestion = "Investing ₹10,000 per month in SIP at 12% annual return would give you ₹${sipFutureValue.toStringAsFixed(2)} in $years years.\n\nRecommended SIPs:\n1️⃣ SBI Bluechip Fund\n2️⃣ ICICI Prudential Growth Fund";

        // FD Calculation (Assuming 7% annual return)
        double fdFutureValue = savings * pow(1.07, years);
        _fdSuggestion = "Placing your current savings of ₹${savings.toStringAsFixed(2)} in an FD at 7% annual return would grow to ₹${fdFutureValue.toStringAsFixed(2)} in $years years.";
      } else {
        _inflationResult = "";
        _sipSuggestion = "";
        _fdSuggestion = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marriage Planner', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Total Estimated Budget', _budgetController, _calculateInflation),
            _buildTextField('Current Savings', _savingsController, _calculateInflation),
            _buildTextField('Monthly Savings', _monthlySavingsController, null),
            _buildTextField('Total Years Left', _weddingDateController, _calculateInflation),
            const SizedBox(height: 10),
            if (_inflationResult.isNotEmpty)
              Text(_inflationResult, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            if (_sipSuggestion.isNotEmpty)
              Text(_sipSuggestion, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            if (_fdSuggestion.isNotEmpty)
              Text(_fdSuggestion, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Function? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged();
          }
        },
      ),
    );
  }
}