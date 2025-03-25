import 'package:flutter/material.dart';
import 'planner_page.dart';
import 'dart:math';
import 'govt_page.dart';

class EmploymentOptionPage extends StatelessWidget {
  const EmploymentOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Employment Type',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlannerPage()),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const SIPCalculator(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Your existing content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IncomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 18, 48, 73),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Government Employee'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PlaceholderPage(title: 'Private Employee'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 30, 75, 93),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Private Employee'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PlaceholderPage(title: 'Others'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 60, 121, 168),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Others'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SIPCalculator extends StatefulWidget {
  const SIPCalculator({super.key});

  @override
  _SIPCalculatorState createState() => _SIPCalculatorState();
}

class _SIPCalculatorState extends State<SIPCalculator> {
  final TextEditingController _monthlyInvestmentController = TextEditingController(text: '5000');
  final TextEditingController _annualReturnController = TextEditingController(text: '12');
  final TextEditingController _timePeriodController = TextEditingController(text: '5');
  double _futureValue = 0;
  double _totalInvestment = 0;
  double _estimatedReturns = 0;

  void _calculateSIP() {
    final double monthlyInvestment = double.tryParse(_monthlyInvestmentController.text) ?? 0;
    final double annualReturn = double.tryParse(_annualReturnController.text) ?? 0;
    final double timePeriod = double.tryParse(_timePeriodController.text) ?? 0;

    if (monthlyInvestment > 0 && annualReturn > 0 && timePeriod > 0) {
      final double monthlyRate = annualReturn / 12 / 100;
      final double months = timePeriod * 12;
      
      _futureValue = monthlyInvestment * 
          ((pow(1 + monthlyRate, months) - 1) / monthlyRate) * 
          (1 + monthlyRate);
      _totalInvestment = monthlyInvestment * months;
      _estimatedReturns = _futureValue - _totalInvestment;
    } else {
      _futureValue = 0;
      _totalInvestment = 0;
      _estimatedReturns = 0;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _calculateSIP();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SIP Calculator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField('Monthly Investment (₹)', _monthlyInvestmentController),
            _buildTextField('Expected Annual Return (%)', _annualReturnController),
            _buildTextField('Time Period (Years)', _timePeriodController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateSIP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildResultRow('Invested Amount', _totalInvestment),
                    _buildResultRow('Estimated Returns', _estimatedReturns),
                    _buildResultRow('Total Value', _futureValue, isTotal: true),
                  ],
                ),
              ),
            ),
          ],
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
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.clear(),
          ),
        ),
        onChanged: (value) => _calculateSIP(),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'You selected: $title',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}