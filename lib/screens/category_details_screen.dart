import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/tourist_place.dart';
import '../theme/app_theme.dart';
import 'place_detail_screen.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;
  final PlaceCategory categoryType;
  final Color categoryColor;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.categoryType,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = ThemeProvider.of(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final places = appState.getPlacesByCategory(categoryType);

          return CustomScrollView(
            slivers: [
              // ── Premium SliverAppBar ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor:
                    isDark ? AppColors.darkSurface : Colors.white,
                foregroundColor:
                    isDark ? AppColors.darkText : AppColors.lightText,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.categoryGradient(categoryColor),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              categoryName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${places.length} lieu${places.length != 1 ? 'x' : ''} trouvé${places.length != 1 ? 's' : ''}',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Empty state ─────────────────────────────────────────────
              if (places.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(
                      color: categoryColor, isDark: isDark),
                )
              else
                // ── Place list ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PlaceCard(
                          place: places[index],
                          color: categoryColor,
                          isDark: isDark,
                          index: index,
                        ),
                      ),
                      childCount: places.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceCard extends StatefulWidget {
  final TouristPlace place;
  final Color color;
  final bool isDark;
  final int index;

  const _PlaceCard({
    required this.place,
    required this.color,
    required this.isDark,
    required this.index,
  });

  @override
  State<_PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<_PlaceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final color = widget.color;
    final isDark = widget.isDark;
    final hasPhotos = place.photos.isNotEmpty;

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
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.card(color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image ──────────────────────────────────────────────────
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: Stack(
                  children: [
                    place.buildImage(
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover),
                    // Gradient bottom overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Photo count badge
                    if (hasPhotos)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_rounded,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${place.photos.length + 1}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Category badge
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppGradients.categoryGradient(color),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          place.category.displayName
                              .replaceAll(RegExp(r'[^\w\s]'), '')
                              .trim(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (place.name.isNotEmpty)
                      Text(
                        place.name,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),

                    // Location chips
                    if (place.wilaya != null || place.moughataa != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (place.wilaya != null)
                            _LocationChip(
                              icon: Icons.map_rounded,
                              label: place.wilaya!,
                              color: AppColors.catTourist,
                            ),
                          if (place.moughataa != null)
                            _LocationChip(
                              icon: Icons.location_city_rounded,
                              label: place.moughataa!,
                              color: AppColors.catHotel,
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    Text(
                      place.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark
                            ? AppColors.darkSubText
                            : AppColors.lightSubText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 14),

                    // ── Action row ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _GradientButton(
                            label: 'Voir les détails',
                            icon: Icons.arrow_forward_rounded,
                            gradient: AppGradients.categoryGradient(color),
                            onTap: () => _navigate(context),
                          ),
                        ),
                        if (place.addressUrl != null) ...[
                          const SizedBox(width: 10),
                          _MapsButton(
                              url: place.addressUrl!, color: color),
                        ],
                      ],
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
        builder: (_) => PlaceDetailScreen(place: widget.place),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _LocationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LocationChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: Colors.white, size: 15),
          ],
        ),
      ),
    );
  }
}

class _MapsButton extends StatelessWidget {
  final String url;
  final Color color;

  const _MapsButton({required this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(Icons.directions_rounded, color: color, size: 20),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color color;
  final bool isDark;
  const _EmptyState({required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun lieu trouvé',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Revenez plus tard, de nouveaux lieux seront ajoutés.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
