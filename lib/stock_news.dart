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
  List<dynamic> myStockNews = [];
  List<String> purchasedStocks = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePurchasedStocks();
    fetchStockNews();
  }

Future<void> _initializePurchasedStocks() async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch user's investments document from Firestore
      final DocumentSnapshot userInvestments = await FirebaseFirestore.instance
          .collection('user_investments')
          .doc(user.uid)
          .get();

      if (userInvestments.exists) {
        // Get all the field names (which are stock names) from the document
        final data = userInvestments.data() as Map<String, dynamic>;
        setState(() {
          purchasedStocks = data.keys.toList(); // This gets all the stock names
        });

        // Log the purchased stocks
        debugPrint('Purchased Stocks: $purchasedStocks');
      } else {
        debugPrint('No investments found for this user');
      }
    } else {
      debugPrint('User not logged in');
    }
  } catch (e) {
    debugPrint('Error fetching purchased stocks: $e');
  }
}

  Future<void> fetchStockNews() async {
    const url = 'http://127.0.0.1:5000/stock-news';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          stockNews = json.decode(response.body);
          isLoading = false;
          _moveMatchingNewsToMyStockNews();
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

  void _moveMatchingNewsToMyStockNews() {
    List<dynamic> matchingNews = [];
    for (var news in stockNews) {
      for (var stock in purchasedStocks) {
        if (news['title'] != null && news['title'].toString().contains(stock)) {
          matchingNews.add(news);
        }
      }
    }
    setState(() {
      myStockNews.addAll(matchingNews);
    });
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

  Widget _buildNewsCard(dynamic news, {bool isMyStock = false}) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,  // Light blue background for all cards
              Colors.white
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            news['title'] ?? 'No Title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                news['source'] ?? 'Unknown Source',
                style: TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      news['link'] ?? 'No Link',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.open_in_new,
            color: Colors.black,
          ),
          onTap: () => _openUrl(news['link'] ?? ''),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 235, 235, 235), Color.fromARGB(255, 47, 146, 179), Color.fromARGB(255, 110, 153, 171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Makes the scaffold transparent
        appBar: AppBar(
          title: const Text(
            'Stock News',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
                (route) => false,
              );
            },
          ),
          backgroundColor: Color(0xFF0F2027), // Transparent to blend with gradient
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.article),
                    SizedBox(width: 8),
                    Text('Stock News'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bookmark),
                    SizedBox(width: 8),
                    Text('My Stock News'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchStockNews,
                        child: ListView.builder(
                          itemCount: stockNews.length,
                          itemBuilder: (context, index) {
                            final news = stockNews[index];
                            return _buildNewsCard(news);
                          },
                        ),
                      ),
            myStockNews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 100,
                          color: Colors.white,
                        ),
                       const SizedBox(height: 20),
                        Text(
                          'No Stock News',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchStockNews,
                    child: ListView.builder(
                      itemCount: myStockNews.length,
                      itemBuilder: (context, index) {
                        final news = myStockNews[index];
                        return _buildNewsCard(news);
                      },
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}