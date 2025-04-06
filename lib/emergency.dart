import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyFund extends StatefulWidget {
  const EmergencyFund({super.key});

  @override
  State<EmergencyFund> createState() => _EmergencyFundState();
}

class _EmergencyFundState extends State<EmergencyFund> {
  String? _displayMessage;
  double _totalEssentialExpenses = 0.0;
  double _totalOptionalExpenses = 0.0;
  double _targetEmergencyFund = 0.0;
  double _currentSavings = 0.0;
  double _recommendedMonthlyInvestment = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _displayMessage = 'Please log in to view financial information.';
        });
        return;
      }

      // Fetch financial planner data
      DocumentSnapshot financialDoc = await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(currentUser.uid)
          .get();

      if (financialDoc.exists) {
        Map<String, dynamic> data = financialDoc.data() as Map<String, dynamic>;

        setState(() {
          // Calculate total essential expenses
          Map<String, dynamic> essentialExpenses = data['essentialExpenses'] ?? {};
          _totalEssentialExpenses = essentialExpenses.values.fold(
            0.0, 
            (sum, value) => sum + (value as num).toDouble()
          );

          // Calculate total optional expenses
          Map<String, dynamic> optionalExpenses = data['optionalExpenses'] ?? {};
          _totalOptionalExpenses = optionalExpenses.values.fold(
            0.0, 
            (sum, value) => sum + (value as num).toDouble()
          );

          // Calculate target emergency fund (6 months of total expenses)
          _targetEmergencyFund = (_totalEssentialExpenses + _totalOptionalExpenses) * 6;

          // Calculate current savings (assuming savings field exists)
          _currentSavings = (data['savings'] as num?)?.toDouble() ?? 0.0;

          // Recommend investing 20% of current savings monthly
          _recommendedMonthlyInvestment = _currentSavings * 0.2;

          // Prepare display message
          _displayMessage = _prepareRecommendationMessage();
        });
      } else {
        setState(() {
          _displayMessage = 'No financial data found. Please update your profile.';
        });
      }
    } catch (e) {
      setState(() {
        _displayMessage = 'Error fetching financial data: ${e.toString()}';
      });
    }
  }

  String _prepareRecommendationMessage() {
    return '''
Emergency Fund Analysis:
• Total Monthly Essential Expenses: ₹${_totalEssentialExpenses.toStringAsFixed(2)}
• Total Monthly Optional Expenses: ₹${_totalOptionalExpenses.toStringAsFixed(2)}
• Total Monthly Expenses: ₹${(_totalEssentialExpenses + _totalOptionalExpenses).toStringAsFixed(2)}
• Target Emergency Fund (6 months): ₹${_targetEmergencyFund.toStringAsFixed(2)}
• Current Savings: ₹${_currentSavings.toStringAsFixed(2)}
• Recommended Monthly Investment: ₹${_recommendedMonthlyInvestment.toStringAsFixed(2)}

Recommendation: 
- We recommend investing 20% of your current savings (₹${_recommendedMonthlyInvestment.toStringAsFixed(2)}) monthly into your emergency fund.
- Continue until you reach the target emergency fund of ₹${_targetEmergencyFund.toStringAsFixed(2)}.
- This will help you build a robust financial safety net covering 6 months of total expenses.
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Fund Planner', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                fontSize: 22,)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF0F2027),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Fund Strategy:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_displayMessage != null)
                Text(
                  _displayMessage!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}