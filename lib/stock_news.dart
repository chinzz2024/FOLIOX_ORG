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
  int _currentPage = 1;
  bool _hasMore = true;
  final int _newsPerPage = 20;
  bool _isLoadingMore = false;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePurchasedStocks();
    _fetchInitialNews();
  }

  Future<void> _initializePurchasedStocks() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('user_investments')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            purchasedStocks = (snapshot.data() as Map<String, dynamic>).keys.toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching purchased stocks: $e');
    }
  }

  Future<void> _fetchInitialNews() async {
    if (_lastRefreshTime != null && 
        DateTime.now().difference(_lastRefreshTime!) < Duration(minutes: 1)) {
      return;
    }

    setState(() {
      isLoading = true;
      _currentPage = 1;
      stockNews.clear();
      myStockNews.clear();
    });

    try {
      final response = await http.get(Uri.parse(
        'https://foliox-backend.onrender.com/stock-news?page=$_currentPage&per_page=$_newsPerPage'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stockNews = data['news'];
          _hasMore = data['has_more'];
          isLoading = false;
          _lastRefreshTime = DateTime.now();
          _filterMyStockNews();
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load news: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await http.get(Uri.parse(
        'https://foliox-backend.onrender.com/stock-news?page=$_currentPage&per_page=$_newsPerPage'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stockNews.addAll(data['news']);
          _hasMore = data['has_more'];
          _isLoadingMore = false;
          _filterMyStockNews();
        });
      } else {
        throw Exception('Failed to load more news');
      }
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

 void _filterMyStockNews() {
  if (purchasedStocks.isEmpty) return;
  
  final lowerCaseStocks = purchasedStocks.map((s) => s.toLowerCase()).toList();
  
  setState(() {
    myStockNews = stockNews.where((news) {
      final title = news['title']?.toString().toLowerCase() ?? '';
      return lowerCaseStocks.any((s) => title.contains(s));  // Changed 'stock' to 's'
    }).toList();
  });
}

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  Widget _buildNewsItem(dynamic news) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _openUrl(news['link'] ?? ''),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news['title'] ?? 'No Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                news['source'] ?? 'Unknown Source',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      news['link'] ?? '',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList(List<dynamic> newsList, bool isMainTab) {
    return RefreshIndicator(
      onRefresh: _fetchInitialNews,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: newsList.length + ((isMainTab && _hasMore) ? 1 : 0),
        itemBuilder: (context, index) {
          if (isMainTab && index == newsList.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _isLoadingMore 
                  ? CircularProgressIndicator()
                  : TextButton(
                      onPressed: _loadMoreNews,
                      child: Text('Load More'),
                    ),
              ),
            );
          }
          return _buildNewsItem(newsList[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _fetchInitialNews,
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock News'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.article), text: 'All News'),
            Tab(icon: Icon(Icons.bookmark), text: 'My Stocks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All News Tab
          isLoading 
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : stockNews.isEmpty
                ? _buildEmptyState()
                : _buildNewsList(stockNews, true),

          // My Stocks Tab
          isLoading
            ? Center(child: CircularProgressIndicator())
            : myStockNews.isEmpty
              ? _buildEmptyState()
              : _buildNewsList(myStockNews, false),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}