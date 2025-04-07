import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:foliox/login_page.dart';
import 'package:foliox/stock_sell.dart';
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
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A2980),
            Color(0xFF26D0CE),
          ],
        ),
      ),
     
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            
            title: Text(
              'Stocks',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                fontSize: 20,
              ),
            ),
            backgroundColor: Color(0xFF0F2027),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 250,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 4),
                            enlargeCenterPage: true,
                            viewportFraction: 0.85,
                            enlargeFactor: 0.3,
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
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: AssetImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 10,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildQuickActionButton(
                                  width: buttonWidth / 2 - 20,
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
                                  width: buttonWidth / 2 - 20,
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
                            SizedBox(height: 20),
                            Center(
                              child: _buildReviewButton(
                                width: buttonWidth,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StockSell()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
             
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _currentIndex,
                onTap: _onBottomNavTapped,
                type: BottomNavigationBarType.fixed,
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
                selectedItemColor: const Color(0xFF003BFF),
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      
    );
  }

  Widget _buildQuickActionButton({
    required double width,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              label, 
              style: TextStyle(
                fontSize: 16, 
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButton({
    required double width,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 30, 125, 165),
              Color.fromARGB(255, 17, 130, 168),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_sharp, color: Colors.white, size: 40),
                SizedBox(width: 15),
                Text(
                  'Review of your portfolio',
                  style: TextStyle(
                    fontSize: 16, 
                    color:  Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}