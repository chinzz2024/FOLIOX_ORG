import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RetireEarly extends StatefulWidget {
  const RetireEarly({super.key});

  @override
  State<RetireEarly> createState() => _RetireEarlyState();
}

class _RetireEarlyState extends State<RetireEarly> {
  final TextEditingController _ageController = TextEditingController();
  String? _displayMessage;
  List<String> _rules = [];
  String? _financialStatus;

  final Map<String, List<String>> _ageBasedRules = {
    '20-30': [
      'Start saving early to leverage compound interest.',
      'Build a solid emergency fund.',
      'Invest in learning skills that increase income.',
    ],
    '31-40': [
      'Increase contributions to retirement accounts.',
      'Diversify your investments to reduce risk.',
      'Plan for significant expenses like a home or children’s education.',
    ],
    '41-50': [
      'Review your retirement goals and adjust savings if necessary.',
      'Start focusing on debt reduction.',
      'Consider long-term care insurance options.',
    ],
    '51+': [
      'Maximize your retirement savings contributions.',
      'Ensure you have a healthcare plan in place.',
      'Start planning for required minimum distributions (RMDs).',
    ],
  };

  Future<Map<String, dynamic>?> _getUserFinancials() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return null;

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('planner').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  void _submit() async {
    final enteredAgeText = _ageController.text;
    if (enteredAgeText.isEmpty) {
      setState(() {
        _displayMessage = 'Please enter a valid age.';
        _rules = [];
        _financialStatus = null;
      });
      return;
    }

    final enteredAge = int.tryParse(enteredAgeText);
    if (enteredAge == null || enteredAge <= 0) {
      setState(() {
        _displayMessage = 'Please enter a valid age.';
        _rules = [];
        _financialStatus = null;
      });
      return;
    }

    String ageCategory;
    if (enteredAge >= 20 && enteredAge <= 30) {
      ageCategory = '20-30';
    } else if (enteredAge >= 31 && enteredAge <= 40) {
      ageCategory = '31-40';
    } else if (enteredAge >= 41 && enteredAge <= 50) {
      ageCategory = '41-50';
    } else {
      ageCategory = '51+';
    }

    final financialData = await _getUserFinancials();
    if (financialData == null) {
      setState(() {
        _displayMessage = 'Could not fetch financial data.';
        _rules = [];
        _financialStatus = null;
      });
      return;
    }

    double income = (financialData['income'] as num?)?.toDouble() ?? 0.0;
    double savings = (financialData['savings'] as num?)?.toDouble() ?? 0.0;
    double expenditure = (financialData['expenditure'] as num?)?.toDouble() ?? 0.0;
    double deduction = (financialData['deduction'] as num?)?.toDouble() ?? 0.0;

    double needs = expenditure + deduction;
    double wants = income * 0.30;
    double expectedSavings = income * 0.20;

    bool followsRule = savings >= expectedSavings;

    setState(() {
      _displayMessage = 'You want to retire at $enteredAge years.';
      _rules = _ageBasedRules[ageCategory]!;
      _financialStatus = followsRule
          ? '✅ You are on track with the 50-30-20 rule!'
          : '❌ You need to save at least ₹${expectedSavings.toStringAsFixed(2)} to follow the 50-30-20 rule.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Early Retire',
          style: TextStyle(color: Colors.white),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan your early retirement. Here are some tips:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "At what age do you want to retire:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      suffixText: 'y',
                      border: const OutlineInputBorder(),
                      hintText: 'Age',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 15),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_displayMessage != null)
              Text(
                _displayMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            if (_financialStatus != null)
              Text(
                _financialStatus!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _financialStatus!.contains('✅') ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            if (_rules.isNotEmpty)
              const Text(
                'Helpful tips for Your Retirement:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            for (String rule in _rules)
              Text(
                '- $rule',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
