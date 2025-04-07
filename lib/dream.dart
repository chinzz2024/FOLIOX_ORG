import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class DreamHomeScreen extends StatefulWidget {
  const DreamHomeScreen({super.key});

  @override
  State<DreamHomeScreen> createState() => _DreamHomeScreenState();
}

class _DreamHomeScreenState extends State<DreamHomeScreen> {
  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;
  double downPayment = 0.0;
  double loanAmount = 0.0;
  bool _isLoading = true;
  List<Map<String, dynamic>> assetList = [];
  List<dynamic> loanRates = [];
  User? _currentUser;

  final TextEditingController propertyValueController = TextEditingController();
  final TextEditingController interestController = TextEditingController(text: "8");
  final TextEditingController tenureController = TextEditingController(text: "15");
  final TextEditingController downPaymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _fetchUserAssets();
      _fetchLoanRates();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchUserAssets() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('assets')) {
          Map<String, dynamic> assetsMap = data['assets'];

          setState(() {
            assetList = assetsMap.entries.map((entry) {
              return {
                'name': entry.key,
                'amount': entry.value is int ? entry.value.toDouble() : entry.value,
                'selected': false,
              };
            }).where((asset) => (asset['amount'] ?? 0) > 0).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching assets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load assets: $e')),
      );
    }
  }

  void _showAssetSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Assets for Down Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: assetList.length,
                      itemBuilder: (context, index) {
                        final asset = assetList[index];
                        return CheckboxListTile(
                          title: Text(asset['name']),
                          subtitle: Text('₹${(asset['amount'] ?? 0).toStringAsFixed(2)}'),
                          value: asset['selected'] ?? false,
                          onChanged: (bool? value) {
                            setModalState(() {
                              assetList[index]['selected'] = value ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      double totalSelected = 0;
                      List<Map<String, dynamic>> selectedAssets = [];
                      
                      for (var asset in assetList) {
                        if (asset['selected'] == true) {
                          totalSelected += (asset['amount'] ?? 0).toDouble();
                          selectedAssets.add({
                            'name': asset['name'],
                            'amount': asset['amount'],
                          });
                        }
                      }
                      
                      if (totalSelected > 0) {
                        setState(() {
                          downPaymentController.text = totalSelected.toStringAsFixed(2);
                          calculateEMI();
                        });
                        _updateAssetsInFirestore(selectedAssets);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text('Apply Selected Assets'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateAssetsInFirestore(List<Map<String, dynamic>> selectedAssets) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final userDocRef = FirebaseFirestore.instance
          .collection('financialPlanner')
          .doc(_currentUser!.uid);

      // Get current assets
      final snapshot = await userDocRef.get();
      final currentAssets = snapshot.data()?['assets'] ?? {};

      // Update each selected asset
      for (final asset in selectedAssets) {
        final assetName = asset['name'];
        final amountUsed = asset['amount'];
        final currentAmount = currentAssets[assetName] ?? 0;
        final newAmount = currentAmount - amountUsed;

        batch.update(userDocRef, {
          'assets.$assetName': newAmount,
        });
      }

      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assets updated successfully!')),
      );

      // Refresh assets
      _fetchUserAssets();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update assets: $e')),
      );
    }
  }

  Future<void> _fetchLoanRates() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/loan-rates'));
      if (response.statusCode == 200) {
        setState(() {
          loanRates = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load loan rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching loan rates: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading loan rates: $e')),
      );
    }
  }

  void calculateEMI() {
    double propertyValue = double.tryParse(propertyValueController.text) ?? 0;
    downPayment = double.tryParse(downPaymentController.text) ?? 0;
    double interestRate = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
    int tenureMonths = (int.tryParse(tenureController.text) ?? 0) * 12;

    loanAmount = propertyValue - downPayment;

    if (interestRate > 0 && tenureMonths > 0 && loanAmount > 0) {
      emi = (loanAmount * interestRate * pow(1 + interestRate, tenureMonths)) /
          (pow(1 + interestRate, tenureMonths) - 1);
      totalPayment = emi * tenureMonths;
      totalInterest = totalPayment - loanAmount;
    } else {
      emi = 0;
      totalPayment = 0;
      totalInterest = 0;
    }

    setState(() {});
  }

  Future<void> _saveInvestment() async {
    if (_currentUser == null || emi <= 0) return;

    try {
      // Get selected assets
      final selectedAssets = assetList.where((a) => a['selected'] == true).toList();
      double totalInvested = selectedAssets.fold(0, (sum, asset) => sum + (asset['amount'] ?? 0));

      // Prepare investment data matching dreamCar/retirement structure
      final investmentData = {
        'goal': 'Dream Home',
        'lastUpdated': FieldValue.serverTimestamp(),
        'monthlyTarget': emi,
        'targetAmount': double.tryParse(propertyValueController.text) ?? 0,
        'totalInvested': totalInvested,
        'loanDetails': {
          'loanAmount': loanAmount,
          'interestRate': double.tryParse(interestController.text) ?? 0,
          'tenureYears': int.tryParse(tenureController.text) ?? 0,
        },
        'assetsUsed': selectedAssets.map((a) => {
          'name': a['name'],
          'amount': a['amount'],
        }).toList(),
      };

      // Save to investments collection with same structure
      await FirebaseFirestore.instance
          .collection('investments')
          .doc(_currentUser!.uid)
          .update({
            'dreamHome': investmentData,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dream Home investment saved successfully!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save investment: $e')),
      );
    }
  }

  Widget _buildAssetItem(Map<String, dynamic> asset) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          asset['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('₹${(asset['amount'] ?? 0).toStringAsFixed(2)}'),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              double currentDownPayment = double.tryParse(downPaymentController.text) ?? 0;
              double assetValue = (asset['amount'] ?? 0).toDouble();
              downPaymentController.text = (currentDownPayment + assetValue).toStringAsFixed(2);
            });
            calculateEMI();
          },
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: isEditable,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) => calculateEMI(),
      ),
    );
  }

  Widget _buildLoanRateItem(dynamic rate) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(rate['bank_name'] ?? 'Unknown Bank'),
        subtitle: Text('Interest Rate: ${rate['rate']?.toString() ?? 'N/A'}%'),
        
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dream Home', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 12, 6, 37),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dream Home', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                fontSize: 22,)),
        backgroundColor: Color(0xFF0F2027),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Loan EMI Calculator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildInputField('Property Value (₹)', propertyValueController),
            _buildInputField('Down Payment (₹)', downPaymentController),
            _buildInputField('Interest Rate (%)', interestController),
            _buildInputField('Loan Tenure (Years)', tenureController),
            
            if (assetList.isNotEmpty) ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showAssetSelectionBottomSheet,
                child: Text('Select Assets for Down Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            if (emi > 0) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('EMI Calculation Results',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _buildResultRow('Property Value', '₹${propertyValueController.text}'),
                      _buildResultRow('Down Payment', '₹${downPaymentController.text}'),
                      _buildResultRow('Loan Amount', '₹${loanAmount.toStringAsFixed(2)}'),
                      Divider(),
                      _buildResultRow('Monthly EMI', '₹${emi.toStringAsFixed(2)}'),
                      _buildResultRow('Total Interest', '₹${totalInterest.toStringAsFixed(2)}'),
                      _buildResultRow('Total Payment', '₹${totalPayment.toStringAsFixed(2)}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveInvestment,
                        child: Text('Invest in this Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            
            
            SizedBox(height: 20),
            Text('Available Home Loan Rates',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (loanRates.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Loading loan rates...',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              Column(children: loanRates.map((rate) => _buildLoanRateItem(rate)).toList()),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
