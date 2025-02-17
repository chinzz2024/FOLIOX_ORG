import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'calculation_page.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController dearnessAllowanceController = TextEditingController();
  final TextEditingController houseRentAllowanceController = TextEditingController();
  final TextEditingController transportAllowanceController = TextEditingController();
  final TextEditingController providentFundController = TextEditingController();
  final TextEditingController incomeTaxController = TextEditingController();
  final TextEditingController professionalTaxController = TextEditingController();
  final TextEditingController licController = TextEditingController();
  final TextEditingController vehicleLoanController = TextEditingController();
  final TextEditingController housingRentController = TextEditingController();
  final TextEditingController utilitiesController = TextEditingController();
  final TextEditingController transportationController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  @override
  void dispose() {
    baseSalaryController.dispose();
    dearnessAllowanceController.dispose();
    houseRentAllowanceController.dispose();
    transportAllowanceController.dispose();
    providentFundController.dispose();
    incomeTaxController.dispose();
    professionalTaxController.dispose();
    licController.dispose();
    vehicleLoanController.dispose();
    housingRentController.dispose();
    utilitiesController.dispose();
    transportationController.dispose();
    educationController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore(double income, double deduction, double expenditure, double savings) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('planner').doc(userId).set({
          'Income': income,
          'Deduction': deduction,
          'Expenditure': expenditure,
          'Savings': savings,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data saved successfully!')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data: $error')));
      }
    }
  }

  Future<void> _fetchDataAndNavigate() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('planner').doc(userId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final savings = (data['Savings'] ?? 0).toDouble();
          Navigator.push(context, MaterialPageRoute(builder: (context) => CalculationPage(savings: savings)));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch data: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Income Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            _buildTextField('Base Salary', baseSalaryController),
            _buildTextField('Dearness Allowance', dearnessAllowanceController),
            _buildTextField('House Rent Allowance (HRA)', houseRentAllowanceController),
            _buildTextField('Transport Allowance', transportAllowanceController),
            const SizedBox(height: 16.0),
            const Text('Deduction Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            _buildTextField('Provident Fund', providentFundController),
            _buildTextField('Income Tax', incomeTaxController),
            _buildTextField('Professional Tax', professionalTaxController),
            _buildTextField('LIC/Other Insurances', licController),
            _buildTextField('Vehicle/Other Loans', vehicleLoanController),
            const SizedBox(height: 16.0),
            const Text('Expenditure Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            _buildTextField('Housing And Utilities', housingRentController),
            _buildTextField('Transportation', transportationController),
            _buildTextField('Education', educationController),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final income = (double.tryParse(baseSalaryController.text) ?? 0) +
                      (double.tryParse(dearnessAllowanceController.text) ?? 0) +
                      (double.tryParse(houseRentAllowanceController.text) ?? 0) +
                      (double.tryParse(transportAllowanceController.text) ?? 0);
                  final deduction = (double.tryParse(providentFundController.text) ?? 0) +
                      (double.tryParse(incomeTaxController.text) ?? 0) +
                      (double.tryParse(professionalTaxController.text) ?? 0) +
                      (double.tryParse(licController.text) ?? 0) +
                      (double.tryParse(vehicleLoanController.text) ?? 0);
                  final expenditure = (double.tryParse(housingRentController.text) ?? 0) +
                      (double.tryParse(utilitiesController.text) ?? 0) +
                      (double.tryParse(transportationController.text) ?? 0) +
                      (double.tryParse(educationController.text) ?? 0);
                  final savings = income - (deduction + expenditure);

                  _saveToFirestore(income, deduction, expenditure, savings);
                },
                child: const Text('Update Savings'),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _fetchDataAndNavigate,
                child: const Text('Plan'),
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
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
