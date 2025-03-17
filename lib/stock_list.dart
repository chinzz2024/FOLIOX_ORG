import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_page.dart';
import 'home_page.dart';

class StockListPage extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [
    {'name': 'Reliance Industries', 'symbol': 'RELIANCE.NS', 'symbolToken': '2885'},
    {'name': 'Tata Consultancy Services', 'symbol': 'TCS.NS', 'symbolToken': '11536'},
    {'name': 'HDFC Bank', 'symbol': 'HDFCBANK.NS', 'symbolToken': '1333'},
    {'name': 'HITECH', 'symbol': 'HITECH.NS', 'symbolToken': '2868'},
    {'name': 'State Bank of India', 'symbol': 'SBIN.NS', 'symbolToken': '3045'},
    {'name': 'Dixon', 'symbol': 'DIXON.NS', 'symbolToken': '21690'},
  ];

  StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Container(
        color: const Color(0xFFF2F6FC),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: Icon(Icons.show_chart, color: Colors.blue.shade700),
                title: Text(
                  stock['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  stock['symbol'],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
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
                      SnackBar(content: Text('Stock ${stock['name']} not found in database')),
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
