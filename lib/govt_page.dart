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
      goalBudgetControllers.remove(oldGoal);
      goalYearsControllers.remove(oldGoal);
      retirementControllers.remove(oldGoal);

      // Assign the old values to the new goal if applicable
      if (newGoal != null) {
        goalBudgetControllers.putIfAbsent(
            newGoal, () => TextEditingController(text: oldBudget));
        goalYearsControllers.putIfAbsent(
            newGoal, () => TextEditingController(text: oldYears));

        if (newGoal == 'Retirement') {
          retirementControllers.putIfAbsent(
              'currentAge', () => TextEditingController(text: oldCurrentAge));
          retirementControllers.putIfAbsent(
              'retirementAge', () => TextEditingController(text: oldRetirementAge));
        }
      }
    }

    selectedGoals[index]['goal'] = newGoal;
  });
}
Future<void> _saveToFirestore() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  // Income details
  Map<String, dynamic> incomeData = {
    'baseSalary': double.tryParse(baseSalaryController.text) ?? 0,
    'dearnessAllowance': double.tryParse(dearnessAllowanceController.text) ?? 0,
    'houseRentAllowance': double.tryParse(houseRentAllowanceController.text) ?? 0,
    'transportAllowance': double.tryParse(transportAllowanceController.text) ?? 0,
  };

  // Essential expenses
  Map<String, dynamic> essentialExpensesData = {
    'rentMortgage': double.tryParse(rentMortgageController.text) ?? 0,
    'foodGroceries': double.tryParse(foodGroceriesController.text) ?? 0,
    'insurance': double.tryParse(insuranceController.text) ?? 0,
    'medicalExpenses': double.tryParse(medicalExpensesController.text) ?? 0,
    'loanRepayments': double.tryParse(loanRepaymentsController.text) ?? 0,
  };

  // Optional expenses
  Map<String, dynamic> optionalExpensesData = {
    'diningOut': double.tryParse(diningOutController.text) ?? 0,
    'entertainment': double.tryParse(entertainmentController.text) ?? 0,
    'travelVacations': double.tryParse(travelVacationsController.text) ?? 0,
    'shopping': double.tryParse(shoppingController.text) ?? 0,
    'fitnessGym': double.tryParse(fitnessGymController.text) ?? 0,
    'hobbiesLeisure': double.tryParse(hobbiesLeisureController.text) ?? 0,
  };

  // Assets
  Map<String, dynamic> assetsData = {
    'fixedDeposits': double.tryParse(fixedDepositsController.text) ?? 0,
    'recurringDeposits': double.tryParse(recurringDepositsController.text) ?? 0,
    'savingsAccount': double.tryParse(savingsAccountController.text) ?? 0,
    'currentAccount': double.tryParse(currentAccountController.text) ?? 0,
    'employeeProvidentFund': double.tryParse(employeeProvidentFundController.text) ?? 0,
    'publicProvidentFund': double.tryParse(publicProvidentFundController.text) ?? 0,
  };

  // Goals
  List<Map<String, dynamic>> goalsList = [];

  for (var goalData in selectedGoals) {
    final goal = goalData['goal'];

    if (goal == "Dream Car" || goal == "Dream Home" || goal == "Emergency Fund") {
      goalsList.add({'goal': goal});
    } else if (goal == "Retirement") {
      goalsList.add({
        'goal': goal,
        'currentAge': int.tryParse(retirementControllers['currentAge']?.text ?? '') ?? null,
        'retirementAge': int.tryParse(retirementControllers['retirementAge']?.text ?? '') ?? null,
      });
    } else if (goal == "Marriage") {
      goalsList.add({
        'goal': goal,
        'estimatedBudget': double.tryParse(goalBudgetControllers[goal]?.text ?? '') ?? null,
        'targetYear': int.tryParse(goalYearsControllers[goal]?.text ?? '') ?? null,
      });
    }
  }

  // Calculate totals
  double totalIncome = incomeData.values.reduce((sum, value) => sum + value);
  double totalEssentialExpenses = essentialExpensesData.values.reduce((sum, value) => sum + value);
  double totalOptionalExpenses = optionalExpensesData.values.reduce((sum, value) => sum + value);
  double totalSavings = totalIncome - (totalEssentialExpenses + totalOptionalExpenses);

  // Firestore document structure
  Map<String, dynamic> data = {
    'incomeDetails': incomeData,
    'essentialExpenses': essentialExpensesData,
    'optionalExpenses': optionalExpensesData,
    'assets': assetsData,
    'totalIncome': totalIncome, // ✅ Added total income
    'totalEssentialExpenses': totalEssentialExpenses, // ✅ Added total essential expenses
    'totalOptionalExpenses': totalOptionalExpenses, // ✅ Added total optional expenses
    'savings': totalSavings,
    'goalsSelected': goalsList,
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    await FirebaseFirestore.instance
        .collection('financialPlanner')
        .doc(userId)
        .set(data, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save data: $error')),
    );
  }
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

