import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockDataPage extends StatefulWidget {
  final String symbolToken;
  final String stockName;

  const StockDataPage(
      {required this.symbolToken, required this.stockName, super.key});

  @override
  State<StockDataPage> createState() => _StockDataPageState();
}

class _StockDataPageState extends State<StockDataPage> {
  String _response = '';
  List<CandlestickData> _candlestickData = [];

  // Function to fetch historical data
  Future<void> fetchHistoricalData() async {
    final String fromDate = '2000-01-01 00:00';
    final String toDate = '2025-01-17 15:30';

    final url = Uri.parse('http://192.168.157.137:5000/fetch_historical_data');
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
      body: Center(
        child: _candlestickData.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomPaint(
                  size: Size(double.infinity, 400),
                  painter: CandlestickChartPainter(_candlestickData),
                ),
              )
            : _response.isNotEmpty
                ? SingleChildScrollView(
                    child: Text(
                      _response,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}

// Data model for candlestick
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

// Custom painter for candlestick chart
class CandlestickChartPainter extends CustomPainter {
  final List<CandlestickData> data;

  CandlestickChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double candleWidth = size.width / data.length;
    final double chartHeight = size.height;

    final double minPrice =
        data.map((d) => d.low).reduce((a, b) => a < b ? a : b);
    final double maxPrice =
        data.map((d) => d.high).reduce((a, b) => a > b ? a : b);
    final double priceRange = maxPrice - minPrice;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke;
    for (int i = 0; i <= 5; i++) {
      final y = i * chartHeight / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
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

      final bool isIncrease = candlestick.close >= candlestick.open;
      paint.color = isIncrease ? Colors.green : Colors.red;

      canvas.drawLine(
        Offset(i * candleWidth + candleWidth / 2, highY),
        Offset(i * candleWidth + candleWidth / 2, lowY),
        paint..strokeWidth = 2,
      );

      canvas.drawRect(
        Rect.fromLTRB(
          i * candleWidth + candleWidth * 0.2,
          openY,
          (i + 1) * candleWidth - candleWidth * 0.2,
          closeY,
        ),
        paint,
      );
    }

    // Draw price labels
    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    for (int i = 0; i <= 5; i++) {
      final price = minPrice + (priceRange / 5) * i;
      textPainter.text = TextSpan(
        text: price.toStringAsFixed(2),
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, chartHeight - (i * chartHeight / 5)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
