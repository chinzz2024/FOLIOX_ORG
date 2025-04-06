import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class RetireEarly extends StatefulWidget {
  const RetireEarly({super.key});

  @override
  State<RetireEarly> createState() => _RetireEarlyState();
}

class _RetireEarlyState extends State<RetireEarly> {
  bool _isLoading = true;
  String _retirementMessage = '';
  String _suggestions = '';
  double _totalRetirementNeed = 0;
  double _savings = 0;
  double _originalSavings = 0; // Track original savings before any allocation
  int _yearsToRetirement = 0;
  double _sipAmount = 0;
  double _previousSipAmount = 0; // Track previous investment amount
  double _requiredMonthlySIP = 0;
  double _projectedAmount = 0;
  double _monthlyExpenses = 0;
  final TextEditingController _investmentController = TextEditingController();
  final bool _showInvestmentInput = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    if (_currentUser == null) {
      setState(() {
        _isLoading = false;
        _retirementMessage = 'Please login to access this feature';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final totalEssentialExpenses = (data['totalEssentialExpenses'] as num?)?.toDouble() ?? 0;
        final totalOptionalExpenses = (data['totalOptionalExpenses'] as num?)?.toDouble() ?? 0;
        _savings = (data['savings'] as num?)?.toDouble() ?? 0;
        _originalSavings = _savings; // Store original savings
        _monthlyExpenses = totalEssentialExpenses + totalOptionalExpenses;

        // Get retirement goals
        if (data['goalsSelected'] is List) {
          for (var goal in data['goalsSelected']) {
            if (goal is Map && goal['goal'] == 'Retirement') {
              final currentAge = goal['currentAge'] ?? 0;
              final retirementAge = goal['retirementAge'] ?? 0;
              _yearsToRetirement = retirementAge - currentAge;
              break;
            }
          }
        }

        // Calculate retirement needs (20 years of expenses)
        final yearlyExpenses = _monthlyExpenses * 12;
        _totalRetirementNeed = yearlyExpenses * 20;

        // Calculate required monthly SIP to reach target
        _requiredMonthlySIP = _calculateRequiredMonthlySIP(_totalRetirementNeed, _yearsToRetirement);

        // Load existing retirement plan if available
        await _loadRetirementPlan();

        _investmentController.text = _sipAmount.toStringAsFixed(2);
        _projectedAmount = _calculateSIPReturns(_sipAmount, 12, _yearsToRetirement);

        // Calculate available savings after allocation
        _savings = _originalSavings - _sipAmount;

        _generateSuggestions();
        _updateRetirementMessage();
      } else {
        setState(() {
          _isLoading = false;
          _retirementMessage = 'No financial data found. Please complete your financial planning first.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _retirementMessage = 'Error fetching financial data: $e';
      });
    }
  }

  Future<void> _loadRetirementPlan() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid)
          .get();
          
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        
        if (data.containsKey('retirement')) {
          Map<String, dynamic> retirementData = data['retirement'];
          setState(() {
            _previousSipAmount = retirementData['monthlyTarget']?.toDouble() ?? 0;
            _sipAmount = _previousSipAmount;
          });
        }
      }
    } catch (e) {
      print('Error loading retirement plan: $e');
    }
  }

  void _generateSuggestions() {
    final double shortfall = _totalRetirementNeed - _projectedAmount;

    StringBuffer suggestions = StringBuffer();

    if (shortfall > 0) {
      suggestions.writeln('⚠️ You\'re currently projected to fall short by ₹${shortfall.toStringAsFixed(2)}');
      suggestions.writeln('\n💡 To reach your target, you should:');
      suggestions.writeln('- Invest ₹${_requiredMonthlySIP.toStringAsFixed(2)} monthly (currently ₹${_sipAmount.toStringAsFixed(2)})');
      suggestions.writeln('\n💰 Reduce your monthly expenses to save more');
    } else {
      suggestions.writeln('✅ You\'re on track to meet your retirement goal!');
    }

    setState(() {
      _suggestions = suggestions.toString();
    });
  }

  void _updateRetirementMessage() {
    setState(() {
      _retirementMessage = 'You need ₹${_totalRetirementNeed.toStringAsFixed(2)} for retirement '
          '(20 years of expenses).\n\n'
          'To achieve this within $_yearsToRetirement years, investing '
          '₹${_sipAmount.toStringAsFixed(2)} monthly in an SIP '
          'would grow to approximately ₹${_projectedAmount.toStringAsFixed(2)} '
          'at 12% annual return.';
      _isLoading = false;
    });
  }

  double _calculateRequiredMonthlySIP(double targetAmount, int years) {
    if (years <= 0 || targetAmount <= 0) return 0;
    
    double monthlyRate = 12 / 12 / 100;
    int months = years * 12;
    return (targetAmount * monthlyRate) / (pow(1 + monthlyRate, months) - 1);
  }

  double _calculateSIPReturns(double principal, double rate, int years) {
    if (years <= 0 || principal <= 0) return 0;
    
    double monthlyRate = rate / 12 / 100;
    int months = years * 12;
    return principal * (pow(1 + monthlyRate, months) - 1) / monthlyRate * (1 + monthlyRate);
  }

Future<void> _saveInvestment() async {
    if (_currentUser == null || _sipAmount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. First get current values from database
      DocumentSnapshot financialSnapshot = await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .get();
      
      DocumentSnapshot investmentSnapshot = await FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid)
          .get();

      double currentSavings = (financialSnapshot.data() as Map<String, dynamic>)['savings']?.toDouble() ?? 0;
      double oldMonthlyTarget = 0;
      
      if (investmentSnapshot.exists) {
        Map<String, dynamic> investmentData = investmentSnapshot.data() as Map<String, dynamic>;
        if (investmentData.containsKey('retirement')) {
          oldMonthlyTarget = investmentData['retirement']['monthlyTarget']?.toDouble() ?? 0;
        }
      }

      // 2. Calculate new savings amount
      double newSavings = (currentSavings + oldMonthlyTarget) - _sipAmount;

      // 3. Update both collections in a batch write
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      // Update investments collection
      DocumentReference investmentDoc = FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid);
      
      batch.set(investmentDoc, {
        'retirement': {
          'goal': 'Retirement',
          'monthlyTarget': _sipAmount,
          'targetAmount': _totalRetirementNeed,
          'yearsToRetirement': _yearsToRetirement,
          'lastUpdated': DateTime.now(),
        }
      }, SetOptions(merge: true));
      
      // Update financial planner with new savings
      DocumentReference financialDoc = FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid);
      
      batch.update(financialDoc, {
        'savings': newSavings,
      });
      
      await batch.commit();
      
      // 4. Update local state
      setState(() {
        _previousSipAmount = _sipAmount;
        _originalSavings = newSavings;
        _savings = newSavings;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retirement plan updated successfully')),
      );
      
      _updateRetirementMessage();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save plan: $e')),
      );
    }
  }

  void _updateProjection(String value) {
    final amount = double.tryParse(value) ?? 0;
    
    // Calculate maximum possible allocation
    double maxAllocation = _originalSavings + _previousSipAmount;
    
    if (amount > maxAllocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot allocate more than ₹${maxAllocation.toStringAsFixed(2)}')),
      );
      return;
    }

    setState(() {
      _sipAmount = amount;
      _projectedAmount = _calculateSIPReturns(_sipAmount, 12, _yearsToRetirement);
      // Calculate available after allocation
      _savings = (_originalSavings + _previousSipAmount) - _sipAmount;
      _generateSuggestions();
      _updateRetirementMessage();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement Planning', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                fontSize: 22,)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
       backgroundColor: Color(0xFF0F2027),
       centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Retirement Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(_retirementMessage, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(_suggestions, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Retirement Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            'Current Monthly Investment: ₹${_sipAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Original Savings: ₹${_originalSavings.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Available After Allocation: ₹${_savings.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _investmentController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'New Monthly Investment (₹)',
                              border: const OutlineInputBorder(),
                              suffixText: '₹',
                            ),
                            onChanged: _updateProjection,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _saveInvestment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Save Plan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _investmentController.dispose();
    super.dispose();
  }
}