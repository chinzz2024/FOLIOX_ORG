import 'package:flutter/material.dart';
import 'car_service.dart';

class DreamCarPage extends StatefulWidget {
  @override
  _DreamCarPageState createState() => _DreamCarPageState();
}

class _DreamCarPageState extends State<DreamCarPage> {
  final TextEditingController carController = TextEditingController();
  String carPrice = '';
  bool isLoading = false; // Add a loading indicator

  void fetchCarPrice() async {
    // Input validation
    if (carController.text.trim().isEmpty) {
      setState(() {
        carPrice = 'Please enter a valid car name.';
      });
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      String price = await getCarPrice(carController.text.trim());
      setState(() {
        carPrice = price;
      });
    } catch (e) {
      setState(() {
        carPrice = 'Error fetching car price. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Car', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 12, 6, 37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: carController,
              decoration: InputDecoration(
                labelText: 'Enter Car Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchCarPrice,
              child: const Text('Get Car Price'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator()), // Show loading spinner
            if (!isLoading && carPrice.isNotEmpty)
              Text(
                carPrice,
                style: const TextStyle(fontSize: 20),
              ),
          ],
        ),
      ),
    );
  }
}
