import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foliox/login_page.dart';
import 'home_page.dart';
import 'planner_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2;
  String? fullName;
  String? email;
  String? panNumber;
  String? phoneNumber;
  String? portfolioValue;
  bool isLoading = true; // To show loading indicator

  @override
  void initState() {
    super.initState();
    // Fetch user data when the page loads
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      // Get the current user ID
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid; // Get the current user's UID

        // Fetch user data from Firestore using userId as document ID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Document ID is the userId
            .get();

        if (userDoc.exists) {
          // If document exists, fetch and set the user data
          setState(() {
            fullName = userDoc['fullName'];
            email = userDoc['email'];
            panNumber = userDoc['panNumber'];
            phoneNumber = userDoc['phoneNumber'];
            portfolioValue = userDoc['portfolioValue'];
            isLoading = false; // Stop loading once data is fetched
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',style: TextStyle(color: Colors.white),),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDataUI(),
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

  // User Data UI
  Widget userDataUI() {
    return SingleChildScrollView(
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
                  'assets/profile_placeholder.png'), // Placeholder image
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 20),
            // Name and Email
            Text(
              fullName ?? 'Loading...', // Display "Loading..." if fullName is null
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email ?? 'Loading...', // Display "Loading..." if email is null
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300], thickness: 1),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: const Text('Portfolio Value'),
              subtitle: Text(portfolioValue ?? 'Loading...'), // Fallback text
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Phone Number'),
              subtitle: Text(phoneNumber ?? 'Loading...'), // Fallback text
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.orange),
              title: const Text('PAN Number'),
              subtitle: Text(panNumber ?? 'Loading...'), // Fallback text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
    );
  }

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
}
