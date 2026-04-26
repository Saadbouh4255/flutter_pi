import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/tourist_place.dart';
import '../theme/app_theme.dart';

class PlaceDetailScreen extends StatefulWidget {
  final TouristPlace place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _allPhotos {
    final list = <String>[];
    if (widget.place.imagePath.isNotEmpty) list.add(widget.place.imagePath);
    for (final p in widget.place.photos) {
      if (!list.contains(p)) list.add(p);
    }
    return list;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir le lien.',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.catActivity,
          ),
        );
      }
    }
  }

  Widget _buildPhoto(String path,
      {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: BoxFit.contain,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        },
        errorBuilder: (ctx, e, s) => _photoError(height),
      );
    } else {
      return Image.asset(
        path,
        height: height,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (ctx, e, s) => _photoError(height),
      );
    }
  }

  Widget _photoError([double? height]) => Container(
        height: height ?? 200,
        color: const Color(0xFF1C2230),
        child: const Center(
          child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.white30),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final photos = _allPhotos;
    final color = place.category.color;
    final isDark = ThemeProvider.of(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero Carousel AppBar ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : color,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Carousel
                  if (photos.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: photos.length,
                      onPageChanged: (i) =>
                          setState(() => _currentPhotoIndex = i),
                      itemBuilder: (context, index) => _buildPhoto(
                        photos[index],
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.categoryGradient(color),
                      ),
                      child: Center(
                        child: Icon(Icons.photo_rounded,
                            size: 80, color: Colors.white24),
                      ),
                    ),

                  // Bottom gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.heroOverlay,
                      ),
                    ),
                  ),

                  // Photo counter badge
                  if (photos.length > 1)
                    Positioned(
                      top: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded,
                                color: Colors.white, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              '${_currentPhotoIndex + 1} / ${photos.length}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Dot indicators
                  if (photos.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPhotoIndex == i ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == i
                                  ? AppColors.gold
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Body Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title Section ──────────────────────────────────────────
                _Section(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppGradients.categoryGradient(color),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          place.category.displayName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Place name
                      Text(
                        place.name,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Location chips
                      if (place.wilaya != null || place.moughataa != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (place.wilaya != null)
                              _InfoChip(
                                icon: Icons.map_rounded,
                                label: place.wilaya!,
                                color: AppColors.catTourist,
                              ),
                            if (place.moughataa != null)
                              _InfoChip(
                                icon: Icons.location_city_rounded,
                                label: place.moughataa!,
                                color: AppColors.catHotel,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── Description ────────────────────────────────────────────
                _Section(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          title: 'Description',
                          icon: Icons.description_rounded,
                          color: color,
                          isDark: isDark),
                      const SizedBox(height: 12),
                      Text(
                        place.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.8,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── Location & Maps ────────────────────────────────────────
                if (place.wilaya != null ||
                    place.moughataa != null ||
                    place.addressUrl != null)
                  _Section(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                            title: 'Localisation',
                            icon: Icons.location_on_rounded,
                            color: color,
                            isDark: isDark),
                        const SizedBox(height: 14),
                        if (place.wilaya != null)
                          _LocationRow(
                            icon: Icons.map_rounded,
                            label: 'Wilaya',
                            value: place.wilaya!,
                            color: AppColors.catTourist,
                            isDark: isDark,
                          ),
                        if (place.moughataa != null) ...[
                          const SizedBox(height: 10),
                          _LocationRow(
                            icon: Icons.location_city_rounded,
                            label: 'Moughataa',
                            value: place.moughataa!,
                            color: AppColors.catHotel,
                            isDark: isDark,
                          ),
                        ],
                        if (place.addressUrl != null) ...[
                          const SizedBox(height: 18),
                          _MapsButton(
                            onTap: () => _openUrl(place.addressUrl!),
                            color: color,
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // ── Photo Gallery ──────────────────────────────────────────
                if (photos.length > 1)
                  _Section(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                            title: 'Photos (${photos.length})',
                            icon: Icons.photo_library_rounded,
                            color: color,
                            isDark: isDark),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: photos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final isActive = i == _currentPhotoIndex;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(i,
                                      duration:
                                          const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut);
                                  setState(() => _currentPhotoIndex = i);
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: isActive
                                        ? Border.all(
                                            color: AppColors.gold, width: 2.5)
                                        : Border.all(
                                            color: isDark
                                                ? AppColors.darkBorder
                                                : AppColors.lightBorder),
                                    boxShadow: isActive
                                        ? AppShadows.glow(AppColors.gold)
                                        : null,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildPhoto(photos[i],
                                      fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Section({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION ROW
// ─────────────────────────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _LocationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAPS BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _MapsButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;

  const _MapsButton({required this.onTap, required this.color});

  @override
  State<_MapsButton> createState() => _MapsButtonState();
}

class _MapsButtonState extends State<_MapsButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
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
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: AppGradients.categoryGradient(widget.color),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ouvrir dans Google Maps',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
