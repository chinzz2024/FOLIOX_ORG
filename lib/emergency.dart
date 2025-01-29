import 'package:flutter/material.dart';

class EmergencyFund extends StatefulWidget {
  const EmergencyFund({super.key});

  @override
  State<EmergencyFund> createState() => _EmergencyFundState();
}

class _EmergencyFundState extends State<EmergencyFund> {
  final TextEditingController _monthlyExpenseController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  String? _displayMessage;

  void _calculateEmergencyFund() {
    final monthlyExpenseText = _monthlyExpenseController.text;
    final monthsText = _monthsController.text;

    if (monthlyExpenseText.isEmpty || monthsText.isEmpty) {
      setState(() {
        _displayMessage = 'Please fill in all fields.';
      });
      return;
    }

    final monthlyExpense = double.tryParse(monthlyExpenseText);
    final months = int.tryParse(monthsText);

    if (monthlyExpense == null || monthlyExpense <= 0 || months == null || months <= 0) {
      setState(() {
        _displayMessage = 'Please enter valid numbers.';
      });
      return;
    }

    final emergencyFund = monthlyExpense * months;

    setState(() {
      _displayMessage =
          'You need an emergency fund of ₹${emergencyFund.toStringAsFixed(2)} for $months months of expenses.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Fund Planner', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan your Emergency Fund:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Monthly Expenses:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _monthlyExpenseController,
                    decoration: const InputDecoration(
                      prefixText: '₹',
                      border: OutlineInputBorder(),
                      hintText: 'Amount',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Months to Cover:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _monthsController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Months',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _calculateEmergencyFund,
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_displayMessage != null)
              Text(
                _displayMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
