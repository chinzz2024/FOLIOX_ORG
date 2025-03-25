import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculation_page.dart';
import 'summary_page.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  // Controllers for all fields
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController dearnessAllowanceController =
      TextEditingController();
  final TextEditingController houseRentAllowanceController =
      TextEditingController();
  final TextEditingController transportAllowanceController =
      TextEditingController();

  // Essential Expenses
  final TextEditingController rentMortgageController = TextEditingController();
  final TextEditingController foodGroceriesController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController medicalExpensesController =
      TextEditingController();
  final TextEditingController loanRepaymentsController =
      TextEditingController();

  // Optional Expenses
  final TextEditingController diningOutController = TextEditingController();
  final TextEditingController entertainmentController = TextEditingController();
  final TextEditingController travelVacationsController =
      TextEditingController();
  final TextEditingController shoppingController = TextEditingController();
  final TextEditingController fitnessGymController = TextEditingController();
  final TextEditingController hobbiesLeisureController =
      TextEditingController();

  // Assets
  final TextEditingController fixedDepositsController = TextEditingController();
  final TextEditingController recurringDepositsController =
      TextEditingController();
  final TextEditingController savingsAccountController =
      TextEditingController();
  final TextEditingController currentAccountController =
      TextEditingController();
  final TextEditingController employeeProvidentFundController =
      TextEditingController();
  final TextEditingController publicProvidentFundController =
      TextEditingController();

  // Goals
  final List<String> availableGoals = [
    'Retirement',
    'Dream Car',
    'Dream Home',
    'Marriage',
    'Emergency Fund',
  ];
  final Map<String, TextEditingController> retirementControllers = {
    'currentAge': TextEditingController(),
    'retirementAge': TextEditingController(),
  };

  List<Map<String, dynamic>> selectedGoals = [];
  final Map<String, TextEditingController> goalBudgetControllers = {};
  final Map<String, TextEditingController> goalYearsControllers = {};

  @override
  void dispose() {
    // Dispose all controllers
    baseSalaryController.dispose();
    dearnessAllowanceController.dispose();
    houseRentAllowanceController.dispose();
    transportAllowanceController.dispose();
    rentMortgageController.dispose();
    foodGroceriesController.dispose();
    insuranceController.dispose();
    medicalExpensesController.dispose();
    loanRepaymentsController.dispose();
    diningOutController.dispose();
    entertainmentController.dispose();
    travelVacationsController.dispose();
    shoppingController.dispose();
    fitnessGymController.dispose();
    hobbiesLeisureController.dispose();
    fixedDepositsController.dispose();
    recurringDepositsController.dispose();
    savingsAccountController.dispose();
    currentAccountController.dispose();
    employeeProvidentFundController.dispose();
    publicProvidentFundController.dispose();

    // Dispose goal controllers
    for (var controller in goalBudgetControllers.values) {
      controller.dispose();
    }
    for (var controller in goalYearsControllers.values) {
      controller.dispose();
    }

    for (var controller in retirementControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _addNewGoal() {
    setState(() {
      // Add a new goal with empty selection
      selectedGoals.add({'goal': null});
    });
  }

  void _removeGoal(int index) {
    setState(() {
      // Make sure index is valid
      if (index < 0 || index >= selectedGoals.length) return;

      // Remove controllers for this goal
      final goalData = selectedGoals[index];
      final String? goal = goalData['goal'] as String?;
      if (goal != null) {
        // Only remove controllers if they exist
        if (goalBudgetControllers.containsKey(goal)) {
          goalBudgetControllers[goal]?.dispose();
          goalBudgetControllers.remove(goal);
        }
        if (goalYearsControllers.containsKey(goal)) {
          goalYearsControllers[goal]?.dispose();
          goalYearsControllers.remove(goal);
        }
      }

      // Remove the goal from the list
      selectedGoals.removeAt(index);
    });
  }

void _updateGoal(int index, String? newGoal) {
  setState(() {
    final oldGoal = selectedGoals[index]['goal'];

    if (oldGoal != null && oldGoal != newGoal) {
      // Preserve old goal data before removal
      String? oldBudget = goalBudgetControllers[oldGoal]?.text;
      String? oldYears = goalYearsControllers[oldGoal]?.text;
      String? oldCurrentAge = retirementControllers['currentAge']?.text;
      String? oldRetirementAge = retirementControllers['retirementAge']?.text;

      // Remove old goal controllers only if switching goals
      if (oldGoal != newGoal) {
        goalBudgetControllers.remove(oldGoal);
        goalYearsControllers.remove(oldGoal);
        retirementControllers.remove('currentAge');
        retirementControllers.remove('retirementAge');
      }

      // Assign the old values to the new goal if applicable
      if (newGoal != null) {
        if (newGoal == 'Retirement') {
          retirementControllers.putIfAbsent(
              'currentAge', () => TextEditingController(text: oldCurrentAge));
          retirementControllers.putIfAbsent(
              'retirementAge', () => TextEditingController(text: oldRetirementAge));
        } else if (newGoal != 'Dream Car' && 
                  newGoal != 'Dream Home' && 
                  newGoal != 'Emergency Fund') {
          goalBudgetControllers.putIfAbsent(
              newGoal, () => TextEditingController(text: oldBudget));
          goalYearsControllers.putIfAbsent(
              newGoal, () => TextEditingController(text: oldYears));
        }
      }
    }

    // Initialize controllers for new goals if they don't exist
    if (newGoal != null && 
        newGoal != 'Dream Car' && 
        newGoal != 'Dream Home' && 
        newGoal != 'Emergency Fund') {
      goalBudgetControllers.putIfAbsent(
          newGoal, () => TextEditingController());
      goalYearsControllers.putIfAbsent(
          newGoal, () => TextEditingController());
    }

    selectedGoals[index]['goal'] = newGoal;
  });
}

Future<void> _saveToFirestore() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('financialPlanner').doc(userId);

  try {
    // Step 1: Fetch existing Firestore data
    DocumentSnapshot userDoc = await userDocRef.get();
    Map<String, dynamic> existingData = userDoc.exists
        ? userDoc.data() as Map<String, dynamic>
        : {};

    // Step 2: Prepare updatedData map
    Map<String, dynamic> updatedData = {};

    // ✅ Income Details
    updatedData['incomeDetails'] = {
      'baseSalary': num.tryParse(baseSalaryController.text) ??
          existingData['incomeDetails']?['baseSalary'] ??
          0,
      'dearnessAllowance': num.tryParse(dearnessAllowanceController.text) ??
          existingData['incomeDetails']?['dearnessAllowance'] ??
          0,
      'houseRentAllowance': num.tryParse(houseRentAllowanceController.text) ??
          existingData['incomeDetails']?['houseRentAllowance'] ??
          0,
      'transportAllowance': num.tryParse(transportAllowanceController.text) ??
          existingData['incomeDetails']?['transportAllowance'] ??
          0,
    };

    // ✅ Essential Expenses
    updatedData['essentialExpenses'] = {
      'rentMortgage': num.tryParse(rentMortgageController.text) ??
          existingData['essentialExpenses']?['rentMortgage'] ??
          0,
      'foodGroceries': num.tryParse(foodGroceriesController.text) ??
          existingData['essentialExpenses']?['foodGroceries'] ??
          0,
      'insurance': num.tryParse(insuranceController.text) ??
          existingData['essentialExpenses']?['insurance'] ??
          0,
      'medicalExpenses': num.tryParse(medicalExpensesController.text) ??
          existingData['essentialExpenses']?['medicalExpenses'] ??
          0,
      'loanRepayments': num.tryParse(loanRepaymentsController.text) ??
          existingData['essentialExpenses']?['loanRepayments'] ??
          0,
    };

    // ✅ Optional Expenses
    updatedData['optionalExpenses'] = {
      'diningOut': num.tryParse(diningOutController.text) ??
          existingData['optionalExpenses']?['diningOut'] ??
          0,
      'entertainment': num.tryParse(entertainmentController.text) ??
          existingData['optionalExpenses']?['entertainment'] ??
          0,
      'travelVacations': num.tryParse(travelVacationsController.text) ??
          existingData['optionalExpenses']?['travelVacations'] ??
          0,
      'shopping': num.tryParse(shoppingController.text) ??
          existingData['optionalExpenses']?['shopping'] ??
          0,
      'fitnessGym': num.tryParse(fitnessGymController.text) ??
          existingData['optionalExpenses']?['fitnessGym'] ??
          0,
      'hobbiesLeisure': num.tryParse(hobbiesLeisureController.text) ??
          existingData['optionalExpenses']?['hobbiesLeisure'] ??
          0,
    };
// ✅ Goals Processing
List<Map<String, dynamic>> goalsList = selectedGoals.map<Map<String, dynamic>>((goalData) {
  if (goalData is! Map<String, dynamic>) return {};
  final goal = goalData['goal'];

  if (goal == "Dream Car" || goal == "Dream Home" || goal == "Emergency Fund") {
    return {'goal': goal};
  } else if (goal == "Retirement") {
    return {
      'goal': goal,
      'currentAge': int.tryParse(retirementControllers['currentAge']?.text ?? '') ?? 
          (goalData['currentAge'] ?? null),
      'retirementAge': int.tryParse(retirementControllers['retirementAge']?.text ?? '') ?? 
          (goalData['retirementAge'] ?? null),
    };
  } else if (goal == "Marriage") {
    return {
      'goal': goal,
      'estimatedBudget': double.tryParse(goalBudgetControllers[goal]?.text ?? '') ?? 
          (goalData['estimatedBudget'] ?? null),
      'targetYear': int.tryParse(goalYearsControllers[goal]?.text ?? '') ?? 
          (goalData['targetYear'] ?? null),
    };
  }
  return {};
}).toList();

if (goalsList.isNotEmpty) {
  updatedData['goalsSelected'] = goalsList;
}

    // Step 3: Update Firestore first (to store the new values)
    await userDocRef.set(updatedData, SetOptions(merge: true));

    // Step 4: Fetch the latest document to ensure updated values
    userDoc = await userDocRef.get();
    Map<String, dynamic> completeData = userDoc.exists
        ? userDoc.data() as Map<String, dynamic>
        : {};

    // Step 5: Calculate totals using updated data
    num totalIncome = _calculateCategoryTotal(completeData['incomeDetails'] ?? {});
    num totalEssentialExpenses = _calculateCategoryTotal(completeData['essentialExpenses'] ?? {});
    num totalOptionalExpenses = _calculateCategoryTotal(completeData['optionalExpenses'] ?? {});
    num totalSavings = totalIncome - (totalEssentialExpenses + totalOptionalExpenses);

    // Step 6: Save calculated values back to Firestore
    await userDocRef.update({
      'totalIncome': totalIncome,
      'totalEssentialExpenses': totalEssentialExpenses,
      'totalOptionalExpenses': totalOptionalExpenses,
      'savings': totalSavings,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save data: $error')),
    );
  }
}

// 🔥 **Fix: Ensure Only `num` Values are Summed**
double _calculateCategoryTotal(Map<String, dynamic> category) {
  return category.values.fold(0.0, (sum, value) {
    if (value is num) return sum + value;
    return sum;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalsSection(),
            _buildSection('Income Details', [
              _buildTextField('Base Salary', baseSalaryController),
              _buildTextField(
                  'Dearness Allowance', dearnessAllowanceController),
              _buildTextField(
                  'House Rent Allowance (HRA)', houseRentAllowanceController),
              _buildTextField(
                  'Transport Allowance', transportAllowanceController),
            ]),
            _buildSection('Essential Expenses', [
              _buildTextField('Rent/Mortgage', rentMortgageController),
              _buildTextField('Food & Groceries', foodGroceriesController),
              _buildTextField('Insurance', insuranceController),
              _buildTextField(
                  'Medical & Healthcare', medicalExpensesController),
              _buildTextField('Loan Repayments', loanRepaymentsController),
            ]),
            _buildSection('Optional Expenses', [
              _buildTextField('Dining Out', diningOutController),
              _buildTextField('Entertainment', entertainmentController),
              _buildTextField('Travel & Vacations', travelVacationsController),
              _buildTextField('Shopping', shoppingController),
              _buildTextField('Fitness & Gym', fitnessGymController),
              _buildTextField('Hobbies & Leisure', hobbiesLeisureController),
            ]),
            _buildSection('Assets', [
              _buildTextField('Fixed Deposits', fixedDepositsController),
              _buildTextField(
                  'Recurring Deposits', recurringDepositsController),
              _buildTextField('Savings Account', savingsAccountController),
              _buildTextField('Current Account', currentAccountController),
              _buildTextField(
                  'Employee Provident Fund', employeeProvidentFundController),
              _buildTextField(
                  'Public Provident Fund', publicProvidentFundController),
            ]),
            const SizedBox(height: 24.0),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _saveToFirestore,
                    child: const Text('Update Savings'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SummaryPage(),
                        ),
                      );
                    },
                    child: const Text('Plan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Financial Goals',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // List of selected goals
        ...selectedGoals.asMap().entries.map((entry) {
          final index = entry.key;
          final goalData = entry.value;
          final goal = goalData['goal'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: goal,
                      decoration: InputDecoration(
                        labelText: 'Select goal ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                      items: availableGoals.map((String goal) {
                        return DropdownMenuItem<String>(
                          value: goal,
                          child: Text(goal),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        _updateGoal(index, value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeGoal(index),
                  ),
                ],
              ),
              if (goal != null) ...[
                const SizedBox(height: 8),

                // Only show input fields if the goal is NOT "Dream Car", "Dream Home", or "Emergency Fund"
                if (goal == 'Retirement') ...[
                  _buildTextField(
                      'Current Age', retirementControllers['currentAge']!),
                  _buildTextField('Target Retirement Age',
                      retirementControllers['retirementAge']!),
                ] else if (goal != 'Dream Car' &&
                    goal != 'Dream Home' &&
                    goal != 'Emergency Fund') ...[
                  _buildTextField(
                      'Estimated Budget', goalBudgetControllers[goal]!),
                  _buildTextField('Years to Goal', goalYearsControllers[goal]!),
                ],

                const SizedBox(height: 16),
              ],
            ],
          );
        }).toList(),

        // Add goal button
        Center(
          child: TextButton(
            onPressed: _addNewGoal,
            child: const Text('+ Add Another Goal'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}

