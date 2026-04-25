import 'package:flutter/material.dart';
import '../main.dart';
import '../models/tourist_place.dart';
import 'place_detail_screen.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;
  final PlaceCategory categoryType;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.categoryType,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final color = categoryType.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          final places = appState.getPlacesByCategory(categoryType);

          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun lieu trouvé dans cette catégorie.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _PlaceCard(place: place, color: color);
            },
          );
        },
      ),
    );
  }
}

// ── Carte de lieu ────────────────────────────────────────────────

class _PlaceCard extends StatelessWidget {
  final TouristPlace place;
  final Color color;

  const _PlaceCard({required this.place, required this.color});

  @override
  Widget build(BuildContext context) {
    final hasLocation = place.wilaya != null || place.moughataa != null;
    final hasPhotos = place.photos.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailScreen(place: place),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image principale ──────────────────────────────────
            Stack(
              children: [
                place.buildImage(
                    height: 200, width: double.infinity, fit: BoxFit.cover),
                // Badge nombre de photos
                if (hasPhotos)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${place.photos.length + 1} photos',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── Contenu texte ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  if (place.name.isNotEmpty)
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  // Localisation (wilaya + moughataa)
                  if (hasLocation) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (place.wilaya != null)
                          _MiniChip(
                            icon: Icons.map_outlined,
                            label: place.wilaya!,
                            color: Colors.blue,
                          ),
                        if (place.moughataa != null)
                          _MiniChip(
                            icon: Icons.location_city_outlined,
                            label: place.moughataa!,
                            color: Colors.indigo,
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Description (tronquée)
                  Text(
                    place.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Bouton "Voir plus" + lien Maps
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Voir les détails'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlaceDetailScreen(place: place),
                              ),
                            );
                          },
                        ),
                      ),
                      if (place.addressUrl != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.directions),
                          color: color,
                          tooltip: 'Voir sur Maps',
                          style: IconButton.styleFrom(
                            backgroundColor: color.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(place.addressUrl!),
                                action: SnackBarAction(
                                    label: 'OK', onPressed: () {}),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Petit chip d'info ────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
