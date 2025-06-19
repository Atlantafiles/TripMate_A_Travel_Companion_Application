import 'package:flutter/material.dart';
import 'package:tripmate/screens/booking_management_screen.dart';
import 'package:tripmate/screens/home_screen.dart';
import 'package:tripmate/screens/signup_screen.dart';
import 'package:tripmate/screens/splash_screen.dart';
import 'package:tripmate/screens/onboarding_screen.dart';
import 'package:tripmate/screens/login_screen.dart';
import 'package:tripmate/screens/verify_identity_screen.dart';
import 'package:tripmate/screens/entry_screen.dart';
import 'package:tripmate/screens/view_details_screen.dart';
import 'package:tripmate/screens/booking_details_screen.dart';
import 'package:tripmate/screens/booking_success_screen.dart';
import 'package:tripmate/screens/profile_edit_screen.dart';
import 'package:tripmate/screens/settings_screen.dart';
import 'package:tripmate/screens/rating_screen.dart';
import 'package:tripmate/screens/create_group.dart';
import 'package:tripmate/screens/agency_signin_screen.dart';
import 'package:tripmate/screens/agency_signup_screen.dart';
import 'package:tripmate/screens/agency_dashboard_screen.dart';
import 'package:tripmate/screens/agency_profile_screen.dart';
import 'package:tripmate/screens/add_travel_package_screen.dart';
import 'package:tripmate/screens/agency_booking_details_screen.dart';
import 'package:tripmate/screens/travel_packages_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyIdentity = '/verify_identity';
  static const String home = '/home';
  static const String entry = '/entry';
  static const String viewDetails = '/view_details';
  static const String bookingDetails = '/booking';
  static const String bookingConfirmation = '/booking_success';
  static const String profileEdit = '/profile_edit';
  static const String settings = '/settings';
  static const String ratings = '/ratings';
  static const String createGroups = '/create_groups';
  static const String agencySignIn = '/agency_signin';
  static const String agencySignUp = '/agency_signup';
  static const String agencyDashboard = '/agency_dashboard';
  static const String agencyProfile = '/agency_profile';
  static const String addtravelpackage = '/addtravelpackage';
  static const String agencybookingdetails = '/agencybookingdetails';
  static const String bookingmanagement = '/bookingmanagement';
  static const String travelpackages = '/travelpackages';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());

    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());

    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());

    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => const SignupScreen());

    case AppRoutes.verifyIdentity:
      return MaterialPageRoute(builder: (_) => const VerifyIdentityScreen());

    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case AppRoutes.entry:
      return MaterialPageRoute(builder: (_) => const MainScreen());

    case AppRoutes.viewDetails:
      final arguments = settings.arguments as Map<String, dynamic>?;
      final packageId = arguments?['packageId'] as String?;

      if (packageId == null) {
        // Handle error - package ID is required
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text('Package ID is required'),
            ),
          ),
        );
      }

      return MaterialPageRoute(
        builder: (context) => PackageDetailsScreen(packageId: packageId),
      );


    case AppRoutes.bookingDetails:
       final package = settings.arguments as Map<String, dynamic>?;
         // Validate if package is not null or provide a fallback.
       if (package != null) {
          return MaterialPageRoute(
             builder: (_) => BookingDetailsScreen(package: package),
         );
       }
       // handle the error when package data is missing
       return MaterialPageRoute(
         builder: (_) => const Scaffold(
         body: Center(child: Text("Package data missing")),
         ),
       );

    case AppRoutes.bookingConfirmation:
    // Extract arguments as a Map
      final args = settings.arguments as Map<String, dynamic>?;

      return MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          bookingReference: args?['reference'] ?? 'N/A',
          packageName: args?['packageName'] ?? 'N/A',
          travelDate: args?['travelDate'] ?? DateTime.now(),
        ),
      );

    case AppRoutes.profileEdit:
      return MaterialPageRoute(builder: (_) => ProfileEditScreen());

    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => SettingsScreen());

    case AppRoutes.ratings:
      return MaterialPageRoute(builder: (_) => RateExperienceScreen());

    case AppRoutes.createGroups:
      return MaterialPageRoute(builder: (_) => CreateNewGroupScreen());

    case AppRoutes.agencySignIn:
      return MaterialPageRoute(builder: (_) => AgencySignInScreen());

    case AppRoutes.agencySignUp:
      return MaterialPageRoute(builder: (_) => AgencySignUpScreen());

    case AppRoutes.agencyDashboard:
      return MaterialPageRoute(builder: (_) => AgencyDashboardScreen());

    case AppRoutes.agencyProfile:
      return MaterialPageRoute(builder: (_) => AgencyProfileScreen());

    case AppRoutes.addtravelpackage:
      final args = settings.arguments as Map<String, dynamic>?;

      return MaterialPageRoute(
        builder: (_) => AddTravelPackageScreen(
          existingPackage: args?['existingPackage'] as Map<String, dynamic>?,
        ),
      );

    case AppRoutes.travelpackages:
      return MaterialPageRoute(builder: (_) => TravelPackagesScreen());

    case AppRoutes.agencybookingdetails:
      return MaterialPageRoute(builder: (_) => AgencyBookingDetailsScreen());

    case AppRoutes.bookingmanagement:
      return MaterialPageRoute(builder: (_) => BookingManagementScreen());

    default:
     return MaterialPageRoute(
        builder: (_) => const Scaffold(
        body: Center(
        child: Text('404: Page Not Found'),
        ),
      ),
    );
  }
}
