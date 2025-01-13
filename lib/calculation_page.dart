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
                  'Your calculated savings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '₹${savings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              buildGoalSelection(context),
            ],
          ),
        ),
      ),
    );
  }

 Widget buildGoalSelection(BuildContext context) {
  return Column(
    children: [
      const Text(
        'Choose your goal & invest for it!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 12, // Space between columns
        mainAxisSpacing: 12, // Space between rows
        childAspectRatio: 0.8, // Adjust aspect ratio of each item
        children: [
          buildGoalCard('Retire early', 'assets/retire.png'),
          buildGoalCard('Emergency fund', 'assets/emergency.png'),
          buildGoalCard('Buy dream home', 'assets/home.png'),
          buildGoalCard('Marriage', 'assets/marriage.png'),
        ],
      ),
      const SizedBox(height: 30),
      Center(
        child: ElevatedButton(
          onPressed: () {
            // Add functionality for creating a new goal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create new goal pressed')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: const Color.fromARGB(255, 12, 6, 37),
          ),
          child: const Text(
            'Create new goal',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}

Widget buildGoalCard(String title, String iconPath) {
  return SizedBox(
    width: 40, // Fixed width for the card
    height: 40, // Fixed height for the card
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 60, // Adjust the image width
              height: 60, // Adjust the image height
              fit: BoxFit.contain, // Ensure the image fits without distortion
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
}