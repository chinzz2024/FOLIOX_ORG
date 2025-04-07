import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockSell extends StatefulWidget {
  const StockSell({super.key});

  @override
  State<StockSell> createState() => _StockSellState();
}

class _StockSellState extends State<StockSell> {
  // Fetch user's stocks from Firestore user_investments collection
  Future<List<Map<String, dynamic>>> _fetchUserStocks() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return [];
      }

      // Fetch the user's investments document
      DocumentSnapshot userInvestmentsDoc = await FirebaseFirestore.instance
          .collection('user_investments')
          .doc(currentUser.uid)
          .get();

      // Check if the document exists and has data
      if (!userInvestmentsDoc.exists || userInvestmentsDoc.data() == null) {
        return [];
      }

      // Convert the document data to a map
      Map<String, dynamic> investmentsData = 
          userInvestmentsDoc.data() as Map<String, dynamic>;

      // Transform the investments into a list of stock maps
      List<Map<String, dynamic>> userStocks = investmentsData.entries.map((entry) {
        // Calculate asset value (quantity * current price)
        double currentPrice = entry.value['purchasePrice'] ?? 0.0;
        int shares = entry.value['shares'] ?? 0;
        double assetValue = currentPrice * shares;
        
        return {
          'companyName': entry.key, // Stock name is now the key
          'quantity': entry.value['shares'],
          'currentPrice': currentPrice,
          'investmentDate': entry.value['investmentDate'],
          'totalInvestment': entry.value['totalInvestment'],
          'assetValue': assetValue
        };
      }).toList();

      return userStocks;
    } catch (e) {
      print('Error fetching stocks: $e');
      return [];
    }
  }

  // Sell stock method
  void _sellStock(String stockName, int quantity, double currentPrice) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Reference to the user's investments document
      DocumentReference userInvestmentsRef = FirebaseFirestore.instance
          .collection('user_investments')
          .doc(currentUser.uid);

      // Get current investments
      DocumentSnapshot currentInvestmentsDoc = await userInvestmentsRef.get();
      Map<String, dynamic> investmentsData = 
          currentInvestmentsDoc.data() as Map<String, dynamic>;

      // Get the specific stock's investment data
      Map<String, dynamic> stockInvestment = investmentsData[stockName];

      // Calculate remaining shares
      int remainingShares = stockInvestment['shares'] - quantity;

      // Update or remove the stock from investments
      if (remainingShares > 0) {
        investmentsData[stockName]['shares'] = remainingShares;
        await userInvestmentsRef.update(investmentsData);
      } else {
        // Remove the stock if no shares remain
        investmentsData.remove(stockName);
        await userInvestmentsRef.set(investmentsData);
      }

      // Add transaction to user's transaction history
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': currentUser.uid,
        'stockName': stockName,
        'type': 'sell',
        'quantity': quantity,
        'price': currentPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Refresh the UI
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock sold successfully!')),
      );
    } catch (e) {
      print('Error selling stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sell stock')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Stocks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
        backgroundColor: Color(0xFF0F2027),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserStocks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No stocks in your portfolio',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate total portfolio value
          double totalPortfolioValue = snapshot.data!.fold(
            0, (sum, stock) => sum + (stock['assetValue'] ?? 0));

          return Column(
            children: [
              // Portfolio summary card
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₹${totalPortfolioValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stock list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var stock = snapshot.data![index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    stock['companyName'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Qty: ${stock['quantity']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Price: ₹${stock['currentPrice']?.toStringAsFixed(2) ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Asset Value: ₹${stock['assetValue']?.toStringAsFixed(2) ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Show sell dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        int sellQuantity = 1;
                                        return AlertDialog(
                                          title: Text('Sell ${stock['companyName']}'),
                                          content: StatefulBuilder(
                                            builder: (context, setState) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Select quantity to sell:'),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.remove),
                                                        onPressed: () {
                                                          if (sellQuantity > 1) {
                                                            setState(() {
                                                              sellQuantity--;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      Text(
                                                        '$sellQuantity',
                                                        style: TextStyle(fontSize: 20),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.add),
                                                        onPressed: () {
                                                          if (sellQuantity < stock['quantity']) {
                                                            setState(() {
                                                              sellQuantity++;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'Amount: ₹${(sellQuantity * stock['currentPrice']).toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton(
                                              child: Text('Sell'),
                                              onPressed: () {
                                                _sellStock(
                                                  stock['companyName'],
                                                  sellQuantity,
                                                  stock['currentPrice']
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 242, 9, 9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Sell', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}