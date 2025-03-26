import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculation_page.dart';
import 'dart:math';
import 'dreamcar.dart';
import 'retire.dart';
import 'dream.dart';
import 'emergency.dart';
import 'marriage.dart';
import 'dart:async';

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
    _fetchFinancialData();
  }

  @override
  void didUpdateWidget(SummaryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRefresh && !oldWidget.shouldRefresh) {
      _fetchFinancialData();
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

      if (mounted) {
        setState(() {
          income = _parseDouble(data['totalIncome']);
          essentialExpenses = _parseDouble(data['totalEssentialExpenses']);
          optionalExpenses = _parseDouble(data['totalOptionalExpenses']);
          savings = _parseDouble(data['savings']);
          
          essentialExpensesMap = data['essentialExpenses'] is Map 
              ? Map<String, double>.from(data['essentialExpenses'])
              : {};
          optionalExpensesMap = data['optionalExpenses'] is Map
              ? Map<String, double>.from(data['optionalExpenses'])
              : {};

          goalsSelected = _parseGoals(data['goalsSelected']);

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

  void _calculateMarriageDetails() {
    if (marriageBudget > 0 && marriageYears > 0) {
      double inflatedAmount = marriageBudget * pow(1.07, marriageYears);
      inflationResult =
          "You would need ₹${inflatedAmount.toStringAsFixed(2)} for your marriage in $marriageYears years.";

      double sipFutureValue =
          10000 * ((pow(1 + 0.01, marriageYears * 12) - 1) / 0.01) * (1 + 0.01);
      sipSuggestion =
          "Investing ₹10,000 per month in SIP at 12% annual return would give you ₹${sipFutureValue.toStringAsFixed(2)} in $marriageYears years.\n\nRecommended SIPs:\n1️⃣ SBI Bluechip Fund\n2️⃣ ICICI Prudential Growth Fund";

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
    // Calculate percentages
    double needsPercentage = (essentialExpenses / income) * 100;
    double wantsPercentage = (optionalExpenses / income) * 100;
    double savingsPercentage = (savings / income) * 100;

    // Check if the user is following the 50-30-20 rule
    bool isFollowingRule = (needsPercentage <= 50) &&
        (wantsPercentage <= 30) &&
        (savingsPercentage >= 20);

    if (isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary',style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: ()=> Navigator.pop(context),
       icon: Icon(Icons.arrow_back, color:Colors.white)),
        backgroundColor: Color(0xFF0F2027),
        elevation: 10,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
        ),
      ),
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
              _buildStatusCard(isFollowingRule),
              const SizedBox(height: 20),
              _buildFinancialOverviewCard(),
              const SizedBox(height: 20),
              _buildRuleBreakdownCard(),
              if (selectedGoal == 'Marriage') _buildMarriagePlanningCard(),
              if (!isFollowingRule) _buildRecommendationsCard(),
              if (goalsSelected.isNotEmpty) _buildGoalsCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      
      ),
    
    );
  
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
        backgroundColor: const Color(0xFF0A0E2D),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A5A98)),
            ),
            const SizedBox(height: 20),
            Text(
              'Updating your financial summary...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isFollowingRule) {
  return Center( // Centering the card
    child: Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isFollowingRule ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures proper spacing
          children: [
            Icon(
              isFollowingRule ? Icons.check_circle : Icons.warning,
              color: isFollowingRule ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              isFollowingRule 
                  ? 'Great! You are following the 50-30-20 rule!' 
                  : 'You are NOT following the 50-30-20 rule',
              textAlign: TextAlign.center, // Center align text
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isFollowingRule ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
            if (isFollowingRule) ...[
              const SizedBox(height: 10),
              const Text(
                '🎉 Keep up the good financial habits!',
                textAlign: TextAlign.center, // Ensuring text is centered
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}


  Widget _buildFinancialOverviewCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0E2D)),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _buildFinancialRowWithIcon(
              Icons.attach_money, 
              'Income', 
              income,
              Colors.green
            ),
            _buildFinancialRowWithIcon(
              Icons.home, 
              'Essential Expenses', 
              essentialExpenses,
              Colors.blue
            ),
            _buildFinancialRowWithIcon(
              Icons.shopping_cart, 
              'Optional Expenses', 
              optionalExpenses,
              Colors.orange
            ),
            _buildFinancialRowWithIcon(
              Icons.savings, 
              'Savings', 
              savings,
              Colors.purple
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRowWithIcon(IconData icon, String label, double amount, Color color) {
    double percentage = (amount / income) * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleBreakdownCard() {
    double needsPercentage = (essentialExpenses / income) * 100;
    double wantsPercentage = (optionalExpenses / income) * 100;
    double savingsPercentage = (savings / income) * 100;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '50-30-20 Rule Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0E2D)),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _buildRuleProgressBar('Needs (50%)', needsPercentage, 50, Colors.blue),
            _buildRuleProgressBar('Wants (30%)', wantsPercentage, 30, Colors.orange),
            _buildRuleProgressBar('Savings (20%)', savingsPercentage, 20, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleProgressBar(String label, double userPercentage, double rulePercentage, Color color) {
    bool isOver = userPercentage > rulePercentage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${userPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOver ? Colors.red : Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: userPercentage / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Positioned(
                left: '${rulePercentage}%'.length * 5.0,
                child: Container(
                  height: 10,
                  width: 2,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (isOver)
            Text(
              '${(userPercentage - rulePercentage).toStringAsFixed(1)}% over recommended',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildMarriagePlanningCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 10),
                const Text(
                  'Marriage Planning',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0E2D)),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            if (inflationResult.isNotEmpty)
              _buildInfoTile(
                Icons.trending_up,
                'Future Cost',
                inflationResult,
                Colors.red),
            if (sipSuggestion.isNotEmpty)
              _buildInfoTile(
                Icons.bar_chart,
                'SIP Investment',
                sipSuggestion,
                Colors.green),
            if (fdSuggestion.isNotEmpty)
              _buildInfoTile(
                Icons.account_balance,
                'Fixed Deposit',
                fdSuggestion,
                Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    double needsPercentage = (essentialExpenses / income) * 100;
    double wantsPercentage = (optionalExpenses / income) * 100;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(top: 20),
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.orange),
                const SizedBox(width: 10),
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0E2D)),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            if (needsPercentage > 50) ...[
              const Text(
                'Essential Expenses Reduction:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
              ),
              ...essentialExpensesMap.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.chevron_right, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Reduce ${entry.key} by 10-15% (Current: ₹${entry.value.toStringAsFixed(2)})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (wantsPercentage > 30) ...[
              const Text(
                'Optional Expenses Reduction:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
              ),
              ...optionalExpensesMap.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.chevron_right, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Limit ${entry.key} spending (Current: ₹${entry.value.toStringAsFixed(2)})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              '💡 Tip: Try to save at least 20% of your income each month',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Financial Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0E2D)),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: goalsSelected.map((goal) {
                return ActionChip(
                  avatar: Icon(_getGoalIcon(goal)),
                  label: Text(goal),
                  backgroundColor: _getGoalColor(goal).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getGoalColor(goal),
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () {
                    _navigateToGoalPage(goal);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap on any goal to plan for it',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String content, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 34.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Marriage': return Icons.favorite;
      case 'Dream Car': return Icons.directions_car;
      case 'Retirement': return Icons.emoji_people;
      case 'Dream Home': return Icons.home;
      case 'Emergency Fund': return Icons.emergency;
      default: return Icons.flag;
    }
  }

  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'Marriage': return Colors.red;
      case 'Dream Car': return Colors.blue;
      case 'Retirement': return Colors.purple;
      case 'Dream Home': return Colors.orange;
      case 'Emergency Fund': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _navigateToGoalPage(String goal) async {
    Widget page;
    switch (goal) {
      case 'Marriage': page = MarriageGoalPage(); break;
      case 'Dream Car': page = DreamcarPage(); break;
      case 'Retirement': page = RetireEarly(); break;
      case 'Dream Home': page = DreamHomeScreen(); break;
      case 'Emergency Fund': page = EmergencyFund(); break;
      default: return;
    }
    
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => page),
    );
    _fetchFinancialData();
  }
}