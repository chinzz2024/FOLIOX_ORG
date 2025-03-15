import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculation_page.dart'; // Import the CalculationPage

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
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('financialPlanner').doc(userId).set({
        'Income': {
          'Base Salary': double.tryParse(baseSalaryController.text) ?? 0,
          'Dearness Allowance': double.tryParse(dearnessAllowanceController.text) ?? 0,
          'House Rent Allowance': double.tryParse(houseRentAllowanceController.text) ?? 0,
          'Transport Allowance': double.tryParse(transportAllowanceController.text) ?? 0,
        },
        'Essential Expenses': {
          'Rent/Mortgage': double.tryParse(rentMortgageController.text) ?? 0,
          'Food & Groceries': double.tryParse(foodGroceriesController.text) ?? 0,
          'Insurance': double.tryParse(insuranceController.text) ?? 0,
          'Medical Expenses': double.tryParse(medicalExpensesController.text) ?? 0,
          'Loan Repayments': double.tryParse(loanRepaymentsController.text) ?? 0,
        },
        'Optional Expenses': {
          'Dining Out': double.tryParse(diningOutController.text) ?? 0,
          'Entertainment': double.tryParse(entertainmentController.text) ?? 0,
          'Travel & Vacations': double.tryParse(travelVacationsController.text) ?? 0,
          'Shopping': double.tryParse(shoppingController.text) ?? 0,
          'Fitness & Gym': double.tryParse(fitnessGymController.text) ?? 0,
          'Hobbies & Leisure': double.tryParse(hobbiesLeisureController.text) ?? 0,
        },
        'Assets': {
          'Fixed Deposits': double.tryParse(fixedDepositsController.text) ?? 0,
          'Recurring Deposits': double.tryParse(recurringDepositsController.text) ?? 0,
          'Savings Account': double.tryParse(savingsAccountController.text) ?? 0,
          'Current Account': double.tryParse(currentAccountController.text) ?? 0,
          'Employee Provident Fund': double.tryParse(employeeProvidentFundController.text) ?? 0,
          'Public Provident Fund': double.tryParse(publicProvidentFundController.text) ?? 0,
        },
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
                        MaterialPageRoute(builder: (context) => CalculationPage(savings: 0.0),),
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
