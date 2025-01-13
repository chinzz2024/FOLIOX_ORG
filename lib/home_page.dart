import 'package:flutter/material.dart';
import 'planner_page.dart';
import 'login_page.dart';
import 'stock_news.dart'; // Import StockNewsPage

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

<<<<<<< HEAD
class _HomepageState extends State<Homepage> {
=======
class _StockNewsPageState extends State<StockNewsPage> {
  List<Map<String, dynamic>> _newsArticles = []; // Updated type
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStockNews(); // Call the API fetch function
  }

  Future<void> _fetchStockNews() async {
    const String apiUrl =
        'http://192.168.77.137:5000/scrape_news'; // Use this IP
    // Flask API URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> fetchedData = json.decode(response.body);

        // Cast the fetched data to List<Map<String, dynamic>>
        final List<Map<String, dynamic>> newsList =
            List<Map<String, dynamic>>.from(fetchedData);

        setState(() {
          _newsArticles = newsList; // Assign the casted list to _newsArticles
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load news. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openArticleUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

>>>>>>> 3d938300146288d10c33124373e3f7b48497a88a
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock News',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Action for Stocks button
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stocks Button Pressed')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text(
                'Stocks',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to StockNewsPage on button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StockNewsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 6, 37),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text(
                'Stock News',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // You can dynamically set this index
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PlannerPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
