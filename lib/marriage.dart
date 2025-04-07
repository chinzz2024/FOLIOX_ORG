import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class MarriageGoalPage extends StatefulWidget {
  @override
  _MarriageGoalPageState createState() => _MarriageGoalPageState();
}

class _MarriageGoalPageState extends State<MarriageGoalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  double? _sipProjection;

  // Dynamic fields from database (now using int for monetary values)
  int _estimatedBudget = 0;
  int _targetYear = 0;
  int _allocatedAmount = 0;
  
  // Budget fields (now using int)
  int _savings = 0;
  int _totalIncome = 0;
  int _totalEssentialExpenses = 0;
  int _totalOptionalExpenses = 0;
  
  // UI State
  bool _isLoading = true;
  String _errorMessage = '';
  String? _documentId;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final List<Map<String, dynamic>> _sipOptions = [
  {
    'name': 'Axis Bluechip Fund',
    'category': 'Large Cap',
    'returns': '12.5%',
    'minSip': 500,
    'risk': 'Moderate',
  },
  {
    'name': 'Mirae Asset Large Cap Fund',
    'category': 'Large Cap',
    'returns': '12.2%',
    'minSip': 1000,
    'risk': 'Moderate',
  },
  {
    'name': 'SBI Small Cap Fund',
    'category': 'Small Cap',
    'returns': '13.1%',
    'minSip': 500,
    'risk': 'High',
  },
  {
    'name': 'HDFC Balanced Advantage Fund',
    'category': 'Hybrid',
    'returns': '11.8%',
    'minSip': 1000,
    'risk': 'Moderately High',
  },
  {
    'name': 'ICICI Prudential Equity & Debt Fund',
    'category': 'Aggressive Hybrid',
    'returns': '12.3%',
    'minSip': 1000,
    'risk': 'Moderate',
  },
];

 @override
void initState() {
  super.initState();
  _currentUser = _auth.currentUser;
  _depositController.addListener(_updateSipProjection);
  _loadData();
}

void _updateSipProjection() {
  if (_depositController.text.isEmpty) {
    setState(() {
      _sipProjection = null;
    });
    return;
  }

  final amount = int.tryParse(_depositController.text) ?? 0;
  
  if (amount <= 0 || _targetYear <= 0) {
    setState(() {
      _sipProjection = null;
    });
    return;
  }

  if (amount > _savings) {
    setState(() {
      _sipProjection = null;
    });
    return;
  }

  final projection = _calculateSipProjection(amount, _targetYear);
  setState(() {
    _sipProjection = projection;
  });
}

Future<void> _loadData() async {
  try {
    if (_currentUser == null) return;

    // 1. Load budget data from financialPlanner
    final budgetDoc = await _firestore
        .collection('financialPlanner')
        .doc(_currentUser!.uid)
        .get();

    if (budgetDoc.exists) {
      setState(() {
        _savings = (budgetDoc['savings']?.toDouble() ?? 0).round();
        _totalIncome = (budgetDoc['totalIncome']?.toDouble() ?? 0).round();
        _totalEssentialExpenses = (budgetDoc['totalEssentialExpenses']?.toDouble() ?? 0).round();
        _totalOptionalExpenses = (budgetDoc['totalOptionalExpenses']?.toDouble() ?? 0).round();
        
        // Get initial goal data from financialPlanner
        final goals = budgetDoc['goalsSelected'] as List<dynamic>? ?? [];
        final marriageGoal = goals.firstWhere(
          (g) => g['goal'] == 'Marriage',
          orElse: () => null,
        );
        
        if (marriageGoal != null) {
          _estimatedBudget = (marriageGoal['estimatedBudget']?.toDouble() ?? 0).round();
          _targetYear = marriageGoal['targetYear']?.toInt() ?? 5;
          _budgetController.text = _estimatedBudget.toString();
          _yearController.text = _targetYear.toString();
        }
      });
    }

    // 2. Load investment tracking data from investments collection
    final investmentDoc = await _firestore
        .collection('investments')
        .doc('${_currentUser!.uid}_Marriage')
        .get();

    if (investmentDoc.exists) {
      setState(() {
        _allocatedAmount = (investmentDoc['totalInvested']?.toDouble() ?? 0).round();
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _saveGoalData() async {
  try {
    if (_currentUser == null) return;

    final newBudget = int.tryParse(_budgetController.text) ?? 0;
    final newYear = int.tryParse(_yearController.text) ?? 0;

    if (newBudget <= 0 || newYear <= 0) {
      throw Exception('Please enter valid budget and year values');
    }

    // 1. Update in financialPlanner goalsSelected array
    final mainDocRef = _firestore.collection('financialPlanner').doc(_currentUser!.uid);
    final mainDoc = await mainDocRef.get();
    final goalsList = mainDoc['goalsSelected'] as List<dynamic>? ?? [];

    int marriageIndex = goalsList.indexWhere((g) => g['goal'] == 'Marriage');
    final marriageData = {
      'goal': 'Marriage',
      'estimatedBudget': newBudget,
      'targetYear': newYear,
    };

    if (marriageIndex >= 0) {
      goalsList[marriageIndex] = marriageData;
    } else {
      goalsList.add(marriageData);
    }

    await mainDocRef.update({
      'goalsSelected': goalsList,
    });

    // 2. Initialize investment tracking if doesn't exist
    await _firestore
        .collection('investments')
        .doc('${_currentUser!.uid}_Marriage')
        .set({
          'goal': 'Marriage',
          'targetAmount': newBudget,
          'totalInvested': _allocatedAmount,
          'monthlyTarget': newBudget / (newYear * 12),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    setState(() {
      _estimatedBudget = newBudget;
      _targetYear = newYear;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marriage goal saved successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

Future<void> _allocateFunds() async {
  final newAllocation = int.tryParse(_depositController.text) ?? 0;
  
  if (newAllocation <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid positive amount')),
    );
    return;
  }

  try {
    // Calculate the new savings amount
    final currentSavings = _savings;
    final previousAllocation = _allocatedAmount;
    final newSavings = (currentSavings + previousAllocation) - newAllocation;
    
    if (newSavings < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allocation amount exceeds available funds')),
      );
      return;
    }

    // 1. Update savings in financialPlanner
    await _firestore
        .collection('financialPlanner')
        .doc(_currentUser!.uid)
        .update({
          'savings': newSavings,
        });

    // 2. Update investments collection
    final monthsRemaining = _targetYear * 12;
    final remainingAmount = _estimatedBudget - newAllocation;
    final monthlyTarget = remainingAmount > 0 ? remainingAmount / monthsRemaining : 0;

    await _firestore
        .collection('investments')
        .doc('${_currentUser!.uid}_Marriage')
        .set({
          'goal': 'Marriage',
          'targetAmount': _estimatedBudget,
          'totalInvested': newAllocation,
          'monthlyTarget': monthlyTarget,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    setState(() {
      _allocatedAmount = newAllocation;
      _savings = newSavings;
      _depositController.clear();
      _sipProjection = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Allocation updated successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating allocation: ${e.toString()}')),
    );
  }
}
  int _calculateFutureValue() {
    const double inflationRate = 0.07; // 7% inflation
    return (_estimatedBudget * pow(1 + inflationRate, _targetYear)).round();
  }

double _calculateSipProjection(int monthlyInvestment, int years) {
  const double annualReturn = 0.12; // 12% annual return
  const double monthlyReturn = annualReturn / 12; // ~1% monthly return
  final int numberOfMonths = years * 12;
  
  // SIP future value formula: FV = P * [(1 + r)^n - 1] / r
  final double futureValue = monthlyInvestment * 
      ((pow(1 + monthlyReturn, numberOfMonths) - 1) / monthlyReturn);
  
  return futureValue;
}
  @override
  Widget build(BuildContext context) {
    final futureValue = _calculateFutureValue();
    final availableSavings = _savings;
    final fundedPercentage = _estimatedBudget > 0 
        ? (_allocatedAmount / _estimatedBudget * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marriage Goal Planner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
        backgroundColor: Color(0xFF0F2027),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget Overview
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Budget Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow('Total Income', '₹$_totalIncome'),
                              _buildDetailRow('Essential Expenses', '₹$_totalEssentialExpenses'),
                              _buildDetailRow('Optional Expenses', '₹$_totalOptionalExpenses'),
                              const Divider(),
                              _buildDetailRow(
                                'Available Savings',
                                '₹$availableSavings',
                                isHighlighted: true,
                              ),
                              _buildDetailRow('Allocated to Marriage', '₹$_allocatedAmount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                     

 // Inside your build method, modify the Allocate Funds Card:
Card(
  elevation: 4,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allocate Funds',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _depositController,
          decoration: InputDecoration(
            labelText: 'Monthly SIP Amount (₹)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.currency_rupee),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check),
              onPressed: _allocateFunds,
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _updateSipProjection(),
        ),
        const SizedBox(height: 10),
        if (_savings > 0)
          Text(
            'Available: ₹$_savings',
            style: const TextStyle(color: Colors.grey),
          ),
        
        // SIP Projection Section
        if (_sipProjection != null && _depositController.text.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'SIP Projection (12% annual return)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                'Monthly Investment',
                '₹${_depositController.text}',
              ),
              _buildDetailRow(
                'Projected Value in $_targetYear years',
                '₹${_sipProjection!.round()}',
                isHighlighted: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Recommended SIP Options (12% returns)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ..._sipOptions.map((option) => _buildSipOptionCard(option)).toList(),
            ],
          ),
      ],
    ),
  ),
),

                      // Projection Section
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inflation Projection (7%)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow(
                                'Current Target',
                                '₹$_estimatedBudget',
                              ),
                              _buildDetailRow(
                                'Future Value',
                                '₹$futureValue',
                                isHighlighted: true,
                              ),
                              _buildDetailRow(
                                'After',
                                '$_targetYear years',
                              ),
                              const SizedBox(height: 10),
                             
                              const SizedBox(height: 5),
                             
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
Widget _buildSipOptionCard(Map<String, dynamic> option) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Chip(
                label: Text(option['returns']),
                backgroundColor: Colors.green[100],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('Category: ${option['category']}'),
          Text('Risk: ${option['risk']}'),
          Text('Min SIP: ₹${option['minSip']}'),
          const SizedBox(height: 10),
          
        ],
      ),
    ),
  );
}

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _yearController.dispose();
    _depositController.dispose();
    super.dispose();
  }
}