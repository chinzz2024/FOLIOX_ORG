import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculation_page.dart'; // Import the CalculationPage
import 'summary_page.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  // Income Fields
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController dearnessAllowanceController = TextEditingController();
  final TextEditingController houseRentAllowanceController = TextEditingController();
  final TextEditingController transportAllowanceController = TextEditingController();

  // Essential Expenses
  final TextEditingController rentMortgageController = TextEditingController();
  final TextEditingController foodGroceriesController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController medicalExpensesController = TextEditingController();
  final TextEditingController loanRepaymentsController = TextEditingController();

  // Optional Expenses
  final TextEditingController diningOutController = TextEditingController();
  final TextEditingController entertainmentController = TextEditingController();
  final TextEditingController travelVacationsController = TextEditingController();
  final TextEditingController shoppingController = TextEditingController();
  final TextEditingController fitnessGymController = TextEditingController();
  final TextEditingController hobbiesLeisureController = TextEditingController();

  // Assets
  final TextEditingController fixedDepositsController = TextEditingController();
  final TextEditingController recurringDepositsController = TextEditingController();
  final TextEditingController savingsAccountController = TextEditingController();
  final TextEditingController currentAccountController = TextEditingController();
  final TextEditingController employeeProvidentFundController = TextEditingController();
  final TextEditingController publicProvidentFundController = TextEditingController();

  // Goal Selection
  String? selectedGoal;

  // Marriage-specific fields
  final TextEditingController marriageBudgetController = TextEditingController();
  final TextEditingController marriageYearsController = TextEditingController();

  final List<String> goals = [
    'Retirement',
    'Dream Car',
    'Dream Home',
    'Marriage',
    'Emergency Fund',
  ];

  @override
  void dispose() {
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
    marriageBudgetController.dispose();
    marriageYearsController.dispose();
    super.dispose();
  }

Future<void> _saveToFirestore() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  // Create a map to store only the fields that have been entered by the user
  Map<String, dynamic> data = {};

  // Add Income fields if they are not empty
  if (baseSalaryController.text.isNotEmpty) {
    data['Income'] = {
      'Base Salary': double.tryParse(baseSalaryController.text),
    };
  }
  if (dearnessAllowanceController.text.isNotEmpty) {
    data['Income'] ??= {};
    data['Income']!['Dearness Allowance'] = double.tryParse(dearnessAllowanceController.text);
  }
  if (houseRentAllowanceController.text.isNotEmpty) {
    data['Income'] ??= {};
    data['Income']!['House Rent Allowance'] = double.tryParse(houseRentAllowanceController.text);
  }
  if (transportAllowanceController.text.isNotEmpty) {
    data['Income'] ??= {};
    data['Income']!['Transport Allowance'] = double.tryParse(transportAllowanceController.text);
  }

  // Add Essential Expenses fields if they are not empty
  if (rentMortgageController.text.isNotEmpty) {
    data['Essential Expenses'] = {
      'Rent/Mortgage': double.tryParse(rentMortgageController.text),
    };
  }
  if (foodGroceriesController.text.isNotEmpty) {
    data['Essential Expenses'] ??= {};
    data['Essential Expenses']!['Food & Groceries'] = double.tryParse(foodGroceriesController.text);
  }
  if (insuranceController.text.isNotEmpty) {
    data['Essential Expenses'] ??= {};
    data['Essential Expenses']!['Insurance'] = double.tryParse(insuranceController.text);
  }
  if (medicalExpensesController.text.isNotEmpty) {
    data['Essential Expenses'] ??= {};
    data['Essential Expenses']!['Medical & Healthcare'] = double.tryParse(medicalExpensesController.text);
  }
  if (loanRepaymentsController.text.isNotEmpty) {
    data['Essential Expenses'] ??= {};
    data['Essential Expenses']!['Loan Repayments'] = double.tryParse(loanRepaymentsController.text);
  }

  // Add Optional Expenses fields if they are not empty
  if (diningOutController.text.isNotEmpty) {
    data['Optional Expenses'] = {
      'Dining Out': double.tryParse(diningOutController.text),
    };
  }
  if (entertainmentController.text.isNotEmpty) {
    data['Optional Expenses'] ??= {};
    data['Optional Expenses']!['Entertainment'] = double.tryParse(entertainmentController.text);
  }
  if (travelVacationsController.text.isNotEmpty) {
    data['Optional Expenses'] ??= {};
    data['Optional Expenses']!['Travel & Vacations'] = double.tryParse(travelVacationsController.text);
  }
  if (shoppingController.text.isNotEmpty) {
    data['Optional Expenses'] ??= {};
    data['Optional Expenses']!['Shopping'] = double.tryParse(shoppingController.text);
  }
  if (fitnessGymController.text.isNotEmpty) {
    data['Optional Expenses'] ??= {};
    data['Optional Expenses']!['Fitness & Gym'] = double.tryParse(fitnessGymController.text);
  }
  if (hobbiesLeisureController.text.isNotEmpty) {
    data['Optional Expenses'] ??= {};
    data['Optional Expenses']!['Hobbies & Leisure'] = double.tryParse(hobbiesLeisureController.text);
  }

  // Add Assets fields if they are not empty
  if (fixedDepositsController.text.isNotEmpty) {
    data['Assets'] = {
      'Fixed Deposits': double.tryParse(fixedDepositsController.text),
    };
  }
  if (recurringDepositsController.text.isNotEmpty) {
    data['Assets'] ??= {};
    data['Assets']!['Recurring Deposits'] = double.tryParse(recurringDepositsController.text);
  }
  if (savingsAccountController.text.isNotEmpty) {
    data['Assets'] ??= {};
    data['Assets']!['Savings Account'] = double.tryParse(savingsAccountController.text);
  }
  if (currentAccountController.text.isNotEmpty) {
    data['Assets'] ??= {};
    data['Assets']!['Current Account'] = double.tryParse(currentAccountController.text);
  }
  if (employeeProvidentFundController.text.isNotEmpty) {
    data['Assets'] ??= {};
    data['Assets']!['Employee Provident Fund'] = double.tryParse(employeeProvidentFundController.text);
  }
  if (publicProvidentFundController.text.isNotEmpty) {
    data['Assets'] ??= {};
    data['Assets']!['Public Provident Fund'] = double.tryParse(publicProvidentFundController.text);
  }

  // Add Goal if selected
  if (selectedGoal != null) {
    data['Goal'] = selectedGoal;
  }

  // Add Marriage-specific fields if selected and filled out
  if (selectedGoal == 'Marriage') {
    if (marriageBudgetController.text.isNotEmpty || marriageYearsController.text.isNotEmpty) {
      data['Marriage Details'] = {};
      if (marriageBudgetController.text.isNotEmpty) {
        data['Marriage Details']!['Total Estimated Budget'] = double.tryParse(marriageBudgetController.text);
      }
      if (marriageYearsController.text.isNotEmpty) {
        data['Marriage Details']!['Total Years to Goal'] = int.tryParse(marriageYearsController.text);
      }
    }
  }

  // Add timestamp
  data['timestamp'] = FieldValue.serverTimestamp();

  try {
    // Save only the entered data to Firestore
    await FirebaseFirestore.instance.collection('financialPlanner').doc(userId).set(data, SetOptions(merge: true));

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
            _buildSection('Select Your Goal', [
              DropdownButtonFormField<String>(
                value: selectedGoal,
                decoration: InputDecoration(
                  labelText: 'Select your goal',
                  border: OutlineInputBorder(),
                ),
                items: goals.map((String goal) {
                  return DropdownMenuItem<String>(
                    value: goal,
                    child: Text(goal),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedGoal = value;
                  });
                },
              ),
              if (selectedGoal == 'Marriage') ...[
                const SizedBox(height: 16),
                _buildTextField('Total Estimated Budget', marriageBudgetController),
                _buildTextField('Total Years to Goal', marriageYearsController),
              ],
            ]),
            _buildSection('Income Details', [
              _buildTextField('Base Salary', baseSalaryController),
              _buildTextField('Dearness Allowance', dearnessAllowanceController),
              _buildTextField('House Rent Allowance (HRA)', houseRentAllowanceController),
              _buildTextField('Transport Allowance', transportAllowanceController),
            ]),
            _buildSection('Essential Expenses', [
              _buildTextField('Rent/Mortgage', rentMortgageController),
              _buildTextField('Food & Groceries', foodGroceriesController),
              _buildTextField('Insurance', insuranceController),
              _buildTextField('Medical & Healthcare', medicalExpensesController),
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
              _buildTextField('Recurring Deposits', recurringDepositsController),
              _buildTextField('Savings Account', savingsAccountController),
              _buildTextField('Current Account', currentAccountController),
              _buildTextField('Employee Provident Fund', employeeProvidentFundController),
              _buildTextField('Public Provident Fund', publicProvidentFundController),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}