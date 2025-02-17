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
  final TextEditingController _currentAgeController = TextEditingController();
  String? _displayMessage;
  List<String> _rules = [];
  String? _financialStatus;
  Color _statusColor = Colors.transparent;
  List<String> _financialSuggestions = [];

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

  Future<Map<String, dynamic>?> _fetchUserFinancials() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('planner')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  void _evaluateRetirementPlan() async {
    final ageText = _ageController.text;
    final currentAgeText = _currentAgeController.text;

    if (ageText.isEmpty || currentAgeText.isEmpty) {
      setState(() {
        _displayMessage = 'Please enter a valid age and current age.';
        _rules = [];
        _financialStatus = null;
        _statusColor = Colors.transparent;
        _financialSuggestions = [];
      });
      return;
    }

    final age = int.tryParse(ageText);
    final currentAge = int.tryParse(currentAgeText);

    if (age == null || age <= 0 || currentAge == null || currentAge <= 0) {
      setState(() {
        _displayMessage = 'Please enter valid ages.';
        _rules = [];
        _financialStatus = null;
        _statusColor = Colors.transparent;
        _financialSuggestions = [];
      });
      return;
    }

    final financialData = await _fetchUserFinancials();
    if (financialData == null) {
      setState(() {
        _displayMessage = 'Unable to fetch financial data.';
        _rules = [];
        _financialStatus = null;
        _statusColor = Colors.transparent;
        _financialSuggestions = [];
      });
      return;
    }

    final income = (financialData['Income'] as num?)?.toDouble() ?? 0.0;
    final savings = (financialData['Savings'] as num?)?.toDouble() ?? 0.0;
    final expenditure = (financialData['Expenditure'] as num?)?.toDouble() ?? 0.0;
    final deduction = (financialData['Deduction'] as num?)?.toDouble() ?? 0.0;

    final needs = expenditure + deduction;
    final expectedSavings = income * 0.20;

    final isNeedsWithinLimit = needs <= income * 0.50;
    final isSavingsEnough = savings >= expectedSavings;

    final followsRule = isNeedsWithinLimit && isSavingsEnough;

    setState(() {
      _displayMessage = 'You plan to retire at $age years.';
      _rules = _ageBasedRules[_getAgeCategory(age)] ?? [];
      _financialStatus = followsRule
          ? '✅ You are following the 50-30-20 rule!'
          : '❌ You are not following the 50-30-20 rule. '
              'Ensure your needs (₹${needs.toStringAsFixed(2)}) are ≤50% of income (₹${(income * 0.50).toStringAsFixed(2)}) '
              'and savings (₹${savings.toStringAsFixed(2)}) are ≥20% of income (₹${expectedSavings.toStringAsFixed(2)}).';
      _statusColor = followsRule ? Colors.green : Colors.red;

      if (followsRule) {
        _financialSuggestions = _getFinancialSuggestions(currentAge, age, income);
      } else {
        _financialSuggestions = [];
      }
    });
  }

  List<String> _getFinancialSuggestions(int currentAge, int retirementAge, double income) {
    final yearsToRetirement = retirementAge - currentAge;
    final monthlySavings = income * 0.20 / 12; // 20% of income as monthly savings
    final sipReturnRate = 0.12; // 12% annual return
    final futureValue = _calculateSIPFutureValue(monthlySavings, sipReturnRate, yearsToRetirement);

    return [
      'Invest in a Systematic Investment Plan (SIP) with a 12% annual return.',
      'Save ₹${monthlySavings.toStringAsFixed(2)} monthly for $yearsToRetirement years to accumulate ₹${futureValue.toStringAsFixed(2)}.',
      'Diversify your portfolio with equity, debt, and gold investments.',
      'Consider investing in a retirement-focused mutual fund or NPS (National Pension System).',
      'Review your investment portfolio annually to ensure it aligns with your retirement goals.',
    ];
  }

  double _calculateSIPFutureValue(double monthlySavings, double annualReturn, int years) {
    final monthlyReturn = annualReturn / 12;
    final months = years * 12;
    double futureValue = 0;

    for (int i = 0; i < months; i++) {
      futureValue = (futureValue + monthlySavings) * (1 + monthlyReturn);
    }

    return futureValue;
  }

  String _getAgeCategory(int age) {
    if (age >= 20 && age <= 30) return '20-30';
    if (age >= 31 && age <= 40) return '31-40';
    if (age >= 41 && age <= 50) return '41-50';
    return '51+';
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
          onPressed: () => Navigator.pop(context),
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
                  "Current Age:",
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
                    controller: _currentAgeController,
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
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "Retirement Age:",
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
                onPressed: _evaluateRetirementPlan,
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
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: _statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _financialStatus!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ],
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
            const SizedBox(height: 16),
            if (_financialSuggestions.isNotEmpty)
              const Text(
                'Financial Planning Suggestions:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            for (String suggestion in _financialSuggestions)
              Text(
                '- $suggestion',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}