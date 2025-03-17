import 'package:flutter/material.dart';
import 'dart:math';
import 'business.dart';
import 'dream.dart';
import 'dreamcar.dart';
import 'marriage.dart';
import 'retire.dart';
import 'emergency.dart';

class CalculationPage extends StatelessWidget {
  final double savings;

  const CalculationPage({super.key, required this.savings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings Calculation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Card(
                    elevation: 6,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Your Calculated Savings',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '₹${savings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
      ),
    );
  }

  Widget buildGoalSelection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Choose Your Goal & Invest!',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
              childAspectRatio: 1,
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
      ],
    );
  }

  Widget buildGoalCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 80, height: 80),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> goalDetails = [
  {'title': 'Retire early', 'imagePath': 'assets/retire.png', 'page': RetireEarly()},
  {'title': 'Emergency fund', 'imagePath': 'assets/emergency.png', 'page': EmergencyFund()},
  {'title': 'Dream home', 'imagePath': 'assets/home.png', 'page': DreamHome()},
  {'title': 'Dream car', 'imagePath': 'assets/car.png', 'page': DreamcarPage()},
  {'title': 'Marriage', 'imagePath': 'assets/marriage.png', 'page': Marriage()},
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

  double calculateFutureValue(
      double monthlyInvestment, double annualReturnRate, double investmentDuration) {
    int months = (investmentDuration * 12).toInt();
    double monthlyReturnRate = annualReturnRate / 12 / 100;
    double futureValue = 0;

    for (int i = 1; i <= months; i++) {
      futureValue += monthlyInvestment * pow(1 + monthlyReturnRate, i);
    }

    return futureValue;
  }
}
