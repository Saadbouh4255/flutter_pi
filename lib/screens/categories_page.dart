import 'package:flutter/material.dart';
import '../models/tourist_place.dart';
import 'category_details_screen.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': '🏛️ Lieux touristiques', 'icon': Icons.account_balance, 'type': PlaceCategory.touristPlaces, 'color': Colors.blue},
    {'name': '🍽️ Restaurants', 'icon': Icons.restaurant, 'type': PlaceCategory.restaurants, 'color': Colors.orange},
    {'name': '🏨 Hôtels', 'icon': Icons.hotel, 'type': PlaceCategory.hotels, 'color': Colors.purple},
    {'name': '🛍️ Marchés', 'icon': Icons.storefront, 'type': PlaceCategory.markets, 'color': Colors.green},
    {'name': '🎯 Activités et loisirs', 'icon': Icons.local_activity, 'type': PlaceCategory.activitiesAndEntertainment, 'color': Colors.red},
    {'name': '🚕 Services', 'icon': Icons.local_taxi, 'type': PlaceCategory.services, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.9,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailsScreen(
                    categoryName: cat['name'] as String,
                    categoryType: cat['type'] as PlaceCategory,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    (cat['color'] as Color).withOpacity(0.7),
                    (cat['color'] as Color),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (cat['color'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'] as IconData, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      cat['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
