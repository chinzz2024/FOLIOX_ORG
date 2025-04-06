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
  
  // Dynamic fields from database
  double _estimatedBudget = 0;
  int _targetYear = 0;
  double _allocatedAmount = 0;
  
  // Budget fields
  double _savings = 0;
  double _totalIncome = 0;
  double _totalEssentialExpenses = 0;
  double _totalOptionalExpenses = 0;
  
  // UI State
  bool _isLoading = true;
  String _errorMessage = '';
  String? _documentId;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (_currentUser == null) return;

      // Load budget data
      final budgetDoc = await _firestore
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .get();

      if (budgetDoc.exists) {
        setState(() {
          _savings = budgetDoc['savings']?.toDouble() ?? 0;
          _totalIncome = budgetDoc['totalIncome']?.toDouble() ?? 0;
          _totalEssentialExpenses = budgetDoc['totalEssentialExpenses']?.toDouble() ?? 0;
          _totalOptionalExpenses = budgetDoc['totalOptionalExpenses']?.toDouble() ?? 0;
        });
      }

      // Load marriage goal data
      final querySnapshot = await _firestore
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .collection('investments')
          .where('goal', isEqualTo: 'Marriage')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _documentId = doc.id;
          _estimatedBudget = doc['estimatedBudget']?.toDouble() ?? 0;
          _targetYear = doc['targetYear']?.toInt() ?? 0;
          _allocatedAmount = doc['allocatedAmount']?.toDouble() ?? 0;
          
          // Initialize controllers with database values
          _budgetController.text = _estimatedBudget.toStringAsFixed(2);
          _yearController.text = _targetYear.toString();
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

      // Get values from text controllers
      final newBudget = double.tryParse(_budgetController.text) ?? 0;
      final newYear = int.tryParse(_yearController.text) ?? 0;

      if (newBudget <= 0 || newYear <= 0) {
        throw Exception('Please enter valid budget and year values');
      }

      final marriageData = {
        'estimatedBudget': newBudget,
        'goal': 'Marriage',
        'targetYear': newYear,
        'allocatedAmount': _allocatedAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (_documentId == null) {
        await _firestore
            .collection('financialPlanner')
            .doc(_currentUser!.uid)
            .collection('investments')
            .add(marriageData);
      } else {
        await _firestore
            .collection('financialPlanner')
            .doc(_currentUser!.uid)
            .collection('investments')
            .doc(_documentId)
            .update(marriageData);
      }

      // Update local state
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
    final amount = double.tryParse(_depositController.text) ?? 0;
    if (amount <= 0 || amount > _savings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount within your savings')),
      );
      return;
    }

    try {
      // Update budget document
      await _firestore
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .update({
            'savings': _savings - amount,
          });

      // Update marriage goal
      await _firestore
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .collection('investments')
          .doc(_documentId)
          .update({
            'allocatedAmount': _allocatedAmount + amount,
          });

      setState(() {
        _allocatedAmount += amount;
        _savings -= amount;
        _depositController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funds allocated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error allocating funds: ${e.toString()}')),
      );
    }
  }

  double _calculateFutureValue() {
    const double inflationRate = 0.07; // 7% inflation
    return _estimatedBudget * pow(1 + inflationRate, _targetYear);
  }

  @override
  Widget build(BuildContext context) {
    final futureValue = _calculateFutureValue();
    final availableSavings = _savings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marriage Goal Planner',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                fontSize: 22,)),
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back,color: Colors.white,)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGoalData,
          
          ),
        ],
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
                              _buildDetailRow('Total Income', '₹${_totalIncome.toStringAsFixed(2)}'),
                              _buildDetailRow('Essential Expenses', '₹${_totalEssentialExpenses.toStringAsFixed(2)}'),
                              _buildDetailRow('Optional Expenses', '₹${_totalOptionalExpenses.toStringAsFixed(2)}'),
                              const Divider(),
                              _buildDetailRow(
                                'Available Savings',
                                '₹${availableSavings.toStringAsFixed(2)}',
                                isHighlighted: true,
                              ),
                              _buildDetailRow('Allocated to Marriage', '₹${_allocatedAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Goal Input Section
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Set Your Marriage Goal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _budgetController,
                                decoration: const InputDecoration(
                                  labelText: 'Estimated Budget (₹)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _yearController,
                                decoration: const InputDecoration(
                                  labelText: 'Target Years',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Fund Allocation
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
                                  labelText: 'Amount to Deposit (₹)',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.currency_rupee),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: _allocateFunds,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              if (availableSavings > 0)
                                Text(
                                  'Available: ₹${availableSavings.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

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
                                '₹${_estimatedBudget.toStringAsFixed(2)}',
                              ),
                              _buildDetailRow(
                                'Future Value',
                                '₹${futureValue.toStringAsFixed(2)}',
                                isHighlighted: true,
                              ),
                              _buildDetailRow(
                                'After',
                                '$_targetYear years',
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: (_allocatedAmount / _estimatedBudget).clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Funded: ${(_allocatedAmount / _estimatedBudget * 100).toStringAsFixed(1)}%',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
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