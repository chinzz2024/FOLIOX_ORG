import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int income = 0;
  int essentialExpenses = 0;
  int optionalExpenses = 0;
  int savings = 0;
  bool isLoading = true;
  Map<String, int> essentialExpensesMap = {};
  Map<String, int> optionalExpensesMap = {};
  List<String> goalsSelected = [];
  String _errorMessage = '';
  String? selectedGoal;
  int marriageBudget = 0;
  bool _hasError = false;
  int marriageYears = 0;
  String inflationResult = '';
  String sipSuggestion = '';
  String fdSuggestion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFinancialData();
    });
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

      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      
      // Safely parse all data as integers
      final parsedIncome = _parseInt(data['totalIncome']);
      final parsedEssentialExpenses = _parseInt(data['totalEssentialExpenses']);
      final parsedOptionalExpenses = _parseInt(data['totalOptionalExpenses']);
      final parsedSavings = _parseInt(data['savings']);
      
      final parsedEssentialMap = (data['essentialExpenses'] is Map<String, dynamic> 
          ? (data['essentialExpenses'] as Map<String, dynamic>).map<String, int>(
              (k, v) => MapEntry(k, _parseInt(v)))
          : <String, int>{});

      final parsedOptionalMap = (data['optionalExpenses'] is Map<String, dynamic>
          ? (data['optionalExpenses'] as Map<String, dynamic>).map<String, int>(
              (k, v) => MapEntry(k, _parseInt(v)))
          : <String, int>{});

      final parsedGoals = _parseGoals(data['goalsSelected'] ?? []);
      
      int parsedMarriageBudget = 0;
      int parsedMarriageYears = 0;
      
      if (parsedGoals.contains('Marriage')) {
        parsedMarriageBudget = _parseInt(data['estimatedBudget']);
        parsedMarriageYears = _parseInt(data['targetYear']);
      }

      if (mounted) {
        setState(() {
          income = parsedIncome;
          essentialExpenses = parsedEssentialExpenses;
          optionalExpenses = parsedOptionalExpenses;
          savings = parsedSavings;
          essentialExpensesMap = parsedEssentialMap;
          optionalExpensesMap = parsedOptionalMap;
          goalsSelected = parsedGoals;
          marriageBudget = parsedMarriageBudget;
          marriageYears = parsedMarriageYears;
          
          if (goalsSelected.contains('Marriage')) {
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
      _handleError('An unexpected error occurred: $e');
    }
  }

  List<String> _parseGoals(dynamic goalsData) {
    if (goalsData is List) {
      return goalsData.map((goal) {
        if (goal is Map) return goal['goal']?.toString() ?? '';
        return goal.toString();
      }).where((goal) => goal.isNotEmpty).toList();
    }
    return [];
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
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
      // Calculate inflated amount (7% annual inflation)
      int inflatedAmount = (marriageBudget * pow(1.07, marriageYears)).round();
      
      // Calculate SIP future value (12% annual return, monthly compounding)
      int sipFutureValue = (10000 * ((pow(1.01, marriageYears * 12) - 1) / 0.01 * 1.01).round());
      
      // Calculate FD future value (7% annual return)
      int fdFutureValue = (savings * pow(1.07, marriageYears)).round();

      setState(() {
        inflationResult =
            "You would need ₹$inflatedAmount for your marriage in $marriageYears years.";

        sipSuggestion =
            "Investing ₹10,000 per month in SIP at 12% annual return would give you ₹$sipFutureValue in $marriageYears years.\n\nRecommended SIPs:\n1️⃣ SBI Bluechip Fund\n2️⃣ ICICI Prudential Growth Fund";

        fdSuggestion =
            "Placing your current savings of ₹$savings in an FD at 7% annual return would grow to ₹$fdFutureValue in $marriageYears years.";
      });
    } else {
      setState(() {
        inflationResult = '';
        sipSuggestion = '';
        fdSuggestion = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    // Calculate percentages safely (clamp between 0-100)
    double needsPercentage = income > 0 ? (essentialExpenses / income) * 100 : 0;
    double wantsPercentage = income > 0 ? (optionalExpenses / income) * 100 : 0;
    double savingsPercentage = income > 0 ? (savings / income) * 100 : 0;

    // Ensure percentages are within bounds
    needsPercentage = needsPercentage.clamp(0, 100);
    wantsPercentage = wantsPercentage.clamp(0, 100);
    savingsPercentage = savingsPercentage.clamp(0, 100);

    // Check if the user is following the 50-30-20 rule
    bool isFollowingRule = (needsPercentage <= 50) &&
        (wantsPercentage <= 30) &&
        (savingsPercentage >= 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 10,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
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
              _buildRuleBreakdownCard(needsPercentage, wantsPercentage, savingsPercentage),
              
              if (!isFollowingRule) _buildRecommendationsCard(needsPercentage, wantsPercentage),
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A5A98)),
            ),
            SizedBox(height: 20),
            Text(
              'Updating your financial summary...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
        backgroundColor: const Color(0xFF0A0E2D),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchFinancialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isFollowingRule) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isFollowingRule ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isFollowingRule ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
            ),
            if (isFollowingRule) ...[
              const SizedBox(height: 10),
              const Text(
                '🎉 Keep up the good financial habits!',
                style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverviewCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            _buildFinancialRowWithIcon(Icons.attach_money, 'Income', income, Colors.green),
            _buildFinancialRowWithIcon(Icons.home, 'Essential Expenses', essentialExpenses, Colors.blue),
            _buildFinancialRowWithIcon(Icons.shopping_cart, 'Optional Expenses', optionalExpenses, Colors.orange),
            _buildFinancialRowWithIcon(Icons.savings, 'Savings', savings, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRowWithIcon(IconData icon, String label, int amount, Color color) {
    double percentage = income > 0 ? (amount / income * 100).clamp(0, 100) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            '₹$amount',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildRuleBreakdownCard(double needsPercentage, double wantsPercentage, double savingsPercentage) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              Text(label, style: const TextStyle(fontSize: 16)),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  double widthFactor = (userPercentage / 100).clamp(0.0, 1.0);
                  return FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                },
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
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
        ],
      ),
    );
  }

  


  Widget _buildRecommendationsCard(double needsPercentage, double wantsPercentage) {
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
      color: Colors.red,
    ),
  ),
  const SizedBox(height: 8),
  ...essentialExpensesMap.entries.map((entry) => 
    Container(
      width: MediaQuery.of(context).size.width * 0.9, // Takes 90% of screen width
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.chevron_right, size: 16),
          const SizedBox(width: 8),
          Expanded( // Makes text take available space and wrap if needed
            child: Text(
              'Reduce ${entry.key} by 10-15% (Current: ₹${entry.value})',
              style: const TextStyle(fontSize: 14),
              softWrap: true, // Allows text to wrap
            ),
          ),
        ],
      ),
    ),
  ),
  const SizedBox(height: 12),
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
                        'Limit ${entry.key} spending (Current: ₹${entry.value})',
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

  @override
  void dispose() {
    super.dispose();
  }
}