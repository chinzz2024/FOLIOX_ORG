import 'package:flutter/material.dart';
import 'summary_page.dart';

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

  String? selectedGoal;
  final List<String> goals = ['Retirement', 'Dream Car', 'Dream Home', 'Marriage', 'Emergency Fund'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bgop.jpeg', // Make sure you have this image in the assets folder and update pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Select Your Goal', [
                 DropdownButtonFormField<String>(
  value: selectedGoal,
  decoration: InputDecoration(
    labelText: 'Select your goal',
    labelStyle: TextStyle(color: Colors.white), // Label text color
    border: OutlineInputBorder(),
  ),
  dropdownColor: Colors.black, // Dropdown background color
  style: TextStyle(color: Colors.white), // Selected item text color
  items: goals.map((String goal) {
    return DropdownMenuItem<String>(
      value: goal,
      child: Text(goal, style: TextStyle(color: Colors.white)), // Dropdown item text color
    );
  }).toList(),
  selectedItemBuilder: (BuildContext context) => goals.map((String goal) {
    return Text(goal, style: TextStyle(color: Colors.white)); // Selected option text color
  }).toList(),
  onChanged: (String? value) {
    setState(() {
      selectedGoal = value;
    });
  },
),

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
                        onPressed: () {},
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
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
