import 'package:flutter/material.dart';

class RetireEarly extends StatefulWidget {
  const RetireEarly({super.key});

  @override
  State<RetireEarly> createState() => _RetireEarlyState();
}

class _RetireEarlyState extends State<RetireEarly> {
  final TextEditingController _ageController = TextEditingController();
  String? _displayMessage; // Variable to store the message

  void _submit() {
    final enteredAge = _ageController.text;
    if (enteredAge.isNotEmpty) {
      setState(() {
        _displayMessage = 'Here are some plans for you';
      });
    } else {
      setState(() {
        _displayMessage = 'Please enter a valid age.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Early Retire',
          style: TextStyle(color: Colors.white),
        ),
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
              'Plan your early retirement. Here are some tips:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Save a significant portion of your income.\n'
              '2. Invest in diversified assets.\n'
              '3. Monitor your financial progress regularly.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Text(
                  "At what age do you want to retire:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50, // Adjusted width
                  height: 40, // Adjusted height
                  child: TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      suffixText: 'y', // Adds 'y' at the end
                      border: const OutlineInputBorder(),
                      hintText: 'Age',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, // Adjusted vertical padding
                        horizontal: 8, // Adjusted horizontal padding
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 15, // Smaller font size for label
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 13, // Font size for hint text
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15, // Font size for user input
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_displayMessage != null)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Aligns the text to the right
                children: [
                  Text(
                    _displayMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign:
                        TextAlign.left, // Aligns the text within its widget
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
