import 'package:flutter/material.dart';


class CalculationPage extends StatelessWidget {
  final double baseSalary;
  final double dearnessAllowance;
  final double houseRentAllowance;
  final double transportAllowance;
  final List<double> otherIncome;

  final double providentFund;
  final double incomeTax;
  final double professionalTax;
  final double lic;
  final double vehicleLoan;

  final double housingRent;
  final double utilities;
  final double transportation;
  final double education;
  final List<double> otherExpenditures;

  const CalculationPage({
    super.key,
    required this.baseSalary,
    required this.dearnessAllowance,
    required this.houseRentAllowance,
    required this.transportAllowance,
    required this.otherIncome,
    required this.providentFund,
    required this.incomeTax,
    required this.professionalTax,
    required this.lic,
    required this.vehicleLoan,
    required this.housingRent,
    required this.utilities,
    required this.transportation,
    required this.education,
    required this.otherExpenditures,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    final double totalOtherIncome =
        otherIncome.fold(0.0, (sum, item) => sum + item);
    final double totalOtherExpenditures =
        otherExpenditures.fold(0.0, (sum, item) => sum + item);

    // Calculate savings
    final double totalIncome = baseSalary +
        dearnessAllowance +
        houseRentAllowance +
        transportAllowance +
        totalOtherIncome;
    final double totalDeductions = providentFund +
        incomeTax +
        professionalTax +
        lic +
        vehicleLoan;
    final double totalExpenses = housingRent +
        utilities +
        transportation +
        education +
        totalOtherExpenditures;

    final double savings = totalIncome - (totalDeductions + totalExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Calculation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
              const Center(
                child: Text(
                  'Your Savings Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildSummaryRow('Total Income:', totalIncome),
              buildSummaryRow('Total Deductions:', totalDeductions),
              buildSummaryRow('Total Expenditures:', totalExpenses),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Savings: ₹${savings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              buildInvestmentCalculator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildInvestmentCalculator(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController interestController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Investment Calculator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Investment Amount',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: interestController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Interest Rate (%)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              final double? amount =
                  double.tryParse(amountController.text.trim());
              final double? interest =
                  double.tryParse(interestController.text.trim());

              if (amount != null && interest != null) {
                final double finalAmount =
                    amount + (amount * (interest / 100));

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Investment Result'),
                    content: Text(
                      'Amount After Interest: ₹${finalAmount.toStringAsFixed(2)}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid numbers')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 12, 6, 37),
            ),
            child: const Text(
              'Calculate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
