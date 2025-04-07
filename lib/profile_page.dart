import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foliox/login_page.dart';
import 'home_page.dart';
import 'planner_page.dart';

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
  Map<String, dynamic> financialData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        DocumentSnapshot financialDoc = await FirebaseFirestore.instance
            .collection('financialPlanner')
            .doc(user.uid)
            .get();

        if (userDoc.exists && financialDoc.exists) {
          setState(() {
            fullName = userDoc['fullName'];
            email = userDoc['email'];
            panNumber = userDoc['panNumber'];
            phoneNumber = userDoc['phoneNumber'];
            financialData = financialDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2980), // Deep blue
              Color(0xFF26D0CE), // Teal
            ],
            stops: [0.1, 0.9],
          ),
        ),
        
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Main Content
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Profile Header
                            _buildProfileHeader(),
                            SizedBox(height: 30),

                            // Financial Overview Cards
                            _buildFinancialOverview(),
                            SizedBox(height: 20),

                            // Expense Breakdown
                            _buildExpenseSection(),
                            SizedBox(height: 30),

                            // Personal Information
                            _buildPersonalInfoSection(),
                            SizedBox(height: 30),

                            // Logout Button
                            _buildLogoutButton(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      
      title: Text(
        'My Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
      backgroundColor: Color(0xFF0F2027),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () => _showEditProfileDialog(context),
        ),
      ],
      
    );
  }

  Widget _buildProfileHeader() {
    String initial = fullName?.isNotEmpty == true ? fullName![0].toUpperCase() : '?';
    
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          fullName ?? 'User Name',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          email ?? 'user@email.com',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialOverview() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Income',
              value: '₹${(financialData['totalIncome']?.toInt() ?? 0)}',
              icon: Icons.arrow_upward,
              color: Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Savings',
              value: '₹${(financialData['savings']?.toInt() ?? 0)}',
              icon: Icons.savings,
              color: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      _buildStatCard(
        title: 'Savings Rate',
        value: '${((financialData['savings'] ?? 0) / (financialData['totalIncome'] ?? 1) * 100).toInt()}%',
        icon: Icons.trending_up,
        color: Color(0xFF9C27B0),
        fullWidth: true,
      ),
    ],
  );
}

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildExpenseSection() {
  int totalExpenses = ((financialData['totalEssentialExpenses'] ?? 0) + 
                      (financialData['totalOptionalExpenses'] ?? 0)).toInt();
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
               _buildExpenseCategory(
        label: 'Essential',
        amount: (financialData['totalEssentialExpenses'] ?? 0).toInt(),
        total: totalExpenses,
        color: Color(0xFF1A2980),
      ),
      SizedBox(height: 12),
      _buildExpenseCategory(
        label: 'Optional',
        amount: (financialData['totalOptionalExpenses'] ?? 0).toInt(),
        total: totalExpenses,
        color: Color(0xFF26D0CE),
      ),
              
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCategory({
  required String label,
  required int amount,
  required int total,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      LinearProgressIndicator(
        value: total > 0 ? amount / total : 0,
        minHeight: 6,
        backgroundColor: Colors.grey[200],
        color: color,
      ),
      SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${total > 0 ? ((amount / total * 100).toInt()) : 0}% of expenses',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${total > 0 ? ((amount / (financialData['totalIncome'] ?? 1) * 100).toInt()) : 0}% of income',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ],
  );
}


 Widget _buildExpenseTag({
  required IconData icon,
  required String label,
  required String value,
}) {
  // Extract the numeric value and convert to int
  String numericValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
  double? doubleValue = double.tryParse(numericValue);
  String intValue = doubleValue != null ? doubleValue.toInt().toString() : '0';
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Color(0xFF1A2980)),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '₹$intValue',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2980),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(icon: Icons.phone, label: 'Phone', value: phoneNumber ?? 'Not set'),
              Divider(height: 24, thickness: 1),
              _buildInfoRow(icon: Icons.credit_card, label: 'PAN', value: panNumber ?? 'Not set'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Color(0xFF1A2980)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red),
          ),
          elevation: 0,
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      onTap: _onBottomNavTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF003BFF),
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) return;

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
        MaterialPageRoute(builder: (context) => const PlannerPage()),
      );
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final nameController = TextEditingController(text: fullName);
    final phoneController = TextEditingController(text: phoneNumber);
    final panController = TextEditingController(text: panNumber);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: panController,
                decoration: InputDecoration(
                  labelText: 'PAN Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'fullName': nameController.text,
                    'phoneNumber': phoneController.text,
                    'panNumber': panController.text,
                  });
                  setState(() {
                    fullName = nameController.text;
                    phoneNumber = phoneController.text;
                    panNumber = panController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating profile: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save', style: TextStyle(color: Color(0xFF1A2980))),
          ),
        ],
      ),
    );
  }
}