import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockPage extends StatefulWidget {
  final String symbol;

  const StockPage({super.key, required this.symbol});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late Future<List<StockData>> stockData;

  @override
  void initState() {
    super.initState();
    stockData = fetchStockData(widget.symbol);
  }

  Future<List<StockData>> fetchStockData(String symbol) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:5000/stock-info/$symbol'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => StockData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: FutureBuilder<List<StockData>>(
        future: stockData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stock data available.'));
          } else {
            final stockDataList = snapshot.data!;
            return ListView.builder(
              itemCount: stockDataList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Price: ${stockDataList[index].price}'),
                    subtitle: Text('Date: ${stockDataList[index].date}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class StockData {
  final double price;
  final String date;

  StockData({required this.price, required this.date});

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      price: json['price'].toDouble(),
      date: json['date'],
    );
  }
}
