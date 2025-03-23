import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:foliox/login_page.dart';
import 'planner_page.dart';
import 'stock_news.dart';
import 'stock_list.dart';
import 'profile_page.dart';

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
    return Container(
      color: const Color.fromARGB(255, 199, 230, 238), // ✅ Full-page background
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent, // ✅ Avoids white color bleeding
          appBar: AppBar(
            title: const Text(
              'Stocks',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            backgroundColor: const Color.fromARGB(255, 12, 6, 37),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 3),
                              enlargeCenterPage: true,
                              viewportFraction: 1.0,
                            ),
                            items: [
                              'assets/car.jpg',
                              'assets/grph.jpg',
                              'assets/maram.jpg',
                            ].map((url) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(url),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

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
                                color: Color.fromARGB(255, 0, 0, 0), // ✅ Text visible on blue bg
                              ),
                            ),
                            const SizedBox(height: 85), // Adjusted spacing
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
              ),
            ],
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
        ),
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
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 0, 0, 0))), // ✅ White text for visibility
        ],
      ),
    );
  }
}
