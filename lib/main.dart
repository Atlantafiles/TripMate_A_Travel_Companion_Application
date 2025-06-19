import 'package:flutter/material.dart';
import 'package:tripmate/routes/on_generate_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kuuzguxatwztabgylqjg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1dXpndXhhdHd6dGFiZ3lscWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxNzkxMTcsImV4cCI6MjA2MTc1NTExN30.IgnxYHd8XfcWIpeK75RJhRY57pwRccUQY_vruKLrxxw',
  );

  runApp(MyApp());
}
// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: onGenerateRoute,
    );
  }
}

