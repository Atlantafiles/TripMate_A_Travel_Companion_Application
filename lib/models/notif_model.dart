import 'package:flutter/material.dart';

class NotificationItem {

  final String title;
  final String subtitle;
  final String timeSince;
  final IconData icon;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeSince,
    required this.icon
  });
}