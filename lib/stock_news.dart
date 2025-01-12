import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockNewsPage extends StatefulWidget {
  const StockNewsPage({super.key});

  @override
  State<StockNewsPage> createState() => _StockNewsPageState();
}

class _StockNewsPageState extends State<StockNewsPage> {
  List<dynamic> stockNews = [];

  @override
  void initState() {
    super.initState();
    fetchStockNews();
  }

  Future<void> fetchStockNews() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:5000/stock-news'));

    if (response.statusCode == 200) {
      setState(() {
        stockNews = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load stock news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock News'),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: stockNews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stockNews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(stockNews[index]['title']),
                  subtitle: Text(stockNews[index]['link']),
                  onTap: () {
                    // Handle onTap if you want to open the link
                  },
                );
              },
            ),
    );
  }
}
