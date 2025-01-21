import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';

class StockNewsPage extends StatefulWidget {
  const StockNewsPage({super.key});

  @override
  State<StockNewsPage> createState() => _StockNewsPageState();
}

class _StockNewsPageState extends State<StockNewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> stockNews = [];
  List<dynamic> myStockNews = []; // List for saved stock news
  List<String> purchasedStocks = []; // Dynamically fetched purchased stocks
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePurchasedStocks(); // Fetch user's purchased stocks
    fetchStockNews();
  }

  Future<void> _initializePurchasedStocks() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser; // Get current user
      if (user != null) {
        // Fetch user's portfolio from Firestore
        final QuerySnapshot portfolioSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('portfolios')
            .get();

        // Extract stock names and update purchasedStocks
        setState(() {
          purchasedStocks = portfolioSnapshot.docs
              .map((doc) => doc['stockName'] as String)
              .toList();
        });

        // Log the purchased stocks
        debugPrint('Purchased Stocks: $purchasedStocks');
      } else {
        debugPrint('User not logged in');
      }
    } catch (e) {
      debugPrint('Error fetching purchased stocks: $e');
    }
  }

  Future<void> fetchStockNews() async {
    const url = 'http://192.168.86.137:5000/stock-news'; // Backend API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          stockNews = json.decode(response.body);
          isLoading = false;
          _moveMatchingNewsToMyStockNews(); // Check if any stock news matches user's purchased stocks
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load stock news. Please try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  // Function to check if any stock news matches the user's purchased stocks
  void _moveMatchingNewsToMyStockNews() {
    List<dynamic> matchingNews = [];
    for (var news in stockNews) {
      for (var stock in purchasedStocks) {
        if (news['title'] != null && news['title'].toString().contains(stock)) {
          matchingNews.add(
              news); // Add news to "My Stock News" if title contains a purchased stock symbol
        }
      }
    }
    setState(() {
      myStockNews.addAll(matchingNews); // Add matching news to My Stock News
    });

    // Log the saved news to the console for debugging
    debugPrint(
        'Matching News: ${myStockNews.map((news) => news['title']).toList()}');
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  void _saveStockNews(Map<String, dynamic> news) {
    setState(() {
      myStockNews.add(news); // Add the selected news to My Stock News list
    });

    // Log saved news to the console for debugging
    debugPrint('Saved News: ${news['title']}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('News saved to My Stock News')),
    );
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stock News'),
            Tab(text: 'My Stock News'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stock News tab
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: stockNews.length,
                      itemBuilder: (context, index) {
                        final news = stockNews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListTile(
                            title: Text(news['title'] ?? 'No Title'),
                            subtitle: Text(news['link'] ?? 'No Link'),
                            onTap: () => _openUrl(news['link'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () => _saveStockNews(news),
                            ),
                          ),
                        );
                      },
                    ),

          // My Stock News tab
          myStockNews.isEmpty
              ? const Center(child: Text('No saved stock news'))
              : ListView.builder(
                  itemCount: myStockNews.length,
                  itemBuilder: (context, index) {
                    final news = myStockNews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(news['title'] ?? 'No Title'),
                        subtitle: Text(news['link'] ?? 'No Link'),
                        onTap: () => _openUrl(news['link'] ?? ''),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
