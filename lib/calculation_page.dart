import 'package:flutter/material.dart';
import 'package:foliox/emergency.dart';
import 'business.dart';
import 'dream.dart';
import 'dreamcar.dart';
import 'marriage.dart';
import 'retire.dart';

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
    final double totalOtherIncome =
        otherIncome.fold(0.0, (sum, item) => sum + item);
    final double totalOtherExpenditures =
        otherExpenditures.fold(0.0, (sum, item) => sum + item);

    final double totalIncome = baseSalary +
        dearnessAllowance +
        houseRentAllowance +
        transportAllowance +
        totalOtherIncome;
    final double totalDeductions =
        providentFund + incomeTax + professionalTax + lic + vehicleLoan;
    final double totalExpenses = housingRent +
        utilities +
        transportation +
        education +
        totalOtherExpenditures;

    final double savings = totalIncome - (totalDeductions + totalExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Calculation',
            style: TextStyle(color: Colors.white)),
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
              const SizedBox(height: 20),
              const InstantInvestingWidget(),
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
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: [
              buildGoalCard(
                'Retire early',
                'assets/retire.png',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RetireEarly())),
              ),
              buildGoalCard(
                'Emergency fund',
                'assets/emergency.png',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmergencyFund())),
              ),
              buildGoalCard(
                'Dream home',
                'assets/home.png',
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const DreamHome())),
              ),
              buildGoalCard(
                'Dream car',
                'assets/car.png',
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Dreamcar())),
              ),
              buildGoalCard(
                'Marriage',
                'assets/marriage.png',
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Marriage())),
              ),
              buildGoalCard(
                'Business',
                'assets/business.png',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BusinessPage())),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
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

  Widget buildGoalCard(String title, String iconPath, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        backgroundColor: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class InstantInvestingWidget extends StatelessWidget {
  const InstantInvestingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instant investing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Begin your MF investment journey today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Get started button pressed')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6200EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Get started'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'assets/invest.png',
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
