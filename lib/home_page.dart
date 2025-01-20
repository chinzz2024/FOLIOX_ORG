import 'package:flutter/material.dart';
import 'planner_page.dart';
import 'stock_news.dart';
import 'stock_list.dart';
import 'profile_page.dart';
import 'login_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlannerPage()),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stocks Overview',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to Stock Page (Homepage)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false, // Clear all previous routes
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner Section
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'https://www.google.com/imgres?q=assets%2Fstock%20banner&imgurl=https%3A%2F%2Fen.pimg.jp%2F109%2F417%2F265%2F1%2F109417265.jpg&imgrefurl=https%3A%2F%2Fwww.pixtastock.com%2Fillustration%2F109417265&docid=HdpMgzR2M6VXiM&tbnid=sS9yKIVlyuKNgM&vet=12ahUKEwiWybKhgoWLAxXIdfUHHc0tOQYQM3oECG0QAA..i&w=450&h=313&hcb=2&itg=1&ved=2ahUKEwiWybKhgoWLAxXIdfUHHc0tOQYQM3oECG0QAA'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Text(
                      'Welcome to the Stock Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Featured Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.newspaper,
                        label: 'Stock News',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StockNewsPage()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.bar_chart,
                        label: 'Stocks',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StockListPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Stocks',
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
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildQuickActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNewsCard({required String title, required String date}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.newspaper, color: Colors.teal, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        subtitle: Text(date),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening article: $title')),
          );
        },
      ),
    );
  }
}
