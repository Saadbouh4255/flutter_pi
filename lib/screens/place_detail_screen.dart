import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tourist_place.dart';

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

  // Liste combinée : image principale + photos supplémentaires
  List<String> get _allPhotos {
    final list = <String>[];
    if (widget.place.imagePath.isNotEmpty) list.add(widget.place.imagePath);
    for (final p in widget.place.photos) {
      if (!list.contains(p)) list.add(p);
    }
    return list;
  }

  /// Ouvrir un lien (Google Maps ou autre) dans l'application externe
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossible d\'ouvrir le lien.'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  /// Afficher une image : asset local (lib/...) ou URL réseau (http...)
  Widget _buildPhoto(String path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (ctx, e, s) => _photoError(),
      );
    } else {
      return Image.asset(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (ctx, e, s) => _photoError(),
      );
    }
  }

  Widget _photoError() => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final photos = _allPhotos;
    final color = place.category.color;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ── AppBar avec carousel de photos ──────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
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
                      itemBuilder: (context, index) {
                        return _buildPhoto(
                          photos[index],
                          height: double.infinity,
                          width: double.infinity,
                        );
                      },
                    )
                  else
                    Container(
                      color: color.withOpacity(0.3),
                      child: Center(
                        child: Icon(Icons.restaurant,
                            size: 80, color: Colors.white70),
                      ),
                    ),
                  // Dégradé bas
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Indicateurs de page
                  if (photos.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPhotoIndex == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == i
                                  ? Colors.white
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Badge nombre de photos
                  if (photos.length > 1)
                    Positioned(
                      top: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentPhotoIndex + 1}/${photos.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Contenu principal ────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte titre + badges
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégorie badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          place.category.displayName,
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nom
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Wilaya & Moughataa chips
                      if (place.wilaya != null || place.moughataa != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (place.wilaya != null)
                              _InfoChip(
                                icon: Icons.map_outlined,
                                label: place.wilaya!,
                                color: Colors.blue,
                              ),
                            if (place.moughataa != null)
                              _InfoChip(
                                icon: Icons.location_city_outlined,
                                label: place.moughataa!,
                                color: Colors.indigo,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Description ──────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: '📝 Description', color: color),
                      const SizedBox(height: 10),
                      Text(
                        place.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Localisation ──────────────────────────────────────
                if (place.wilaya != null ||
                    place.moughataa != null ||
                    place.addressUrl != null)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                            title: '📍 Localisation', color: color),
                        const SizedBox(height: 12),
                        if (place.wilaya != null)
                          _LocationRow(
                            icon: Icons.map,
                            label: 'Wilaya',
                            value: place.wilaya!,
                            iconColor: Colors.blue,
                          ),
                        if (place.moughataa != null) ...[
                          const SizedBox(height: 8),
                          _LocationRow(
                            icon: Icons.location_city,
                            label: 'Moughataa',
                            value: place.moughataa!,
                            iconColor: Colors.indigo,
                          ),
                        ],
                        if (place.addressUrl != null) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.directions, size: 20),
                              label: const Text(
                                'Ouvrir dans Google Maps',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _openUrl(place.addressUrl!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Galerie photos ────────────────────────────────────
                if (photos.length > 1)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                            title: '🖼️ Photos (${photos.length})',
                            color: color),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: photos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final isActive = i == _currentPhotoIndex;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    i,
                                    duration:
                                        const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                  );
                                  setState(() => _currentPhotoIndex = i);
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: isActive
                                        ? Border.all(color: color, width: 3)
                                        : null,
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color:
                                                  color.withOpacity(0.4),
                                              blurRadius: 8,
                                            )
                                          ]
                                        : null,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildPhoto(photos[i]),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets utilitaires ──────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _LocationRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
