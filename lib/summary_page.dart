import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For pow() function
import 'dreamcar.dart';
import 'retire.dart';
import 'dream.dart';
import 'emergency.dart';
import 'marriage.dart';
import 'dart:async'; // Add this at the top of your file

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key, this.shouldRefresh = false});

  final bool shouldRefresh;
  

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
  String _errorMessage = '';
  String? selectedGoal;
  double marriageBudget = 0;
  bool _hasError = false;

  int marriageYears = 0;
  String inflationResult = '';
  String sipSuggestion = '';
  String fdSuggestion = '';

  @override
void initState() {
  super.initState();
  _fetchFinancialData(); // Keep your existing initialization
}

@override
void didUpdateWidget(SummaryPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.shouldRefresh && !oldWidget.shouldRefresh) {
    _fetchFinancialData(); // Add this new method
  }
}

Future<void> _fetchFinancialData() async {
  if (!mounted) return;
  
  setState(() {
    isLoading = true;
    _hasError = false;
    _errorMessage = '';
  });

  try {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _handleError('User not authenticated');
      return;
    }

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('financialPlanner')
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 10));

    if (!snapshot.exists) {
      _handleError('No financial data found');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      _handleError('Invalid data format');
      return;
    }

    // Parse and update state
    if (mounted) {
      setState(() {
        income = _parseDouble(data['totalIncome']);
        essentialExpenses = _parseDouble(data['totalEssentialExpenses']);
        optionalExpenses = _parseDouble(data['totalOptionalExpenses']);
        savings = _parseDouble(data['savings']);
        
        // Parse expenses maps
        essentialExpensesMap = data['essentialExpenses'] is Map 
            ? Map<String, double>.from(data['essentialExpenses'])
            : {};
        optionalExpensesMap = data['optionalExpenses'] is Map
            ? Map<String, double>.from(data['optionalExpenses'])
            : {};

        // Parse goals
        goalsSelected = _parseGoals(data['goalsSelected']);

        // Handle marriage data if needed
        if (goalsSelected.contains('Marriage')) {
          marriageBudget = _parseDouble(data['estimatedBudget']);
          marriageYears = _parseInt(data['targetYear']);
          _calculateMarriageDetails();
        }

        isLoading = false;
      });
    }
  } on FirebaseException catch (e) {
    _handleError('Database error: ${e.message}');
  } on TimeoutException {
    _handleError('Request timed out. Please try again');
  } catch (e) {
    _handleError('An unexpected error occurred');
  }
}

// Helper methods:

List<String> _parseGoals(dynamic goalsData) {
  if (goalsData is! List) return [];
  return goalsData.map((goal) {
    if (goal is Map) return goal['goal']?.toString() ?? '';
    return goal.toString();
  }).toList();
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

void _handleError(String message) {
  if (!mounted) return;
  
  setState(() {
    isLoading = false;
    _hasError = true;
    _errorMessage = message;
  });
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Updating your financial summary...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
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
    body: RefreshIndicator(
      onRefresh: _fetchFinancialData,
      color: Colors.blue,
      backgroundColor: Colors.white,
      displacement: 40.0,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      onTap: () async {
                        if (!mounted) return;
                        
                        // Goal-specific navigation
                        switch (goal) {
                          case 'Marriage':
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => MarriageGoalPage()),
                            );
                            _fetchFinancialData();
                            break;
                          case 'Dream Car':
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DreamcarPage(),
                              ),
                            );
                            _fetchFinancialData();
                            break;
                          case 'Retirement':
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => RetireEarly()),
                            );
                            _fetchFinancialData();
                            break;
                          case 'Dream Home':
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => DreamHomeScreen()),
                            );
                            _fetchFinancialData();
                            break;
                          case 'Emergency Fund':
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => EmergencyFund()),
                            );
                            _fetchFinancialData();
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
