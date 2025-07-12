// lib/core/constants/category_data.dart

import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  const Category({required this.name, required this.icon});
}

const List<Category> categories = [
  Category(name: "Community & Government", icon: Icons.account_balance),
  Category(name: "Dining & Drinking", icon: Icons.restaurant_menu),
  Category(name: "Arts & Entertainment", icon: Icons.palette),
  Category(name: "Business & Professional Services", icon: Icons.work),
  Category(name: "Event", icon: Icons.event),
  Category(name: "Health & Medicine", icon: Icons.local_hospital),
  Category(name: "Restaurant", icon: Icons.restaurant),
  Category(name: "Nightlife Spot", icon: Icons.nightlife),
  Category(name: "College & University", icon: Icons.school),
  Category(name: "Retail", icon: Icons.store),
  Category(name: "Travel & Transport", icon: Icons.directions_bus),
  Category(name: "Residential Building", icon: Icons.apartment),
  Category(name: "Landmarks & Outdoors", icon: Icons.park),
  Category(name: "Sports & Recreation", icon: Icons.sports_soccer),
];
