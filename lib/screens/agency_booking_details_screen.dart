import 'package:flutter/material.dart';

class AgencyBookingDetailsScreen extends StatelessWidget {
  const AgencyBookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, color: Colors.orange, size: 18),
                SizedBox(width: 6),
                Text("Pending Confirmation",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                        fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSummary(),
                  const SizedBox(height: 16),
                  _buildHotelInfo(),
                  const SizedBox(height: 16),
                  _buildGuestInfo(),
                  const SizedBox(height: 16),
                  _buildPriceDetails(),
                  const SizedBox(height: 16),
                  _buildManagerCard(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text("Confirm Booking"),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text("Reject Booking",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryBox("Booking Reference", "#BK284751"),
        _summaryBox("Booking Date", "Jan 15, 2024"),
      ],
    );
  }

  Widget _summaryBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (label == "Booking Reference")
              const Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("2 Guests",
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelInfo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              'https://images.unsplash.com/photo-1501117716987-c8e1ecb2100e?auto=format&fit=crop&w=800&q=80',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Luxury Ocean View Suite",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16),
                    SizedBox(width: 4),
                    Text("Malibu, California",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _iconText(Icons.calendar_today_outlined, "Check-in",
                        "Feb 1, 2024"),
                    const SizedBox(width: 24),
                    _iconText(Icons.calendar_today_outlined, "Check-out",
                        "Feb 5, 2024"),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Room Type",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black54)),
                const SizedBox(height: 4),
                const Text("Deluxe Ocean View Suite"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildGuestInfo() {
    return _infoCard(
      title: "Guest Information",
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 20,
            child: Text("JD",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("John Doe", style: TextStyle(fontWeight: FontWeight.w600)),
              Text("Lead Guest", style: TextStyle(color: Colors.black54)),
              SizedBox(height: 4),
              Text("+1 (555) 123-4567"),
              Text("john.doe@example.com"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return _infoCard(
      title: "Price Details",
      child: Column(
        children: const [
          PriceRow("Room Rate (4 nights)", "\$800.00"),
          PriceRow("Taxes & Fees", "\$120.00"),
          Divider(),
          PriceRow("Total Amount", "\$920.00", isBold: true),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.credit_card, size: 16, color: Colors.grey),
              SizedBox(width: 6),
              Text("Paid with •••• 4567",
                  style: TextStyle(color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildManagerCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1590080876273-ec6b5b78de8f?auto=format&fit=crop&w=500&q=80'),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sarah Wilson",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text("Property Manager",
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("View Profile"),
          )
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;

  const PriceRow(
      this.label,
      this.amount, {
        super.key,
        this.isBold = false,
      });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: isBold ? 16 : 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(amount, style: textStyle),
        ],
      ),
    );
  }
}
