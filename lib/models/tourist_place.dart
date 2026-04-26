import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


enum PlaceCategory {
  touristPlaces,
  restaurants,
  hotels,
  markets,
  activitiesAndEntertainment,
  services
}

class TouristPlace {
  final String id;
  final String name;
  final String imagePath;
  final String description;
  final PlaceCategory category;

  // Champs supplémentaires (optionnels)
  final String? wilaya;
  final String? moughataa;
  final String? addressUrl;
  final List<String> photos;

  Uint8List? _cachedImageBytes;

  TouristPlace({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
    required this.category,
    this.wilaya,
    this.moughataa,
    this.addressUrl,
    this.photos = const [],
  });

  factory TouristPlace.fromJson(Map<String, dynamic> json) {
    return TouristPlace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      wilaya: json['wilaya']?.toString(),
      moughataa: json['moughataa']?.toString(),
      addressUrl: json['addressUrl']?.toString(),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: PlaceCategory.values.firstWhere(
        (e) {
          final catString = json['category']?.toString();
          if (catString == null) return false;

          final lowerCat = catString.toLowerCase();
          final enumName = e.name.toLowerCase();

          if (e.toString() == catString || enumName == lowerCat) {
            return true;
          }

          if (enumName == 'touristplaces' &&
              (lowerCat.contains('touristique') || lowerCat.contains('tourist'))) return true;
          if (enumName == 'restaurants' && lowerCat.contains('restaurant')) return true;
          if (enumName == 'hotels' &&
              (lowerCat.contains('hotel') || lowerCat.contains('hôtel'))) return true;
          if (enumName == 'markets' &&
              (lowerCat.contains('marché') ||
                  lowerCat.contains('market') ||
                  lowerCat.contains('marche'))) return true;
          if (enumName == 'activitiesandentertainment' &&
              (lowerCat.contains('activit') || lowerCat.contains('loisir'))) return true;
          if (enumName == 'services' && lowerCat.contains('service')) return true;

          return false;
        },
        orElse: () => PlaceCategory.touristPlaces,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'description': description,
      'category': category.name,
      if (wilaya != null) 'wilaya': wilaya,
      if (moughataa != null) 'moughataa': moughataa,
      if (addressUrl != null) 'addressUrl': addressUrl,
      if (photos.isNotEmpty) 'photos': photos,
    };
  }

  Widget buildImage({double? height, double? width, BoxFit? fit}) {
    return _buildImageFromPath(imagePath, height: height, width: width, fit: fit);
  }

  Widget buildPhotoAt(int index, {double? height, double? width, BoxFit? fit}) {
    if (index < photos.length) {
      return _buildImageFromPath(photos[index], height: height, width: width, fit: fit);
    }
    return _errorContainer(height);
  }

  Widget _buildImageFromPath(String path,
      {double? height, double? width, BoxFit? fit}) {
    if (path.isEmpty) return _errorContainer(height);

    if (path.startsWith('data:image')) {
      // Image encodée en Base64
      if (_cachedImageBytes == null) {
        final base64Str = path.split(',').last;
        _cachedImageBytes = base64Decode(base64Str);
      }
      return Image.memory(
        _cachedImageBytes!,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _errorContainer(height),
      );
    } else if (path.startsWith('http')) {
      // Image distante
      return Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _errorContainer(height),
      );
    } else {
      // Asset Flutter local (lib/... ou assets/...)
      return Image.asset(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorContainer(height),
      );
    }
  }

  Widget _errorContainer(double? height) {
    return Container(
      height: height ?? 200,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
    );
  }
}

extension PlaceCategoryExtension on PlaceCategory {
  String get displayName {
    switch (this) {
      case PlaceCategory.touristPlaces:
        return '🏛️ Lieux touristiques';
      case PlaceCategory.restaurants:
        return '🍽️ Restaurants';
      case PlaceCategory.hotels:
        return '🏨 Hôtels';
      case PlaceCategory.markets:
        return '🛍️ Marchés';
      case PlaceCategory.activitiesAndEntertainment:
        return '🎯 Activités et loisirs';
      case PlaceCategory.services:
        return '🚕 Services';
    }
  }

  Color get color {
    switch (this) {
      case PlaceCategory.touristPlaces:
        return AppColors.catTourist;
      case PlaceCategory.restaurants:
        return AppColors.catRestaurant;
      case PlaceCategory.hotels:
        return AppColors.catHotel;
      case PlaceCategory.markets:
        return AppColors.catMarket;
      case PlaceCategory.activitiesAndEntertainment:
        return AppColors.catActivity;
      case PlaceCategory.services:
        return AppColors.catService;
    }
  }
}
