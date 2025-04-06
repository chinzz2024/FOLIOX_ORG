import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class StockNewsPage extends StatefulWidget {
  const StockNewsPage({super.key});

  @override
  State<StockNewsPage> createState() => _StockNewsPageState();
}

class _StockNewsPageState extends State<StockNewsPage> 
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> _news = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _perPage = 10;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _retryCount = ValueNotifier<int>(0);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadInitialNews() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('Fetching news from API...');
      final response = await http.get(
        Uri.parse('https://foliox-backend.onrender.com/stock-news?page=1&per_page=$_perPage')
      ).timeout(const Duration(seconds: 20));

      debugPrint('API response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final parsed = _parseApiResponse(response.body);
        
        setState(() {
          _news.addAll(parsed['data']);
          _hasMore = parsed['hasMore'];
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      _retryCount.value++;
      setState(() {
        _error = "Request timed out. Please try again. (Retry ${_retryCount.value})";
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load news: ${_formatError(e)}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parseApiResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      
      // Handle case when backend returns just an array
      if (decoded is List) {
        return {
          'data': decoded,
          'hasMore': false
        };
      }
      
      // Handle case when backend returns a proper response object
      if (decoded is Map) {
        return {
          'data': decoded['data'] ?? [],
          'hasMore': decoded['meta']?['has_more'] ?? false
        };
      }
      
      throw Exception('Unexpected response format');
    } catch (e) {
      debugPrint('Error parsing API response: $e');
      return {
        'data': [],
        'hasMore': false
      };
    }
  }

  String _formatError(dynamic error) {
    final message = error.toString();
    // Clean up common error messages
    if (message.contains('JSArray<dynamic>')) {
      return 'Server returned unexpected data format';
    }
    if (message.contains('List<dynamic>')) {
      return 'Server returned unexpected list format';
    }
    return message.replaceAll('"', "'");
  }

  Future<void> _loadMoreNews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://foliox-backend.onrender.com/stock-news?page=${_page + 1}&per_page=$_perPage')
      ).timeout(const Duration(seconds: 15));

      final data = _parseApiResponse(response.body);
      
      if (data['success'] == true || data['status'] == 200 || data['status'] == 'success') {
        setState(() {
          _news.addAll(List<Map<String, dynamic>>.from(data['data'] ?? []));
          _hasMore = data['meta']?['has_more'] ?? false;
          _page++;
        });
      }
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMoreNews();
    }
  }

  Future<void> _refreshNews() async {
    await _loadInitialNews();
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filterNews(String query) {
    if (query.isEmpty) return _news;
    return _news.where((item) => 
      item['title']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false
    ).toList();
  }

  Widget _buildNewsItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _openUrl(item['link'] ?? ''),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] ?? 'No title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                item['source'] ?? 'Unknown source',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['link'] ?? '',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }


  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialNews,
            child: const Text('Retry'),
          ),
          const SizedBox(height: 16),
          Text(
            'If this persists, please:\n'
            '1. Check your internet connection\n'
            '2. Verify the server is running\n'
            '3. Contact support if needed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNews,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNews,
              child: _error != null && _news.isEmpty
                  ? _buildError()
                  : _news.isEmpty
                      ? _buildLoader()
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _filterNews(_searchController.text).length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _filterNews(_searchController.text).length) {
                              return _buildLoader();
                            }
                            return _buildNewsItem(_filterNews(_searchController.text)[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}