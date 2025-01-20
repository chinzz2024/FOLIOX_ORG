import 'package:flutter/material.dart';
import 'stock_page.dart'; // Import the StockDataPage
import 'home_page.dart';

class StockListPage extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [
    {
      'name': 'Reliance Industries',
      'symbol': 'RELIANCE',
      'symbolToken': '2885'
    },
    {
      'name': 'Tata Consultancy Services',
      'symbol': 'TCS',
      'symbolToken': '11536'
    },
    {'name': 'HDFC Bank', 'symbol': 'HDFCBANK', 'symbolToken': '1333'},
    {'name': 'HITECH', 'symbol': 'HITECH', 'symbolToken': '2868'},
    {'name': 'State Bank of India', 'symbol': 'SBIN', 'symbolToken': '3045'},
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
            // Navigate back to Stock Page (Homepage)
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(stock['symbol']),
            onTap: () {
              // Navigate to StockDataPage with symbolToken
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDataPage(
                    symbolToken: stock['symbolToken'],
                    stockName: stock['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
