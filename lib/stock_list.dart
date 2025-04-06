import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_page.dart';
import 'home_page.dart';

class StockListPage extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [

    {'name': 'Reliance Industries', 'symbol': 'RELIANCE', 'symbolToken': '2885'},
    {'name': 'Tata Consultancy Services', 'symbol': 'TCS', 'symbolToken': '11536'},
        {'name': 'HDFC Bank', 'symbol': 'HDFCBANK', 'symbolToken': '1333'},
    {'name': 'Dixon', 'symbol': 'DIXON', 'symbolToken': '21690'},

    {'name': 'Infosys', 'symbol': 'INFY', 'symbolToken': '1594'},
    {'name': 'ICICI Bank', 'symbol': 'ICICIBANK', 'symbolToken': '4963'},
    {'name': 'Hindustan Unilever', 'symbol': 'HINDUNILVR', 'symbolToken': '1394'},
    {'name': 'Bharti Airtel', 'symbol': 'BHARTIARTL', 'symbolToken': '10604'},
    {'name': 'ITC Limited', 'symbol': 'ITC', 'symbolToken': '1660'},
    {'name': 'Larsen & Toubro', 'symbol': 'LT', 'symbolToken': '11483'},
    {'name': 'Asian Paints', 'symbol': 'ASIANPAINT', 'symbolToken': '1363'},
    {'name': 'Kotak Mahindra Bank', 'symbol': 'KOTAKBANK', 'symbolToken': '1922'},
    {'name': 'HITECH', 'symbol': 'HITECH', 'symbolToken': '2868'},
    {'name': 'State Bank of India', 'symbol': 'SBI', 'symbolToken': '3045'},

  ];

  StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
              (route) => false,
            );
          },
        ),
        backgroundColor: Color(0xFF0F2027),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF2F6FC), // Light blue-gray background
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.show_chart, color: Colors.blue.shade700),
                ),
                title: Text(
                  stock['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  stock['symbol'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
                onTap: () async {
                  String? documentId = await _getStockDocumentId(stock['symbol']);

                  if (documentId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDataPage(
                          symbolToken: stock['symbolToken'],
                          stockName: stock['name'],
                          stockDocumentId: documentId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stock ${stock['name']} not found in database'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String?> _getStockDocumentId(String symbol) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stocks')
          .where('symbol', isEqualTo: symbol)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error fetching stock document ID: $e');
      return null;
    }
  }
}