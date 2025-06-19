import 'package:flutter/material.dart';
import 'package:tripmate/services/travelpackages_service.dart';

class AgencyDashboardScreen extends StatefulWidget {
  const AgencyDashboardScreen({super.key});

  @override
  State<AgencyDashboardScreen> createState() => _AgencyDashboardScreenState();
}

class _AgencyDashboardScreenState extends State<AgencyDashboardScreen> {
  final TravelPackagesService _packageService = TravelPackagesService();

  // State variables for real-time data
  int _packageCount = 0;
  int _bookingCount = 0; // You can also make this real-time
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Use the more efficient dashboard stats method
      final stats = await _packageService.getDashboardStats();

      setState(() {
        _packageCount = stats['packages'] ?? 0;
        _bookingCount = stats['bookings'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/agency_profile');
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              if (_error.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _error = ''),
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),

              // Stats Cards
              Row(
                children: [
                  _buildStatCard(
                    context,
                    title: "Trip Packages",
                    value: _isLoading ? "..." : _packageCount.toString(),
                    icon: Icons.card_travel,
                    color: Colors.blue.shade50,
                    iconColor: Colors.blue,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    title: "Total Bookings",
                    value: _isLoading ? "..." : _bookingCount.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    isLoading: _isLoading,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // Quick Actions Grid
              GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width > 600 ? 4 : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                children: [
                  _buildActionButton(
                    icon: Icons.card_travel,
                    label: "Manage Trips",
                    onTap: () async {
                      final result = await Navigator.pushNamed(context, '/travelpackages');
                      // Refresh data when returning from manage trips screen
                      if (result == true) {
                        _refreshData();
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.add,
                    label: "Add New Package",
                    onTap: () async {
                      final result = await Navigator.pushNamed(context, '/addtravelpackage');
                      // Refresh data when a new package is added
                      if (result == true) {
                        _refreshData();
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.calendar_month,
                    label: "View Bookings",
                    onTap: () {
                      Navigator.pushNamed(context, '/bookingmanagement');
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.people,
                    label: "Customer List",
                    onTap: () {
                      // Navigator.pushNamed(context, '');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
        required String value,
        required IconData icon,
        required Color color,
        required Color iconColor,
        bool isLoading = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 6),
                Flexible(
                    child: Text(
                        title,
                        overflow: TextOverflow.ellipsis
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}