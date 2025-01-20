import 'package:flutter/material.dart';
import 'stock_page.dart'; // Import the StockDataPage

class StockListPage extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [
    {
      'name': 'Reliance Industries',
      'symbol': 'RELIANCE',
      'symbolToken': '28859'
    },
    {
      'name': 'Tata Consultancy Services',
      'symbol': 'TCS',
      'symbolToken': '1300'
    },
    {'name': 'HDFC Bank', 'symbol': 'HDFCBANK', 'symbolToken': '500112'},
    {'name': 'Infosys', 'symbol': 'INFY', 'symbolToken': '1594'},
    {'name': 'State Bank of India', 'symbol': 'SBIN', 'symbolToken': '3045'},
  ];

  StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Indian Stock Market'),
        centerTitle: true,
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
