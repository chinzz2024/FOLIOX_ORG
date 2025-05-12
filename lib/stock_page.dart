import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'stock_list.dart';
import 'package:http/http.dart' as http;

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
  Razorpay? _razorpay;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    fetchHistoricalData();
    _initRazorpay();
  }

  void _initRazorpay() {
    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      debugPrint('Error initializing Razorpay: $e');
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> fetchHistoricalData() async {
    try {
      final String fromDate = '2000-01-01 00:00';
      final String toDate = '2025-04-26 12:00';

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
      } else {
        setState(() {
          _response = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  // Create Razorpay order through your backend
  Future<Map<String, dynamic>> _createRazorpayOrder(double amount, String shares) async {
    try {
      // Update with your actual backend URL
      final url = Uri.parse('http://127.0.0.1:5000/create-razorpay-order');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': 'INR',
          'receipt': 'stock_${widget.stockDocumentId}_${DateTime.now().millisecondsSinceEpoch}',
          'notes': {
            'shares': shares,
            'stock_name': widget.stockName,
            'symbol_token': widget.symbolToken
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return responseData;
        } else {
          throw Exception('Failed to create order: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating Razorpay order: $e');
      throw e;
    }
  }

  // Get order details from your backend
  Future<Map<String, dynamic>> _getOrderDetails(String orderId) async {
    try {
      // Update with your actual backend URL
      final url = Uri.parse('http://127.0.0.1:5000/get-order-details/$orderId');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return responseData;
        } else {
          throw Exception('Failed to get order details: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to get order details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting order details: $e');
      throw e;
    }
  }

  // Verify payment through your backend
  Future<bool> _verifyPayment(String orderId, String paymentId, String signature) async {
    try {
      // Update with your actual backend URL
      final url = Uri.parse('http://127.0.0.1:5000/verify-payment');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      setState(() => _isProcessingPayment = true);
      
      debugPrint('Payment successful: ${response.orderId}, ${response.paymentId}');
      
      // Verify the payment first
      final isVerified = await _verifyPayment(
        response.orderId ?? '',
        response.paymentId ?? '',
        response.signature ?? ''
      );
      
      if (!isVerified) {
        throw Exception('Payment verification failed');
      }
      
      // Get order details from your server to get the shares
      final orderDetails = await _getOrderDetails(response.orderId ?? '');
      final shares = orderDetails['notes']['shares'];
      final amount = double.parse(shares) * _lastPrice!;

      // Add to portfolio only after successful payment
      await _addInvestmentToPortfolio(shares, amount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! ${widget.stockName} shares added'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _isProcessingPayment = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  void _openRazorpayPayment(double amount, String shares) async {
    if (_razorpay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment gateway not initialized')),
      );
      return;
    }

    try {
      setState(() => _isProcessingPayment = true);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();

      // Create order on the server first
      final orderData = await _createRazorpayOrder(amount, shares);
      final orderId = orderData['id']; // Get the order ID from Razorpay

      if (orderId == null) {
        throw Exception('Failed to get order ID from the server');
      }
      
      debugPrint('Created Razorpay order: $orderId');

      final options = {
        'key': 'rzp_test_NsB3oPpNOVdgRa', // Your test key
        'amount': orderData['amount'].toString(), // Use amount from the server (already in paise)
        'currency': orderData['currency'],
        'name': 'Stock Investment',
        'description': 'Buying $shares shares of ${widget.stockName}',
        'order_id': orderId, // Use the server-generated order ID
        'prefill': {
          'contact': userData?['phone'] ?? '9876543210',
          'email': user.email ?? 'user@example.com',
          'name': userData?['name'] ?? 'User',
        },
        'theme': {
          'color': '#0F2027', // Matching your app bar color
        }
      };

      _razorpay?.open(options);
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addInvestmentToPortfolio(String shares, double amount) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to invest')),
      );
      return;
    }

    try {
      final userInvestmentsRef = FirebaseFirestore.instance
          .collection('user_investments')
          .doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userInvestmentsRef);
        
        Map<String, dynamic> currentInvestments = {};
        if (snapshot.exists) {
          currentInvestments = Map<String, dynamic>.from(snapshot.data()!);
        }

        final newShares = int.parse(shares);
        final newInvestmentData = {
          'shares': newShares,
          'purchasePrice': _lastPrice,
          'totalInvestment': amount,
          'investmentDate': Timestamp.now(),
        };

        if (currentInvestments.containsKey(widget.stockName)) {
          final existingStock = currentInvestments[widget.stockName];
          final updatedShares = existingStock['shares'] + newShares;
          final updatedInvestment = existingStock['totalInvestment'] + amount;
          
          currentInvestments[widget.stockName] = {
            'shares': updatedShares,
            'purchasePrice': _lastPrice,
            'totalInvestment': updatedInvestment,
            'investmentDate': existingStock['investmentDate'],
          };
        } else {
          currentInvestments[widget.stockName] = newInvestmentData;
        }

        transaction.set(userInvestmentsRef, currentInvestments);
      });

      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': user.uid,
        'stockName': widget.stockName,
        'type': 'buy',
        'quantity': int.parse(shares),
        'price': _lastPrice,
        'amount': amount,
        'timestamp': Timestamp.now(),
        'status': 'completed',
        'paymentId': 'rzpy_${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding investment: $e'),
          backgroundColor: Colors.red,
        ),
      );
      throw e;
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
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: sharesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter number of shares to invest',
              prefixText: 'Shares: ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredShares = sharesController.text;
                if (enteredShares.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter number of shares')),
                  );
                  return;
                }
                
                if (_lastPrice == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stock price not available')),
                  );
                  return;
                }

                try {
                  final totalAmount = double.parse(enteredShares) * _lastPrice!;
                  Navigator.pop(context);
                  _openRazorpayPayment(totalAmount, enteredShares);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid input: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Invest',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.stockName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: Color(0xFF0F2027),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => StockListPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_lastPrice != null) ...[
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
                      onPressed: _isProcessingPayment ? null : _showInvestmentDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
          if (_isProcessingPayment)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Processing Payment...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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