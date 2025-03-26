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
        return {
          'companyName': entry.key, // Stock name is now the key
          'quantity': entry.value['shares'],
          'currentPrice': entry.value['purchasePrice'],
          'investmentDate': entry.value['investmentDate'],
          'totalInvestment': entry.value['totalInvestment']
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
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
        backgroundColor: Color(0xFF0F2027),
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

          return ListView.builder(
            padding: EdgeInsets.all(16),
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
                          Text(
                            stock['companyName'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
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
                          Text(
                            'Current Price: ₹${stock['currentPrice']?.toStringAsFixed(2) ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
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
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Sell',style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ],
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