import 'package:flutter/material.dart';
import 'home_page.dart';
import 'planner_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2;

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PlannerPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                    'assets/profile_placeholder.png'), // Replace with a real image path or network image
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 20),
              // Name and Email
              Text(
                'John Doe', // Replace with dynamic name
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'johndoe@example.com', // Replace with dynamic email
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Divider
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 20),
              // Account Details
              ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.blue),
                title: const Text('Portfolio Value'),
                subtitle: const Text('\$25,000'), // Replace with dynamic data
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.green),
                title: const Text('Investment Growth'),
                subtitle: const Text('15%'), // Replace with dynamic data
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
                title: const Text('Joined Date'),
                subtitle:
                    const Text('Jan 1, 2023'), // Replace with dynamic data
              ),
              const SizedBox(height: 20),
              // Log Out Button
              ElevatedButton(
                onPressed: () {
                  // Add logout functionality
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
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
