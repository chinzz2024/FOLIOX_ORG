import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  double income = 0;
  double essentialExpenses = 0;
  double optionalExpenses = 0;
  double savings = 0;
  bool isLoading = true;
  Map<String, double> essentialExpensesMap = {};
  Map<String, double> optionalExpensesMap = {};

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      // Fetch data from the 'financialPlanner' collection
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          // Fetch income
          income = (snapshot['Income']?['Base Salary'] ?? 0) +
              (snapshot['Income']?['Dearness Allowance'] ?? 0) +
              (snapshot['Income']?['House Rent Allowance'] ?? 0) +
              (snapshot['Income']?['Transport Allowance'] ?? 0);

          // Fetch essential expenses
          essentialExpensesMap = Map<String, double>.from(snapshot['Essential Expenses']);
          essentialExpenses = essentialExpensesMap.values.reduce((a, b) => a + b);

          // Fetch optional expenses
          optionalExpensesMap = Map<String, double>.from(snapshot['Optional Expenses']);
          optionalExpenses = optionalExpensesMap.values.reduce((a, b) => a + b);

          // Calculate savings
          savings = income - (essentialExpenses + optionalExpenses);

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No financial data found!')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate percentages
    double needsPercentage = (essentialExpenses / income) * 100;
    double wantsPercentage = (optionalExpenses / income) * 100;
    double savingsPercentage = (savings / income) * 100;

    // Check if the user is following the 50-30-20 rule
    bool isFollowingRule = (needsPercentage <= 50) &&
        (wantsPercentage <= 30) &&
        (savingsPercentage >= 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Green or Red Light
            Center(
              child: Icon(
                isFollowingRule ? Icons.check_circle : Icons.error,
                color: isFollowingRule ? Colors.green : Colors.red,
                size: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFollowingRule
                  ? 'You are following the 50-30-20 rule!'
                  : 'You are NOT following the 50-30-20 rule.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isFollowingRule ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Income
            _buildFinancialRow('Income', income),
            const SizedBox(height: 10),

            // Essential Expenses
            _buildFinancialRow('Essential Expenses (Needs)', essentialExpenses,
                percentage: needsPercentage),
            const SizedBox(height: 10),

            // Optional Expenses
            _buildFinancialRow('Optional Expenses (Wants)', optionalExpenses,
                percentage: wantsPercentage),
            const SizedBox(height: 10),

            // Savings
            _buildFinancialRow('Savings', savings, percentage: savingsPercentage),
            const SizedBox(height: 20),

            // Rule Breakdown
            const Text(
              '50-30-20 Rule Breakdown:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRuleRow('Needs (50%)', needsPercentage, 50),
            _buildRuleRow('Wants (30%)', wantsPercentage, 30),
            _buildRuleRow('Savings (20%)', savingsPercentage, 20),

            // Recommendations
            if (!isFollowingRule) ...[
              const SizedBox(height: 20),
              const Text(
                'Recommendations:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._buildRecommendations(needsPercentage, wantsPercentage),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to build a financial row
  Widget _buildFinancialRow(String label, double amount, {double? percentage}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          percentage != null
              ? '₹${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(2)}%)'
              : '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Helper method to build a rule comparison row
  Widget _buildRuleRow(String label, double userPercentage, double rulePercentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${userPercentage.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 16,
              color: userPercentage <= rulePercentage ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build recommendations
  List<Widget> _buildRecommendations(double needsPercentage, double wantsPercentage) {
    List<Widget> recommendations = [];

    // Recommendations for essential expenses
    if (needsPercentage > 50) {
      recommendations.addAll([
        const Text(
          'Your essential expenses are too high. Consider:',
          style: TextStyle(fontSize: 16),
        ),
        ...essentialExpensesMap.entries.map((entry) {
          return Text(
            '- Reduce ${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          );
        }).toList(),
        const SizedBox(height: 10),
      ]);
    }

    // Recommendations for optional expenses
    if (wantsPercentage > 30) {
      recommendations.addAll([
        const Text(
          'Your optional expenses are too high. Consider:',
          style: TextStyle(fontSize: 16),
        ),
        ...optionalExpensesMap.entries.map((entry) {
          return Text(
            '- Reduce ${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          );
        }).toList(),
        const SizedBox(height: 10),
      ]);
    }

    return recommendations;
  }
}