import 'package:flutter/material.dart';
import 'dart:math';
import 'business.dart';
import 'dream.dart';
import 'dreamcar.dart';
import 'marriage.dart';
import 'retire.dart';
import 'emergency.dart';

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
          onPressed: () => Navigator.pop(context),
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
              InstantInvestingWidget(
                onGetStarted: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => const SipCalculatorModal(),
                  );
                },
              ),
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
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: goalDetails.length,
            itemBuilder: (context, index) {
              final goal = goalDetails[index];
              return buildGoalCard(
                goal['title'],
                goal['imagePath'],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => goal['page']),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create new goal pressed')));
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

  Widget buildGoalCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Image.asset(imagePath, width: 80, height: 40),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> goalDetails = [
  {
    'title': 'Retire early',
    'imagePath': 'assets/retire.png',
    'page': RetireEarly()
  },
  {
    'title': 'Emergency fund',
    'imagePath': 'assets/emergency.png',
    'page': EmergencyFund()
  },
  {'title': 'Dream home', 'imagePath': 'assets/home.png', 'page': DreamHome()},
  {'title': 'Dream car', 'imagePath': 'assets/car.png', 'page': Dreamcar()},
  {'title': 'Marriage', 'imagePath': 'assets/marriage.png', 'page': Marriage()},
  {
    'title': 'Business',
    'imagePath': 'assets/business.png',
    'page': BusinessPage()
  },
];

class InstantInvestingWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const InstantInvestingWidget({super.key, required this.onGetStarted});

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
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
          Image.asset('assets/invest.png',
              width: 150, height: 150, fit: BoxFit.cover),
        ],
      ),
    );
  }
}

class SipCalculatorModal extends StatefulWidget {
  const SipCalculatorModal({super.key});

  @override
  State<SipCalculatorModal> createState() => _SipCalculatorModalState();
}

class _SipCalculatorModalState extends State<SipCalculatorModal> {
  double monthlyInvestment = 5000;
  double annualReturnRate = 12;
  double investmentDuration = 10;

  @override
  Widget build(BuildContext context) {
    double futureValue = calculateFutureValue(
        monthlyInvestment, annualReturnRate, investmentDuration);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'SIP Calculator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Monthly Investment (₹)',
            min: 1000,
            max: 50000,
            value: monthlyInvestment,
            onChanged: (value) {
              setState(() {
                monthlyInvestment = value;
              });
            },
          ),
          _buildSlider(
            label: 'Expected Annual Return Rate (%)',
            min: 5,
            max: 15,
            value: annualReturnRate,
            onChanged: (value) {
              setState(() {
                annualReturnRate = value;
              });
            },
          ),
          _buildSlider(
            label: 'Investment Duration (Years)',
            min: 1,
            max: 30,
            value: investmentDuration,
            onChanged: (value) {
              setState(() {
                investmentDuration = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Estimated Future Value: ₹${futureValue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double min,
    required double max,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ₹${value.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }

  double calculateFutureValue(double monthlyInvestment, double annualReturnRate,
      double investmentDuration) {
    int months = (investmentDuration * 12).toInt();
    double monthlyReturnRate = annualReturnRate / 12 / 100;
    double futureValue = 0;

    for (int i = 1; i <= months; i++) {
      futureValue += monthlyInvestment * pow(1 + monthlyReturnRate, i);
    }

    return futureValue;
  }
}
