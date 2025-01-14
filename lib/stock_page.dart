import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockDataPage extends StatefulWidget {
  const StockDataPage({super.key});

  @override
  State<StockDataPage> createState() => _StockDataPageState();
}

class _StockDataPageState extends State<StockDataPage> {
  String authToken = ''; // Store authToken after login
  String _response = '';
  TextEditingController _totpController = TextEditingController();
  List<Map<String, dynamic>> _historicalData = []; // To store historical data

  // Function to login
  Future<void> login(String totpToken) async {
    final url = Uri.parse('http://127.0.0.1:5000/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'totp_token': totpToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        authToken = data['authToken'];
      });
      print('Login Successful');
    } else {
      print('Login Failed');
    }
  }

  // Function to fetch historical data
  Future<void> fetchHistoricalData() async {
    if (authToken.isEmpty) {
      setState(() {
        _response = 'Please log in first.';
      });
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5000/fetch_historical_data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'authToken': authToken,
        'symboltoken': '3045', // Example symbol token
        'fromdate': '2021-02-08 09:00',
        'todate': '2021-02-08 09:16',
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body); // Decode the response body
        if (data['status'] == true) {
          // Ensure that the data is a list and assign it correctly
          setState(() {
            _historicalData = List<Map<String, dynamic>>.from(
              data['data'].map((item) {
                return {
                  'timestamp': item[0],
                  'open': item[1],
                  'high': item[2],
                  'low': item[3],
                  'close': item[4],
                  'volume': item[5],
                };
              }),
            );
          });
          print('Data fetched successfully');
        } else {
          setState(() {
            _response = 'Error: ${data['message']}';
          });
        }
      } catch (e) {
        setState(() {
          _response = 'Error decoding response: $e';
        });
        print('Failed to decode response: $e');
      }
    } else {
      setState(() {
        _response = 'Error: ${response.body}';
      });
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _totpController,
              decoration: const InputDecoration(
                labelText: 'Enter TOTP Token',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await login(_totpController.text);
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: fetchHistoricalData,
              child: const Text('Fetch Historical Data'),
            ),
            const SizedBox(height: 20),
            if (_response.isNotEmpty) Text(_response),
            const SizedBox(height: 20),
            if (_historicalData.isNotEmpty)
              DataTable(
                columns: const [
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('Open')),
                  DataColumn(label: Text('High')),
                  DataColumn(label: Text('Low')),
                  DataColumn(label: Text('Close')),
                  DataColumn(label: Text('Volume')),
                ],
                rows: _historicalData.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data['timestamp'])),
                    DataCell(Text(data['open'].toString())),
                    DataCell(Text(data['high'].toString())),
                    DataCell(Text(data['low'].toString())),
                    DataCell(Text(data['close'].toString())),
                    DataCell(Text(data['volume'].toString())),
                  ]);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
