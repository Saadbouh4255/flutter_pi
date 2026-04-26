import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/tourist_place.dart';

class AppState extends ChangeNotifier {
  List<TouristPlace> _places = [];
  Timer? _timer;

  List<TouristPlace> get places => _places;

  // ────────────────────────────────────────────────────────────
  // Restaurants célèbres de Nouakchott – données statiques locales
  // ────────────────────────────────────────────────────────────
  static final List<TouristPlace> _localRestaurants = [
    TouristPlace(
      id: 'local_rest_001',
      name: 'Nouakchott Night',
      imagePath: 'lib/data/photos/nkc_night/photo1.jpeg',
      description:
          'Restaurant réputé pour sa cuisine mauritanienne authentique. '
          'Idéal pour découvrir la gastronomie locale dans une ambiance chaleureuse.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.app.goo.gl/8EG2H5tyyBQVPvjL8',
      photos: [
        'lib/data/photos/nkc_night/photo2.jpeg',
        'lib/data/photos/nkc_night/photo1.jpeg',
        'lib/data/photos/nkc_night/photo3.jpeg',
        'lib/data/photos/nkc_night/photo4.jpeg',
        'lib/data/photos/nkc_night/photo5.jpeg',
      ],
    ),
    TouristPlace(
      id: 'local_rest_002',
      name: 'Restaurant Kemal',
      imagePath: 'lib/data/photos/kemal/photo1.jpeg',
      description:
          'Cuisine variée mêlant spécialités mauritaniennes et levantines. '
          'Cadre chaleureux et portions généreuses au cœur de Tevragh Zeïna.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.app.goo.gl/TkweeEDbKhcLboVv8',
      photos: [
        'lib/data/photos/kemal/photo1.jpeg',
        'lib/data/photos/kemal/photo2.jpeg',
        'lib/data/photos/kemal/photo3.jpeg',
        'lib/data/photos/kemal/photo4.jpeg',
        'lib/data/photos/kemal/photo5.jpeg',

      ],
    ),


    TouristPlace(
      id: 'local_rest_003',
      name: "Restaurant l'endroit parfait",
      imagePath: 'lib/data/photos/endroit/photo1.jpeg',
      description:
          'Lieu prisé pour sa cuisine généreuse, ses spécialités de tagine et son poisson grillé. '
          'Ambiance décontractée et service attentionné.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Sud',
      moughataa: 'Arafat',
      addressUrl: 'https://maps.app.goo.gl/F3ThCyvRfa4Vvjd59',
      photos: [
        'lib/data/photos/endroit/photo6.jpeg',
        'lib/data/photos/endroit/photo2.jpeg',
        'lib/data/photos/endroit/photo3.jpeg',
        'lib/data/photos/endroit/photo4.jpeg',
        'lib/data/photos/endroit/photo5.jpeg',
      ],
    ),
    TouristPlace(
      id: 'local_rest_004',
      name: 'Restaurant Trend',
      imagePath: 'lib/data/photos/trend/photo1.jpeg',
      description:
          'Véritable référence de la cuisine mauritanienne traditionnelle. '
          'Dégustez des plats ancestraux dans un cadre authentique au Ksar.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Ksar',
      addressUrl: 'https://maps.google.com/?q=Ksar+Nouakchott+Mauritania',
      photos: [
        'lib/data/photos/trend/photo1.jpeg',
        'lib/data/photos/trend/photo2.jpeg',
        'lib/data/photos/trend/photo3.jpeg',
        'lib/data/photos/trend/photo4.jpeg',
        'lib/data/photos/trend/photo5.jpeg',
      ],
    ),
    TouristPlace(
      id: 'local_rest_005',
      name: 'Restaurant Mondial pizza',
      imagePath: 'lib/data/photos/mondial/photo1.jpeg',
      description:
          'Restaurant de luxe proposant une cuisine internationale et locale raffinée. '
          'Idéal pour des repas d\'affaires ou des occasions spéciales.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.app.goo.gl/JURVubGNaCnuT1zg8',
      photos: [
        'lib/data/photos/mondial/photo1.jpeg',
        'lib/data/photos/mondial/photo2.jpeg',
        'lib/data/photos/mondial/photo3.jpeg',
        'lib/data/photos/mondial/photo4.jpeg',
        'lib/data/photos/mondial/photo5.jpeg',
      ],
    ),
  ];

  AppState() {
    fetchPlaces();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchPlaces();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _lastResponseBody;

  Future<void> fetchPlaces() async {
    try {
      final response =
          await http.get(Uri.parse('https://nouakchott-backend-3.onrender.com/api/places'));
      if (response.statusCode == 200) {
        if (_lastResponseBody == response.body) {
          return; // Aucun changement, pas de reconstruction de l'UI
        }
        _lastResponseBody = response.body;

        final dynamic decodedData = json.decode(response.body);
        final List<dynamic> data =
            decodedData is List ? decodedData : (decodedData['places'] ?? []);

        final List<TouristPlace> parsed = [];
        for (var item in data) {
          try {
            parsed.add(TouristPlace.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            print('Failed to parse place: $e');
          }
        }

        // Fusionner avec les restaurants locaux (anti-doublons par ID)
        final Set<String> existingIds = parsed.map((p) => p.id).toSet();
        for (final localRestaurant in _localRestaurants) {
          if (!existingIds.contains(localRestaurant.id)) {
            parsed.add(localRestaurant);
          }
        }

        _places = parsed;
        notifyListeners();
      } else {
        print('Failed to load places: ${response.statusCode}');
        if (_places.isEmpty) {
          _places = List.from(_localRestaurants);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading places: $e');
      if (_places.isEmpty) {
        _places = List.from(_localRestaurants);
        notifyListeners();
      }
    }
  }

  List<TouristPlace> getPlacesByCategory(PlaceCategory category) {
    return _places.where((p) => p.category == category).toList();
  }

  List<TouristPlace> searchPlaces(String query) {
    final lowerQuery = query.toLowerCase();
    return _places.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
