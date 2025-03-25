import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculation_page.dart'; // Import the CalculationPage
import 'dart:math'; // For pow() function
import 'dreamcar.dart';
import 'retire.dart';
import 'dream.dart';
import 'emergency.dart';
import 'marriage.dart';

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
  List<String> goalsSelected = [];
  // Marriage-specific variables
  String? selectedGoal;
  double marriageBudget = 0;
  int marriageYears = 0;
  String inflationResult = '';
  String sipSuggestion = '';
  String fdSuggestion = '';

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

Future<void> _fetchFinancialData() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  try {
    // Fetch data from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('financialPlanner')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          // Fetch income
          income = (data['totalIncome'] ?? 0).toDouble();

          // Fetch essential expenses
          essentialExpensesMap = Map<String, double>.from(data['essentialExpenses'] ?? {});
          essentialExpenses = (data['totalEssentialExpenses'] ?? 0).toDouble();

          // Fetch optional expenses
          optionalExpensesMap = Map<String, double>.from(data['optionalExpenses'] ?? {});
          optionalExpenses = (data['totalOptionalExpenses'] ?? 0).toDouble();

          // Fetch savings
          savings = (data['savings'] ?? 0).toDouble();

          // Fetch selected goals
          List<dynamic>? goals = data['goalsSelected'];
          goalsSelected = goals != null 
              ? goals.map((goal) {
                  // Handle both string and map types
                  if (goal is Map) {
                    return goal['goal']?.toString() ?? '';
                  }
                  return goal.toString();
                }).toList()
              : [];

          // Fetch marriage-specific details if Marriage is a selected goal
          if (goalsSelected.contains('Marriage')) {
            marriageBudget = (data['estimatedBudget'] ?? 0).toDouble();
            marriageYears = (data['targetYear'] ?? 0);
            _calculateMarriageDetails();
          }

          isLoading = false;
        });
      }
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
  // Calculate marriage-specific details
  void _calculateMarriageDetails() {
    if (marriageBudget > 0 && marriageYears > 0) {
      // Inflation Calculation (7% inflation rate)
      double inflatedAmount = marriageBudget * pow(1.07, marriageYears);
      inflationResult =
          "You would need ₹${inflatedAmount.toStringAsFixed(2)} for your marriage in $marriageYears years.";

      // SIP Calculation (Assuming 12% annual return, monthly investment of 10k)
      double sipFutureValue =
          10000 * ((pow(1 + 0.01, marriageYears * 12) - 1) / 0.01) * (1 + 0.01);
      sipSuggestion =
          "Investing ₹10,000 per month in SIP at 12% annual return would give you ₹${sipFutureValue.toStringAsFixed(2)} in $marriageYears years.\n\nRecommended SIPs:\n1️⃣ SBI Bluechip Fund\n2️⃣ ICICI Prudential Growth Fund";

      // FD Calculation (Assuming 7% annual return)
      double fdFutureValue = savings * pow(1.07, marriageYears);
      fdSuggestion =
          "Placing your current savings of ₹${savings.toStringAsFixed(2)} in an FD at 7% annual return would grow to ₹${fdFutureValue.toStringAsFixed(2)} in $marriageYears years.";
    } else {
      inflationResult = '';
      sipSuggestion = '';
      fdSuggestion = '';
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
          // Green or Red Light with investment advice
          Center(
            child: Column(
              children: [
                Icon(
                  isFollowingRule ? Icons.check_circle : Icons.error,
                  color: isFollowingRule ? Colors.green : Colors.red,
                  size: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  isFollowingRule
                      ? 'Great! You are following the 50-30-20 rule!'
                      : 'You are NOT following the 50-30-20 rule.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isFollowingRule ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Show investment suggestions only if following the rule
                if (isFollowingRule) ...[
                  _buildInvestmentSuggestions(),
                ],
              ],
            ),
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
          _buildFinancialRow('Savings', savings,
              percentage: savingsPercentage),
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

          // Marriage-specific details
          if (selectedGoal == 'Marriage') ...[
            const SizedBox(height: 20),
            const Text(
              'Marriage Planning:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (inflationResult.isNotEmpty)
              Text(inflationResult,
                  style: const TextStyle(fontSize: 16, color: Colors.red)),
            if (sipSuggestion.isNotEmpty)
              Text(sipSuggestion,
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
            if (fdSuggestion.isNotEmpty)
              Text(fdSuggestion,
                  style: const TextStyle(fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 20),
          ],

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

          if (goalsSelected.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Your Selected Goals:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: goalsSelected.map((goal) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      
                      // Goal-specific navigation
                      switch (goal) {
                        case 'Marriage':
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Marriage()),
                          );
                          break;
                        case 'Dream Car':
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => DreamcarPage()),
                          );
                          break;
                        case 'Retirement':
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => RetireEarly()),
                          );
                          break;
                        case 'Dream Home':
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => DreamHomeScreen()),
                          );
                          break;
                        case 'Emergency Fund':
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => EmergencyFund()),
                          );
                          break;
                      }
                    },
                    child: Text(
                      '👉 Click here to plan for $goal', 
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 20), // Add some space at the bottom
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

  Widget _buildInvestmentSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Investment Suggestions:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '📈 SIP Investment: Invest ₹10,000/month in SIPs at 12% annual return. Recommended Funds:\n'
          '   ✅ SBI Bluechip Fund\n'
          '   ✅ ICICI Prudential Growth Fund\n',
          style: const TextStyle(fontSize: 16, color: Colors.green),
        ),
        const SizedBox(height: 10),
        Text(
          '🏦 Fixed Deposit: Deposit your savings in an FD at 7% interest for stable returns.',
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        Text(
          '💡 Other Investments:\n'
          '   📊 Consider index funds (Nifty 50, S&P 500 ETFs)\n'
          '   🏡 Real estate investments for long-term growth\n'
          '   📜 Government bonds for risk-free returns',
          style: const TextStyle(fontSize: 16, color: Colors.orange),
        ),
      ],
    );
  }

  // Helper method to build a rule comparison row
  Widget _buildRuleRow(
      String label, double userPercentage, double rulePercentage) {
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
              color:
                  userPercentage <= rulePercentage ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build recommendations
List<Widget> _buildRecommendations(
    double needsPercentage, double wantsPercentage) {
  List<Widget> recommendations = [];

  // Recommendations for essential expenses
  if (needsPercentage > 50) {
    recommendations.addAll([
      const Text(
        'Your essential expenses are too high. Consider:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      ...essentialExpensesMap.entries.map((entry) {
        return Text(
          '- Reduce ${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        );
      }),
      const SizedBox(height: 10),

      // New section for reallocating optional expenses
      const Text(
        'Reallocation Strategy:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      Text(
        '💡 You can reduce your optional expenses and redirect funds to essential expenses:',
        style: const TextStyle(fontSize: 16),
      ),
      Text(
        '- Current Optional Expenses: ₹${optionalExpenses.toStringAsFixed(2)} (${wantsPercentage.toStringAsFixed(2)}%)',
        style: const TextStyle(fontSize: 16),
      ),
      Text(
        '- Recommended Reallocation: Transfer 5-10% of optional expenses to essential expenses',
        style: const TextStyle(fontSize: 16, color: Colors.green),
      ),
      const SizedBox(height: 10),
      
      // Suggested areas to cut from optional expenses
      const Text(
        'Potential Areas to Reduce in Optional Expenses:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      ...optionalExpensesMap.entries.map((entry) {
        return Text(
          '- Consider reducing ${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        );
      }),
      const SizedBox(height: 10),
    ]);
  }

  // Recommendations for optional expenses
  if (wantsPercentage > 30) {
    recommendations.addAll([
      const Text(
        'Your optional expenses are too high. Consider:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      ...optionalExpensesMap.entries.map((entry) {
        return Text(
          '- Reduce ${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        );
      }),
      const SizedBox(height: 10),
    ]);
  }

  return recommendations;
}
}
