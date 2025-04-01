import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockDataPage extends StatefulWidget {
  final String symbolToken;
  final String stockName;
  final String stockDocumentId;

  const StockDataPage({
    required this.symbolToken,
    required this.stockName,
    required this.stockDocumentId,
    super.key,
  });

  @override
  State<StockDataPage> createState() => _StockDataPageState();
}

class _StockDataPageState extends State<StockDataPage> {
  String _response = '';
  List<CandlestickData> _candlestickData = [];
  double? _lastPrice;

  Future<void> fetchHistoricalData() async {
    final String fromDate = '2000-01-01 00:00';
    final String toDate = '2025-03-27 11:15';

    final url = Uri.parse('http://127.0.0.1:5000/fetch_historical_data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'symboltoken': widget.symbolToken,
        'fromdate': fromDate,
        'todate': toDate,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _response = 'Data fetched successfully';
            _candlestickData = List<CandlestickData>.from(
              data['data']['data'].map((item) => CandlestickData(
                    DateTime.parse(item[0]),
                    item[1].toDouble(),
                    item[2].toDouble(),
                    item[3].toDouble(),
                    item[4].toDouble(),
                    item[5].toDouble(),
                  )),
            );
            if (_candlestickData.isNotEmpty) {
              _lastPrice = _candlestickData.last.close;
            }
          });
        } else {
          setState(() {
            _response = 'Error: ${data['message']}';
          });
        }
      } catch (e) {
        setState(() {
          _response = 'Error decoding response: $e';
        });
      }
    } else {
      setState(() {
        _response = 'Error: ${response.body}';
      });
    }
  }

  void _addInvestmentToPortfolio(String shares, double amount) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login to invest')),
    );
    return;
  }

  try {
    // Reference to the user's investments document
    final userInvestmentsRef = FirebaseFirestore.instance
        .collection('user_investments')
        .doc(user.uid);

    // Get the current investments
    final docSnapshot = await userInvestmentsRef.get();
    
    // Prepare the new investment data
    final newInvestmentData = {
      'shares': int.parse(shares),
      'purchasePrice': _lastPrice,
      'totalInvestment': amount,
      'investmentDate': Timestamp.now(),
    };

    // If the document exists, update or add to the existing investments
    if (docSnapshot.exists) {
      // Get the current investments map
      Map<String, dynamic> currentInvestments = 
          Map<String, dynamic>.from(docSnapshot.data() ?? {});

      // Update or add the investment for this specific stock
      currentInvestments[widget.stockName] = newInvestmentData;

      // Update the entire document
      await userInvestmentsRef.set(currentInvestments, SetOptions(merge: true));
    } else {
      // Create a new document with the first investment
      await userInvestmentsRef.set({
        widget.stockName: newInvestmentData
      });
    }

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '₹$amount invested in ${widget.stockName} for $shares shares!',
        ),
      ),
    );
  } catch (e) {
    // Show error message if something goes wrong
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
  void _showInvestmentDialog() {
    final TextEditingController sharesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Invest in Stock',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: sharesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter number of shares to invest',
              prefixText: 'Shares: ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredShares = sharesController.text;
                if (enteredShares.isNotEmpty && _lastPrice != null) {
                  final totalAmount = double.parse(enteredShares) * _lastPrice!;
                  Navigator.pop(context);
                  _addInvestmentToPortfolio(
                    enteredShares,
                    totalAmount,
                  );
                }
              },
              child: const Text('Invest'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchHistoricalData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stockName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastPrice != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stockName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_lastPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: _showInvestmentDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            Expanded(
              child: _candlestickData.isNotEmpty
                  ? CustomPaint(
                      size: Size(double.infinity, double.infinity),
                      painter: CandlestickChartPainter(_candlestickData),
                    )
                  : _response.isNotEmpty
                      ? Center(child: Text(_response))
                      : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class CandlestickData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandlestickData(
    this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
  );
}

class CandlestickChartPainter extends CustomPainter {
  final List<CandlestickData> data;

  CandlestickChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    final candleWidth = size.width / data.length;
    final chartHeight = size.height;

    final minPrice = data.map((d) => d.low).reduce((a, b) => a < b ? a : b);
    final maxPrice = data.map((d) => d.high).reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );

    for (int i = 0; i <= 5; i++) {
      final y = i * chartHeight / 5;
      final price = maxPrice - (i * priceRange / 5);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final textSpan = TextSpan(
        text: price.toStringAsFixed(2),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width - 40, y - 8));
    }

    for (int i = 0; i < data.length; i++) {
      final candlestick = data[i];

      final double openY = chartHeight -
          ((candlestick.open - minPrice) / priceRange * chartHeight);
      final double closeY = chartHeight -
          ((candlestick.close - minPrice) / priceRange * chartHeight);
      final double highY = chartHeight -
          ((candlestick.high - minPrice) / priceRange * chartHeight);
      final double lowY = chartHeight -
          ((candlestick.low - minPrice) / priceRange * chartHeight);

      paint.color =
          candlestick.close >= candlestick.open ? Colors.green : Colors.red;

      canvas.drawLine(
        Offset(i * candleWidth + candleWidth / 2, highY),
        Offset(i * candleWidth + candleWidth / 2, lowY),
        paint,
      );

      final rect = Rect.fromLTRB(
        i * candleWidth + candleWidth * 0.1,
        openY,
        (i + 1) * candleWidth - candleWidth * 0.1,
        closeY,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}