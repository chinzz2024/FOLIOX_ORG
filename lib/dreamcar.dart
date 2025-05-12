import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DreamcarPage extends StatefulWidget {
  const DreamcarPage({super.key});

  @override
  _DreamcarPageState createState() => _DreamcarPageState();
}

class _DreamcarPageState extends State<DreamcarPage> {
  bool isEMISelected = false;
  double emi = 0.0;
  double monthlySavings = 0.0;
  String savingsRecommendation = '';
 double _totalInvested = 0.0;
List<Map<String, dynamic>> _investmentHistory = [];
bool _isLoading = true;
String _errorMessage = '';
  double totalSavings = 0.0;
  late final TextEditingController targetAmountController;
  late final TextEditingController yearsController;
  late final TextEditingController loanAmountController;
  late final TextEditingController interestController;
  late final TextEditingController tenureController;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    targetAmountController = TextEditingController();
    yearsController = TextEditingController();
    loanAmountController = TextEditingController(text: "500000");
    interestController = TextEditingController(text: "8");
    tenureController = TextEditingController(text: "5");

    if (_currentUser != null) {
      _fetchFinancialData();
    } else {
      _isLoading = false;
      _errorMessage = 'Please log in to access this feature';
    }

    targetAmountController.addListener(_scheduleSavingsCalculation);
    yearsController.addListener(_scheduleSavingsCalculation);
  }
   Future<void> _fetchFinancialData() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Get financial data (unchanged)
      DocumentSnapshot financialSnapshot = await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .get();

      if (!mounted) return;

      if (financialSnapshot.exists) {
        Map<String, dynamic>? data = financialSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            totalSavings = (data['savings'] ?? 0).toDouble();
          });
        }
      }

      // 2. Load investments with nested structure
      await _loadInvestments();

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load financial data: ${e.toString()}';
        totalSavings = 0.0;
      });
    }
  }


Future<void> _loadInvestments() async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('investments')
        .doc(_currentUser!.uid)
        .get();
        
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      
      // Access nested dreamCar data
      if (data.containsKey('dreamCar')) {
        Map<String, dynamic> dreamCarData = data['dreamCar'];
        setState(() {
          _totalInvested = dreamCarData['totalInvested']?.toDouble() ?? 0.0;
          // Initialize controllers with existing values if available
          targetAmountController.text = (dreamCarData['targetAmount']?.toString() ?? '500000');
          // Removed progress calculation
        });
      }
      
      // Load investment history (unchanged)
      QuerySnapshot history = await FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid)
          .collection('history')
          .orderBy('date', descending: true)
          .get();
          
      setState(() {
        _investmentHistory = history.docs.map((doc) {
          return {
            'amount': doc['amount'],
            'date': (doc['date'] as Timestamp).toDate(),
          };
        }).toList();
      });
    }
  } catch (e) {
    print('Error loading investments: $e');
  }
}

 Future<double> _getDreamCarAllocation() async {
    if (_currentUser == null) return 0.0;
    
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid)
          .get();
          
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('dreamCar')) {
          return data['dreamCar']['monthlyTarget']?.toDouble() ?? 0.0;
        }
      }
    } catch (e) {
      print('Error getting dream car allocation: $e');
    }
    return 0.0;
  }

Future<void> _startMonthlyInvestment(double amount) async {
    if (_currentUser == null) return;

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
        if (investmentData.containsKey('dreamCar')) {
          oldMonthlyTarget = investmentData['dreamCar']['monthlyTarget']?.toDouble() ?? 0;
        }
      }

      // 2. Calculate new savings amount
      double newSavings = (currentSavings + oldMonthlyTarget) - amount;

      // 3. Update both collections in a batch write
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      // Update investments collection
      DocumentReference investmentDoc = FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid);
      
      batch.set(investmentDoc, {
        'dreamCar': {
          'goal': 'DreamCar',
          'totalInvested': FieldValue.increment(amount),
          'monthlyTarget': amount, // Store the new allocation amount
          'targetAmount': double.tryParse(targetAmountController.text),
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
        _totalInvested += amount;
        totalSavings = newSavings;
        _isLoading = false;
        
        _investmentHistory.insert(0, {
          'amount': amount,
          'date': DateTime.now(),
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('₹${amount.toStringAsFixed(2)} allocated to Dream Car')),
      );
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Allocation failed: ${e.toString()}')),
      );
    }
  }


  void _scheduleSavingsCalculation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateMonthlySavings();
    });
  }

  double calculateSIPReturns(double principal, double rate, int years) {
    double monthlyRate = rate / 12 / 100;
    int months = years * 12;
    double futureValue = principal * (pow(1 + monthlyRate, months) - 1) / monthlyRate * (1 + monthlyRate);
    return futureValue;
  }

void calculateMonthlySavings() {
  double targetAmount = double.tryParse(targetAmountController.text) ?? 0;
  int years = int.tryParse(yearsController.text) ?? 0;

  if (years > 0 && targetAmount > 0) {
    // Calculate required monthly SIP to reach target in given years at 12% return
    double monthlyRate = 12 / 12 / 100; // 12% annual return
    int months = years * 12;
    
    // Formula: P = (FV * r) / [(1+r)^n - 1]
    double requiredMonthlySIP = (targetAmount * monthlyRate) / 
        (pow(1 + monthlyRate, months) - 1);
    
    setState(() {
      monthlySavings = requiredMonthlySIP;
      savingsRecommendation = '''
Savings Plan:

- Target Amount: ₹${targetAmount.toStringAsFixed(2)}
- Time Frame: $years years
- Required Monthly SIP: ₹${requiredMonthlySIP.toStringAsFixed(2)} at 12% return
''';
    });
  } else {
    setState(() {
      monthlySavings = 0;
      savingsRecommendation = '';
    });
  }
}
  void showEMICalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: EMICalculator(
            onEMICalculated: (calculatedEMI) {
              setState(() {
                emi = calculatedEMI;
                isEMISelected = true;
              });
            },
            loanAmountController: loanAmountController,
            interestController: interestController,
            tenureController: tenureController,
          ),
        );
      },
    );
  }



  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
        ),
      ),
    );
  }

  Future<void> _allocateSavingsToGoal() async {
    try {
      await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .update({
            'goalsSelected': FieldValue.arrayUnion([
              {
                'goal': 'Dream Car',
                'targetAmount': double.tryParse(targetAmountController.text) ?? 0,
                'targetYears': int.tryParse(yearsController.text) ?? 0,
                'allocatedAmount': totalSavings * 0.2,
                'monthlySavingsNeeded': monthlySavings,
                'createdAt': DateTime.now(),
              }
            ])
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully allocated savings to Dream Car goal')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to allocate savings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dream Car Calculator', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color.fromARGB(255, 12, 6, 37),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Please log in to access this feature'),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dream Car Calculator', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color.fromARGB(255, 12, 6, 37),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Car ', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                fontSize: 22,)),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
        centerTitle: true,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.white),
  onPressed: () {
    // Return true if investments were made, false otherwise
    Navigator.pop(context, _totalInvested > 0);
  },
),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Financial Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Financial Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Savings:'),
                        Text('₹${totalSavings.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
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
                const Text('Current Dream Car Allocation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                FutureBuilder<double>(
                  future: _getDreamCarAllocation(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final allocation = snapshot.data ?? 0.0;
                    return Column(
                      children: [
                        Text(
                          'Monthly Allocation: ₹${allocation.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                       
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

   

            // Purchase Method Selection
            const Text('How do you want to buy your car?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEMISelected = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isEMISelected ? Colors.blue : Colors.grey[300],
                      foregroundColor: !isEMISelected ? Colors.white : Colors.black,
                    ),
                    child: const Text('Ready Cash'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: showEMICalculator,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEMISelected ? Colors.blue : Colors.grey[300],
                      foregroundColor: isEMISelected ? Colors.white : Colors.black,
                    ),
                    child: const Text('EMI'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ready Cash Calculator
            if (!isEMISelected) ...[
              const Text('Ready Cash Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              buildTextField('Target Amount (₹)', targetAmountController),
              const SizedBox(height: 10),
              buildTextField('Years to Goal', yearsController),
              const SizedBox(height: 20),
              
              const SizedBox(height: 20),

           if (savingsRecommendation.isNotEmpty) ...[
  Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Savings Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(savingsRecommendation),
          const SizedBox(height: 20),

         
        ElevatedButton(
  onPressed: () {
    _startMonthlyInvestment(monthlySavings);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
  ),
  child: Text('Allocate ₹${monthlySavings.toStringAsFixed(2)} Monthly'),
),
          const SizedBox(height: 10),
          const Text('Note: Progress will update as you make investments',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  ),
],
            ],
            // EMI Details
            if (isEMISelected && emi > 0) ...[
              const SizedBox(height: 20),
              const Text('EMI Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Loan Amount:'),
                          Text('₹${loanAmountController.text}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Interest Rate:'),
                          Text('${interestController.text}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tenure:'),
                          Text('${tenureController.text} years'),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monthly EMI:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₹${emi.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                       
                        
                      
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveEMIPlan() async {
    try {
      await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .update({
            'goalsSelected': FieldValue.arrayUnion([
              {
                'goal': 'Dream Car (EMI)',
                'loanAmount': double.tryParse(loanAmountController.text) ?? 0,
                'interestRate': double.tryParse(interestController.text) ?? 0,
                'tenure': int.tryParse(tenureController.text) ?? 0,
                'monthlyEMI': emi,
                'createdAt': DateTime.now(),
              }
            ])
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EMI plan saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save EMI plan: $e')),
      );
    }
  }
}

class EMICalculator extends StatefulWidget {
  final Function(double) onEMICalculated;
  final TextEditingController loanAmountController;
  final TextEditingController interestController;
  final TextEditingController tenureController;

  const EMICalculator({
    super.key,
    required this.onEMICalculated,
    required this.loanAmountController,
    required this.interestController,
    required this.tenureController,
  });

  @override
  _EMICalculatorState createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;

  @override
  void initState() {
    super.initState();
    widget.loanAmountController.addListener(_scheduleEMICalculation);
    widget.interestController.addListener(_scheduleEMICalculation);
    widget.tenureController.addListener(_scheduleEMICalculation);
    WidgetsBinding.instance.addPostFrameCallback((_) => calculateEMI());
  }

  @override
  void dispose() {
    widget.loanAmountController.removeListener(_scheduleEMICalculation);
    widget.interestController.removeListener(_scheduleEMICalculation);
    widget.tenureController.removeListener(_scheduleEMICalculation);
    super.dispose();
  }

  void _scheduleEMICalculation() {
    WidgetsBinding.instance.addPostFrameCallback((_) => calculateEMI());
  }

  void calculateEMI() {
    double loanAmount = double.tryParse(widget.loanAmountController.text) ?? 0;
    double interestRate = double.tryParse(widget.interestController.text) ?? 0;
    int tenureYears = int.tryParse(widget.tenureController.text) ?? 0;
    int tenureMonths = tenureYears * 12;

    if (interestRate > 0 && tenureMonths > 0) {
      double monthlyInterestRate = interestRate / 12 / 100;
      emi = (loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, tenureMonths)) /
          (pow(1 + monthlyInterestRate, tenureMonths) - 1);
      totalPayment = emi * tenureMonths;
      totalInterest = totalPayment - loanAmount;
    } else {
      emi = loanAmount / tenureMonths;
      totalPayment = loanAmount;
      totalInterest = 0;
    }

    setState(() {});
    widget.onEMICalculated(emi);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('EMI Calculator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: widget.loanAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Loan Amount (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.interestController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Interest Rate (%)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.tenureController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tenure (Years)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              calculateEMI();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Calculate EMI'),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly EMI:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹${emi.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Interest:'),
                      Text('₹${totalInterest.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payment:'),
                      Text('₹${totalPayment.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}