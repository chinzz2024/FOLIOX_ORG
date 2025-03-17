import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foliox/home_page.dart';
import 'package:foliox/planner_page.dart';
import 'calculation_page.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController dearnessAllowanceController = TextEditingController();
  final TextEditingController houseRentAllowanceController = TextEditingController();
  final TextEditingController transportAllowanceController = TextEditingController();
  final TextEditingController rentMortgageController = TextEditingController();
  final TextEditingController foodGroceriesController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController medicalExpensesController = TextEditingController();
  final TextEditingController loanRepaymentsController = TextEditingController();
  final TextEditingController diningOutController = TextEditingController();
  final TextEditingController entertainmentController = TextEditingController();
  final TextEditingController travelVacationsController = TextEditingController();
  final TextEditingController shoppingController = TextEditingController();
  final TextEditingController fitnessGymController = TextEditingController();
  final TextEditingController hobbiesLeisureController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PlannerPage()));
          },
        ),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bgop.jpeg', // Add your background image here
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Dark overlay for readability
          ),
          SingleChildScrollView(
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
                        onPressed: () {},
                        child: const Text('Update Savings'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CalculationPage(savings: 0.0)),
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
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
