import 'package:flutter/material.dart';
import 'dart:math';

class DreamcarPage extends StatefulWidget {
  const DreamcarPage({super.key});

  @override
  _DreamcarPageState createState() => _DreamcarPageState();
}

class _DreamcarPageState extends State<DreamcarPage> {
  bool isEMISelected = false;
  double emi = 0.0;
  double monthlySavings = 0.0;
  double progress = 0.0;

  // Controllers
  late final TextEditingController targetAmountController;
  late final TextEditingController currentSavingsController;
  late final TextEditingController yearsController;
  late final TextEditingController loanAmountController;
  late final TextEditingController interestController;
  late final TextEditingController tenureController;

  @override
  void initState() {
    super.initState();
    targetAmountController = TextEditingController();
    currentSavingsController = TextEditingController();
    yearsController = TextEditingController();
    loanAmountController = TextEditingController(text: "500000");
    interestController = TextEditingController(text: "8");
    tenureController = TextEditingController(text: "5");

    // Add listeners that schedule calculations after build
    targetAmountController.addListener(_scheduleSavingsCalculation);
    currentSavingsController.addListener(_scheduleSavingsCalculation);
    yearsController.addListener(_scheduleSavingsCalculation);
  }

  @override
  void dispose() {
    targetAmountController.dispose();
    currentSavingsController.dispose();
    yearsController.dispose();
    loanAmountController.dispose();
    interestController.dispose();
    tenureController.dispose();
    super.dispose();
  }

  void _scheduleSavingsCalculation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateMonthlySavings();
    });
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
            loanAmountController: loanAmountController,
            interestController: interestController,
            tenureController: tenureController,
          ),
        );
      },
    );
  }

  void calculateMonthlySavings() {
    double targetAmount = double.tryParse(targetAmountController.text) ?? 0;
    double currentSavings = double.tryParse(currentSavingsController.text) ?? 0;
    int years = int.tryParse(yearsController.text) ?? 0;

    if (years > 0) {
      double remainingAmount = targetAmount - currentSavings;
      setState(() {
        monthlySavings = remainingAmount / (years * 12);
        progress = targetAmount > 0 ? (currentSavings / targetAmount) * 100 : 0;
      });
    } else {
      setState(() {
        monthlySavings = 0;
        progress = 0;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Dream Car Calculator', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How do you want to buy your car?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEMISelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isEMISelected ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Ready Cash', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    showEMICalculator(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEMISelected ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('EMI', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            if (!isEMISelected) ...[
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
              Text('Monthly Savings Required: ₹${monthlySavings.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 5),
              Text('Progress: ${progress.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 14)),
            ],
            if (isEMISelected && emi > 0) ...[
              SizedBox(height: 20),
              Text('EMI Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Loan Amount:'),
                          Text('₹${loanAmountController.text}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Interest Rate:'),
                          Text('${interestController.text}%'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tenure:'),
                          Text('${tenureController.text} years'),
                        ],
                      ),
                      Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly EMI:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₹${emi.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EMICalculator extends StatefulWidget {
  final Function(double) onEMICalculated;
  final TextEditingController loanAmountController;
  final TextEditingController interestController;
  final TextEditingController tenureController;

  const EMICalculator({
    Key? key,
    required this.onEMICalculated,
    required this.loanAmountController,
    required this.interestController,
    required this.tenureController,
  }) : super(key: key);

  @override
  _EMICalculatorState createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;

  @override
  void initState() {
    super.initState();
    widget.loanAmountController.addListener(_scheduleEMICalculation);
    widget.interestController.addListener(_scheduleEMICalculation);
    widget.tenureController.addListener(_scheduleEMICalculation);
    // Calculate initial EMI after build
    WidgetsBinding.instance.addPostFrameCallback((_) => calculateEMI());
  }

  @override
  void dispose() {
    widget.loanAmountController.removeListener(_scheduleEMICalculation);
    widget.interestController.removeListener(_scheduleEMICalculation);
    widget.tenureController.removeListener(_scheduleEMICalculation);
    super.dispose();
  }

  void _scheduleEMICalculation() {
    WidgetsBinding.instance.addPostFrameCallback((_) => calculateEMI());
  }

  void calculateEMI() {
    double loanAmount = double.tryParse(widget.loanAmountController.text) ?? 0;
    double interestRate = double.tryParse(widget.interestController.text) ?? 0;
    int tenureYears = int.tryParse(widget.tenureController.text) ?? 0;
    int tenureMonths = tenureYears * 12;

    if (interestRate > 0 && tenureMonths > 0) {
      double monthlyInterestRate = interestRate / 12 / 100;
      emi = (loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, tenureMonths)) /
          (pow(1 + monthlyInterestRate, tenureMonths) - 1);
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
          Text('EMI Calculator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: widget.loanAmountController,
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
              controller: widget.interestController,
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
              controller: widget.tenureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Tenure (Years)',
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              calculateEMI();
              Navigator.pop(context);
            },
            child: Text('Calculate EMI'),
          ),
          SizedBox(height: 20),
          Text('Monthly EMI: ₹${emi.toStringAsFixed(2)}'),
          Text('Total Interest Payable: ₹${totalInterest.toStringAsFixed(2)}'),
          Text('Total Payment: ₹${totalPayment.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}