import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'stock_page.dart'; // Import the StockDataPage
import 'home_page.dart';

class StockListPage extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [
    {
      'name': 'Reliance Industries',
      'symbol': 'RELIANCE.NS', // Corrected stock symbol for Reliance Industries
      'symbolToken': '2885'
    },
    {
      'name': 'Tata Consultancy Services',
      'symbol': 'TCS.NS', // Corrected stock symbol for TCS
      'symbolToken': '11536'
    },
    {
      'name': 'HDFC Bank',
      'symbol': 'HDFCBANK.NS', // Corrected stock symbol for HDFC Bank
      'symbolToken': '1333'
    },
    {
      'name': 'HITECH',
      'symbol':
          'HITECH.NS', // Assuming HITECH is a valid stock, adjusted format
      'symbolToken': '2868'
    },
    {
      'name': 'State Bank of India',
      'symbol': 'SBIN.NS', // Corrected stock symbol for State Bank of India
      'symbolToken': '3045'
    },
  ];

  StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock News', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to Homepage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
              (route) => false, // Clear all previous routes
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return ListTile(
            title: Text(
              stock['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(stock['symbol']),
            onTap: () async {
              // Fetch the document ID from Firestore
              String? documentId = await _getStockDocumentId(stock['symbol']);

              if (documentId != null) {
                // Navigate to StockDataPage with the documentId and stock details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockDataPage(
                      symbolToken: stock['symbolToken'],
                      stockName: stock['name'],
                      stockDocumentId: documentId, // Pass the document ID
                    ),
                  ),
                );
              } else {
                // Show an error if the stock is not found
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Stock ${stock['name']} not found in database')),
                );
              }
            },
          );
        },
      ),
    );
  }

  // Function to fetch the stock document ID based on the symbol
  Future<String?> _getStockDocumentId(String symbol) async {
    try {
      // Query Firestore collection `stocks` where the `symbol` matches
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stocks')
          .where('symbol', isEqualTo: symbol)
          .limit(1)
          .get();

      // If a matching document is found, return its document ID
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null; // Return null if no document is found
    } catch (e) {
      print('Error fetching stock document ID: $e');
      return null;
    }
  }
}
