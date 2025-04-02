import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/routes/on_generate_route.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> package;

  const BookingDetailsScreen({super.key, required this.package});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPaymentMethod; // Holds selected payment method

  final List<Map<String, dynamic>> _paymentMethods = [
    {"title": "Credit Card", "icon": Icons.credit_card, "color": Colors.blue},
    {"title": "UPI", "icon": Icons.account_balance_wallet, "color": Colors.green},
    {"title": "Promo Code", "icon": Icons.local_offer, "color": Colors.orange},
  ];

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate total dynamically from the passed package
    final int basePrice = widget.package['basePrice'];
    final int taxes = widget.package['taxes'];
    final int totalPrice = basePrice + taxes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name Input
              Text("Full Name", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Enter your full name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Email Input
              Text("Email", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Travel Date Picker
              Text("Travel Date", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: "Select date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat.yMMMd().format(_selectedDate!)
                        : "Select date",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Price Details Section
              Text("Price Details", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildPriceRow("Base Price", "₹$basePrice"),
                    _buildPriceRow("Taxes & Fees", "₹$taxes"),
                    const Divider(thickness: 1),
                    _buildPriceRow("Total", "₹$totalPrice", isTotal: true),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Payment Method Section
              Text("Payment Method", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: _paymentMethods.map((method) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = method["title"];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedPaymentMethod == method["title"]
                            ? method["color"].withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedPaymentMethod == method["title"]
                              ? method["color"]
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(method["icon"], color: method["color"]),
                          const SizedBox(width: 10),
                          Text(
                            method["title"],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          if (_selectedPaymentMethod == method["title"])
                            Icon(Icons.check_circle, color: method["color"]),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Confirm Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _selectedDate == null ||
                        _selectedPaymentMethod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all details before proceeding")),
                      );
                    } else {
                      // Navigate to Payment Gateway Screen (Before Confirmation)
                      // Navigator.pushNamed(
                      //   context,
                      //   AppRoutes.paymentGateway,
                      //   arguments: {
                      //     'packageName': selectedPackage.name,
                      //     'totalPrice': selectedPackage.price,
                      //     'travelDate': selectedDate, // Ensure this is passed
                      //   },
                      // );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookingConfirmation,
                        arguments: {
                          'reference': 'BKG123456',
                          'packageName': 'Bali Paradise Tour',
                          'travelDate': _selectedDate,
                        },
                      );

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Confirm Payment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
