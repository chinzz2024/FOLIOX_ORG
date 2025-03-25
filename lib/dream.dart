import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() {
  runApp(LoanRatesApp());
}

class LoanRatesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [LoanRatesScreen(), DreamHomeScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Loan & Home EMI')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Loan Rates'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dream Home'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class LoanRatesScreen extends StatefulWidget {
  @override
  _LoanRatesScreenState createState() => _LoanRatesScreenState();
}

class _LoanRatesScreenState extends State<LoanRatesScreen> {
  List<dynamic> loanRates = [];

  @override
  void initState() {
    super.initState();
    fetchLoanRates();
  }

  Future<void> fetchLoanRates() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/loan-rates'));
      if (response.statusCode == 200) {
        setState(() {
          loanRates = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load loan rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching loan rates: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading loan rates: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loanRates.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: loanRates.length,
              itemBuilder: (context, index) {
                final rate = loanRates[index];
                return ListTile(
                  title: Text(rate['bank_name'] ?? 'Unknown Bank'),
                  subtitle: Text('Rate: ${rate['rate']?.toString() ?? 'N/A'}%'),
                );
              },
            ),
    );
  }
}

class DreamHomeScreen extends StatefulWidget {
  @override
  State<DreamHomeScreen> createState() => _DreamHomeScreenState();
}

class _DreamHomeScreenState extends State<DreamHomeScreen> {
  bool isEMISelected = false;
  double emi = 0.0;
  List<dynamic> loanRates = [];

  @override
  void initState() {
    super.initState();
    fetchLoanRates();
  }

  Future<void> fetchLoanRates() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/loan-rates'));
      if (response.statusCode == 200) {
        setState(() {
          loanRates = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load loan rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching loan rates: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading loan rates: $e')),
      );
    }
  }

  void showEMICalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: EMICalculator(
            onEMICalculated: (calculatedEMI) {
              setState(() {
                emi = calculatedEMI;
                isEMISelected = true;
              });
            },
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
       appBar: AppBar(
        title: Text('Dream Home', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
         centerTitle: true,
      ),

    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How do you want to build your home?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEMISelected = false;
                  });
                },
                child: const Text('Ready Cash'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  showEMICalculator(context);
                },
                child: const Text('EMI'),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Expanded widget to take remaining space
          Expanded(
            child: isEMISelected
                ? emi > 0
                    ? Center(
                        child: Text('EMI: ₹${emi.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      )
                    : Center(child: Text('Calculate your EMI'))
                : ReadyCashCalculator(loanRates: loanRates),
          ),
        ],
      ),
    ),
  );
}
}

class ReadyCashCalculator extends StatefulWidget {
  final List<dynamic> loanRates;

  const ReadyCashCalculator({Key? key, required this.loanRates}) : super(key: key);

  @override
  _ReadyCashCalculatorState createState() => _ReadyCashCalculatorState();
}

class _ReadyCashCalculatorState extends State<ReadyCashCalculator> {
  TextEditingController targetAmountController = TextEditingController();
  TextEditingController currentSavingsController = TextEditingController();
  TextEditingController yearsController = TextEditingController();
  double monthlySavings = 0.0;

  void calculateMonthlySavings() {
    double targetAmount = double.tryParse(targetAmountController.text) ?? 0;
    double currentSavings = double.tryParse(currentSavingsController.text) ?? 0;
    int years = int.tryParse(yearsController.text) ?? 0;

    if (years > 0) {
      double remainingAmount = targetAmount - currentSavings;
      monthlySavings = remainingAmount / (years * 12);
    } else {
      monthlySavings = 0;
    }

    setState(() {});
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Ready Cash Calculator',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          buildTextField('Target Amount (₹)', targetAmountController),
          buildTextField('Current Savings (₹)', currentSavingsController),
          buildTextField('Years to Goal', yearsController),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: calculateMonthlySavings,
            child: Text('Calculate Monthly Savings'),
          ),
          SizedBox(height: 20),
          Text('Monthly Savings Required: ₹${monthlySavings.toStringAsFixed(2)}'),
          const SizedBox(height: 30),
          const Text('Available Loan Rates:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          // ConstrainedBox to limit the height of the loan rates list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
            ),
            child: widget.loanRates.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: widget.loanRates.length,
                    itemBuilder: (context, index) {
                      final rate = widget.loanRates[index];
                      return ListTile(
                        title: Text(rate['bank_name'] ?? 'Unknown Bank'),
                        subtitle: Text('Rate: ${rate['rate']?.toString() ?? 'N/A'}%'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
  

class EMICalculator extends StatefulWidget {
  final Function(double) onEMICalculated;

  const EMICalculator({Key? key, required this.onEMICalculated}) : super(key: key);

  @override
  _EMICalculatorState createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  TextEditingController loanController = TextEditingController(text: "7500000");
  TextEditingController interestController = TextEditingController(text: "8");
  TextEditingController tenureController = TextEditingController(text: "15");
  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;

  void calculateEMI() {
    double loanAmount = double.tryParse(loanController.text) ?? 0;
    double interestRate = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
    int tenureMonths = (int.tryParse(tenureController.text) ?? 0) * 12;

    if (interestRate > 0) {
      emi = (loanAmount * interestRate * pow(1 + interestRate, tenureMonths)) /
          (pow(1 + interestRate, tenureMonths) - 1);
      totalPayment = emi * tenureMonths;
      totalInterest = totalPayment - loanAmount;
    } else {
      emi = loanAmount / tenureMonths;
      totalPayment = loanAmount;
      totalInterest = 0;
    }

    setState(() {});
    widget.onEMICalculated(emi);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: loanController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Loan Amount (₹)',
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: interestController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Interest Rate (%)',
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: tenureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Tenure (Years)',
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: calculateEMI,
            child: Text('Calculate EMI'),
          ),
          SizedBox(height: 20),
          Text('Monthly EMI: ₹${emi.toStringAsFixed(2)}'),
          Text('Total Interest Payable: ₹${totalInterest.toStringAsFixed(2)}'),
          Text('Total Payment (Principal + Interest): ₹${totalPayment.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}