import 'package:flutter/material.dart';
import 'option.dart';
import 'calculation_page.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController dearnessAllowanceController =
      TextEditingController();
  final TextEditingController houseRentAllowanceController =
      TextEditingController();
  final TextEditingController transportAllowanceController =
      TextEditingController();

  final TextEditingController providentFundController = TextEditingController();
  final TextEditingController incomeTaxController = TextEditingController();
  final TextEditingController professionalTaxController =
      TextEditingController();
  final TextEditingController licController = TextEditingController();
  final TextEditingController vehicleLoanController = TextEditingController();

  final TextEditingController housingRentController = TextEditingController();
  final TextEditingController utilitiesController = TextEditingController();
  final TextEditingController transportationController =
      TextEditingController();
  final TextEditingController educationController = TextEditingController();

  bool showOtherIncomeFields = false;
  bool showOtherDeductionFields = false;
  bool showOtherExpenditureFields = false;

  final List<TextEditingController> otherIncomeControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> otherDeductionControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> otherExpenditureControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    baseSalaryController.dispose();
    dearnessAllowanceController.dispose();
    houseRentAllowanceController.dispose();
    transportAllowanceController.dispose();

    providentFundController.dispose();
    incomeTaxController.dispose();
    professionalTaxController.dispose();
    licController.dispose();
    vehicleLoanController.dispose();

    housingRentController.dispose();
    utilitiesController.dispose();
    transportationController.dispose();
    educationController.dispose();

    for (var controller in otherIncomeControllers) {
      controller.dispose();
    }
    for (var controller in otherDeductionControllers) {
      controller.dispose();
    }
    for (var controller in otherExpenditureControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Government Employee',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmploymentOptionPage()),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTextField('Base Salary', baseSalaryController),
              _buildTextField('Dearness Allowance', dearnessAllowanceController),
              _buildTextField(
                  'House Rent Allowance (HRA)', houseRentAllowanceController),
              _buildTextField(
                  'Transport Allowance', transportAllowanceController),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showOtherIncomeFields = !showOtherIncomeFields;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                ),
                child: Text(
                  showOtherIncomeFields
                      ? 'Hide Other Income Fields'
                      : 'Add Other Income Fields',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (showOtherIncomeFields)
                Column(
                  children: [
                    _buildTextField(
                        'Medical Allowance', otherIncomeControllers[0]),
                    _buildTextField(
                        'Children\'s Education Allowance', otherIncomeControllers[1]),
                    _buildTextField(
                        'Festival Allowance', otherIncomeControllers[2]),
                    _buildTextField(
                        'Performance Linked Bonuses', otherIncomeControllers[3]),
                    _buildTextField('Spouse Income', otherIncomeControllers[4]),
                  ],
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Deduction Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTextField('Provident Fund', providentFundController),
              _buildTextField('Income Tax', incomeTaxController),
              _buildTextField('Professional Tax', professionalTaxController),
              _buildTextField('LIC/Other Insurances', licController),
              _buildTextField('Vehicle/Other Loans', vehicleLoanController),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showOtherDeductionFields = !showOtherDeductionFields;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                ),
                child: Text(
                  showOtherDeductionFields
                      ? 'Hide Other Deduction Fields'
                      : 'Add Other Deduction Fields',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (showOtherDeductionFields)
                Column(
                  children: [
                    _buildTextField(
                        'Maintenance Fund', otherDeductionControllers[0]),
                    _buildTextField(
                        'Employees State Insurance', otherDeductionControllers[1]),
                    _buildTextField(
                        'National Pension System', otherDeductionControllers[2]),
                    _buildTextField(
                        'Training Expenses', otherDeductionControllers[3]),
                    _buildTextField(
                        'Professional Expenses', otherDeductionControllers[4]),
                  ],
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Expenditure Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTextField('Health And Wellness', housingRentController),
              _buildTextField('Housing And Utilities', utilitiesController),
              _buildTextField('Transportation', transportationController),
              _buildTextField('Education', educationController),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showOtherExpenditureFields = !showOtherExpenditureFields;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                ),
                child: Text(
                  showOtherExpenditureFields
                      ? 'Hide Other Expenditure Fields'
                      : 'Add Other Expenditure Fields',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (showOtherExpenditureFields)
                Column(
                  children: [
                    _buildTextField('Food and Groceries',
                        otherExpenditureControllers[0]),
                    _buildTextField('Personal And Miscellaneous',
                        otherExpenditureControllers[1]),
                    _buildTextField(
                        'Emergency Fund',
                        otherExpenditureControllers[2]),
                    _buildTextField('Entertainment Expenses',
                        otherExpenditureControllers[3]),
                  ],
                ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Collect all input values from controllers
                    final basicSalary = double.tryParse(baseSalaryController.text) ?? 0;
                    final dearnessAllowance = double.tryParse(dearnessAllowanceController.text) ?? 0;
                    final houseRentAllowance = double.tryParse(houseRentAllowanceController.text) ?? 0;
                    final transportAllowance = double.tryParse(transportAllowanceController.text) ?? 0;
                    final providentFund = double.tryParse(providentFundController.text) ?? 0;
                    final incomeTax = double.tryParse(incomeTaxController.text) ?? 0;
                    final professionalTax = double.tryParse(professionalTaxController.text) ?? 0;
                    final lic = double.tryParse(licController.text) ?? 0;
                    final vehicleLoan = double.tryParse(vehicleLoanController.text) ?? 0;
                    final housingRent = double.tryParse(housingRentController.text) ?? 0;
                    final utilities = double.tryParse(utilitiesController.text) ?? 0;
                    final transportation = double.tryParse(transportationController.text) ?? 0;
                    final education = double.tryParse(educationController.text) ?? 0;
                    final otherIncome = otherIncomeControllers.map((e) => double.tryParse(e.text) ?? 0).toList();
                    final otherDeductions = otherDeductionControllers.map((e) => double.tryParse(e.text) ?? 0).toList();
                    final otherExpenditures = otherExpenditureControllers.map((e) => double.tryParse(e.text) ?? 0).toList();

                    // Navigate to CalculationPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalculationPage(
                          baseSalary: basicSalary,
                          dearnessAllowance: dearnessAllowance,
                          houseRentAllowance: houseRentAllowance,
                          transportAllowance: transportAllowance,
                          otherIncome: otherIncome,
                          providentFund: providentFund,
                          incomeTax: incomeTax,
                          professionalTax: professionalTax,
                          lic: lic,
                          vehicleLoan: vehicleLoan,
                          housingRent: housingRent,
                          utilities: utilities,
                          transportation: transportation,
                          education: education,
                          otherExpenditures: otherExpenditures,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Calculate Savings',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
