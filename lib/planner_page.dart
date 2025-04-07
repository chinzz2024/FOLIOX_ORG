import 'package:flutter/material.dart';
import 'package:foliox/govt_page.dart';
import 'home_page.dart';
import 'dart:math';
import 'profile_page.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final int _currentIndex = 1;

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
        (route) => false,
      );
    }
  }

  void _showSIPCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SIPCalculator(scrollController: scrollController),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F6FC),
     
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Financial Planner',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
           
            backgroundColor: Color(0xFF0F2027),
           
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SizedBox(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height,
  child: Image.asset(
    'assets/planner.jpg',
    fit: BoxFit.cover,
  ),
),
              Column(
                children: [
                  // Top content box
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE3F2FD),
                            Color(0xFFBBDEFB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.savings,
                            size: 40,
                            color: Color(0xFF003BFF),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Grow Your Wealth Systematically',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C0625),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Project your potential returns and plan your financial goals',
                            
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const IncomePage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003BFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                // Fixed: Added missing closing parenthesis for shape parameter
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              elevation: 3,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Find Your Plan',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Calculator Box
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF003BFF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calculate,
                                  color: Color(0xFF003BFF),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Investment Calculator',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C0625),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Start investing as low as ₹500/month and benefit from the power of compounding',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF616161),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _showSIPCalculator(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF003BFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFF003BFF),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Open Calculator',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.trending_up, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
             
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _currentIndex,
                onTap: _onBottomNavTapped,
                selectedItemColor: const Color(0xFF003BFF),
                unselectedItemColor: Colors.grey.shade600,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                type: BottomNavigationBarType.fixed,
                elevation: 10,
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
              ),
            ),
          ),
        ),
      
    );
  }
}

// Note: SIPCalculator class is not provided in the original code

class SIPCalculator extends StatefulWidget {
  final ScrollController? scrollController;
  
  const SIPCalculator({super.key, this.scrollController});

  @override
  _SIPCalculatorState createState() => _SIPCalculatorState();
}

class _SIPCalculatorState extends State<SIPCalculator> {
  final TextEditingController _monthlyInvestmentController = TextEditingController(text: '5000');
  final TextEditingController _expectedReturnController = TextEditingController(text: '12');
  final TextEditingController _timePeriodController = TextEditingController(text: '5');
  
  double _maturityAmount = 0;
  double _totalInvestment = 0;
  double _estimatedReturns = 0;
  double _inflationAdjustedValue = 0;
  
  // Inflation rate constant
  static const double INFLATION_RATE = 0.07; // 7%

  void _calculateSIP() {
  final double monthlyInvestment = double.tryParse(_monthlyInvestmentController.text) ?? 0;
  final double expectedReturn = double.tryParse(_expectedReturnController.text) ?? 0;
  final double timePeriod = double.tryParse(_timePeriodController.text) ?? 0;
  final double inflationRate = 0.07; // 7% inflation rate

  if (monthlyInvestment > 0 && expectedReturn > 0 && timePeriod > 0) {
    // Number of compounding periods
    final int months = (timePeriod * 12).toInt();
    
    // Monthly interest rate (convert annual to monthly)
    final double monthlyRate = expectedReturn / 12 / 100;
    
    // Calculate total investment
    _totalInvestment = monthlyInvestment * months;
    
    // SIP Future Value Calculation (using compound interest formula)
    _maturityAmount = monthlyInvestment * 
        (pow(1 + monthlyRate, months) - 1) / 
        monthlyRate * 
        (1 + monthlyRate);
    
    // Calculate estimated returns
    _estimatedReturns = _maturityAmount - _totalInvestment;
    
    // Inflation-adjusted value (Present Value of Future Amount)
    final double annualRate = expectedReturn / 100;
    final double inflationAdjustedRate = annualRate - inflationRate;
    
    _inflationAdjustedValue = _maturityAmount / 
        pow(1 + inflationAdjustedRate, timePeriod);
  } else {
    // Reset values if inputs are invalid
    _maturityAmount = 0;
    _totalInvestment = 0;
    _estimatedReturns = 0;
    _inflationAdjustedValue = 0;
  }

  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with draggable handle
        Container(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Draggable handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SIP Calculator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Calculator content
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Monthly Investment Card
                _buildInputCard(
                  title: 'Monthly Investment',
                  value: '₹${_monthlyInvestmentController.text}',
                  controller: _monthlyInvestmentController,
                ),
                const SizedBox(height: 16),
                
                // Expected Return Card
                _buildInputCard(
                  title: 'Expected Return (p.a.)',
                  value: '${_expectedReturnController.text}%',
                  controller: _expectedReturnController,
                ),
                const SizedBox(height: 16),
                
                // Time Period Card
                _buildInputCard(
                  title: 'Time Period',
                  value: '${_timePeriodController.text} years',
                  controller: _timePeriodController,
                ),
                const SizedBox(height: 24),
                
                // Results Section
                _buildResultSection(),
                const SizedBox(height: 24),
                
                // Calculate Button
                _buildCalculateButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({
    required String title,
    required String value,
    required TextEditingController controller,
  }) {
    return GestureDetector(
      onTap: () => _showNumberInputDialog(context, title, controller),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003BFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculateSIP,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003BFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Calculate Returns',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

 Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildResultItem('Invested Amount', _totalInvestment),
          const SizedBox(height: 12),
          _buildResultItem('Estimated Returns', _estimatedReturns),
          const SizedBox(height: 12),
          _buildResultItem('Inflation-Adjusted Value', _inflationAdjustedValue),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
          _buildResultItem('Total Value', _maturityAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isTotal ? Colors.black : Colors.black54,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF003BFF) : Colors.black,
          ),
        ),
      ],
    );
  }

  void _showNumberInputDialog(
    BuildContext context,
    String title,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF003BFF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _calculateSIP();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}