import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/tourist_place.dart';
import '../theme/app_theme.dart';
import 'category_details_screen.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const List<_CategoryData> _categories = [
    _CategoryData(
      name: 'Lieux touristiques',
      emoji: '🏛️',
      icon: Icons.account_balance_rounded,
      type: PlaceCategory.touristPlaces,
      color: AppColors.catTourist,
    ),
    _CategoryData(
      name: 'Restaurants',
      emoji: '🍽️',
      icon: Icons.restaurant_rounded,
      type: PlaceCategory.restaurants,
      color: AppColors.catRestaurant,
    ),
    _CategoryData(
      name: 'Hôtels',
      emoji: '🏨',
      icon: Icons.hotel_rounded,
      type: PlaceCategory.hotels,
      color: AppColors.catHotel,
    ),
    _CategoryData(
      name: 'Marchés',
      emoji: '🛍️',
      icon: Icons.storefront_rounded,
      type: PlaceCategory.markets,
      color: AppColors.catMarket,
    ),
    _CategoryData(
      name: 'Activités & Loisirs',
      emoji: '🎯',
      icon: Icons.local_activity_rounded,
      type: PlaceCategory.activitiesAndEntertainment,
      color: AppColors.catActivity,
    ),
    _CategoryData(
      name: 'Services',
      emoji: '🚕',
      icon: Icons.local_taxi_rounded,
      type: PlaceCategory.services,
      color: AppColors.catService,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.of(context).isDark;
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catégories',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explorez par type de lieu',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSubText
                          : AppColors.lightSubText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Grid ──────────────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 100),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.88,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return AnimatedBuilder(
                    animation: appState,
                    builder: (context, _) {
                      final count = appState
                          .getPlacesByCategory(cat.type)
                          .length;
                      return _CategoryCard(
                        data: cat,
                        count: count,
                        isDark: isDark,
                        index: index,
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

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  final _CategoryData data;
  final int count;
  final bool isDark;
  final int index;

  const _CategoryCard({
    required this.data,
    required this.count,
    required this.isDark,
    required this.index,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.data;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        _navigate(context);
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.categoryGradient(cat.color),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: cat.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background large emoji
              Positioned(
                right: -8,
                bottom: -8,
                child: Text(
                  cat.emoji,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat.icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      cat.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.count} lieu${widget.count != 1 ? 'x' : ''}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailsScreen(
          categoryName: widget.data.name,
          categoryType: widget.data.type,
          categoryColor: widget.data.color,
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final String emoji;
  final IconData icon;
  final PlaceCategory type;
  final Color color;

  const _CategoryData({
    required this.name,
    required this.emoji,
    required this.icon,
    required this.type,
    required this.color,
  });
}
