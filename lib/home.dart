import 'package:flutter/material.dart';
import 'package:fds/services/firebase.dart'; // Import your Firebase service
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create TextEditingControllers to manage input from TextFields
  final TextEditingController _orderIDController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Instance of the Database class
  final Database database = Database();

  // Variable to track whether the user can input data
  bool _showInputFields = false;

  // Function to add an order to the database
  void _addOrder() async {
    // Get the data from controllers
    final String customerName = _customerNameController.text;
    final int ordersID = int.tryParse(_orderIDController.text) ?? 0; // Fallback to 0 if input is not a valid number
    final double totalCost = double.tryParse(_totalCostController.text) ?? 0.0; // Fallback to 0.0 if input is not a valid number
    final int quantity = int.tryParse(_quantityController.text) ?? 0;

    // Make sure the fields are not empty
    if (customerName.isNotEmpty && ordersID != 0 && totalCost != 0.0) {
      // Add order to the database
      await database.addOrder(ordersID, customerName, totalCost, quantity);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order added successfully")),
      );

      // Optionally, reset the form after submission
      _orderIDController.clear();
      _customerNameController.clear();
      _totalCostController.clear();
    } else {
      // Show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS System', style:TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Force a refresh of the UI
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Icon above the button
            const Icon(
              Icons.shopping_cart,
              size: 50,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Button to enable input and show input fields
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showInputFields = true; // When button is clicked, show the input fields
                });
              },
              child: const Text("New Order"),
            ),
            const SizedBox(height: 16),

            // Conditionally display the input fields based on _showInputFields
            Visibility(
              visible: _showInputFields, // If true, show the input fields
              child: Column(
                children: [
                  // TextField for ordersID
                  TextField(
                    controller: _orderIDController,
                    decoration: const InputDecoration(
                      labelText: 'Order ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // TextField for customerName
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TextField for totalCost
                  TextField(
                    controller: _totalCostController,
                    decoration: const InputDecoration(
                      labelText: 'Total Cost',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // TextField for Quantity
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Button to add the order
                  ElevatedButton(
                    onPressed: _addOrder, // Add the order when this button is clicked
                    child: const Text("Add Order"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // StreamBuilder to listen to changes in Firestore and show the updated list of orders
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Order Table').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }

                  // Get the documents from Firestore
                  final orders = snapshot.data?.docs ?? [];

                  // Display the orders in a ListView
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderID = order['ordersID'];
                      final customerName = order['customerName'];
                      final totalCost = order['totalCost'].toDouble();
                      final quantity = order['quantity'];
                      final orderDate = (order['orderDate'] as Timestamp).toDate();

                      return ListTile(
                        title: Text('Order ID: $orderID'),
                        subtitle: Text('Customer: $customerName\nTotal: \$${totalCost.toStringAsFixed(2)}\nDate: $orderDate'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
