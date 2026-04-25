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
      name: 'Restaurant Tfeila',
      imagePath: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&auto=format',
      description:
          'Le Restaurant Tfeila est l\'un des établissements les plus réputés de Nouakchott. '
          'Spécialisé dans la cuisine mauritanienne traditionnelle, il propose des plats '
          'authentiques comme le thieboudienne, le méchoui et la chèvre grillée. '
          'Un endroit incontournable pour découvrir la gastronomie locale dans une ambiance chaleureuse.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.google.com/?q=Tevragh+Zeina+Nouakchott+Mauritania',
      photos: [
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&auto=format',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format',
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&auto=format',
        'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&auto=format',
      ],
    ),
    TouristPlace(
      id: 'local_rest_002',
      name: 'Restaurant Kemal',
      imagePath: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format',
      description:
          'Le Restaurant Kemal est un établissement très apprécié de Nouakchott, '
          'situé dans le quartier Tevragh Zeïna. Il propose une cuisine variée mêlant '
          'spécialités mauritaniennes, plats levantins et grillades savoureuses. '
          'Son cadre chaleureux, son service attentionné et ses portions généreuses '
          'en font une adresse incontournable pour les habitants et les visiteurs de la capitale.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.app.goo.gl/TkweeEDbKhcLboVv8',
      photos: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format',
        'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&auto=format',
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format',
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&auto=format',
      ],
    ),

    TouristPlace(
      id: 'local_rest_003',
      name: 'Restaurant Oasis',
      imagePath: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format',
      description:
          'Le Restaurant Oasis est un lieu prisé des habitants et des touristes pour sa cuisine '
          'variée et ses portions généreuses. Spécialités du chef : tagine d\'agneau aux pruneaux, '
          'couscous royal et poisson du jour grillé. L\'ambiance décontractée et le service '
          'attentionné en font une adresse incontournable à Nouakchott.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Sud',
      moughataa: 'Arafat',
      addressUrl: 'https://maps.google.com/?q=Arafat+Nouakchott+Mauritania',
      photos: [
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format',
        'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800&auto=format',
        'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=800&auto=format',
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format',
      ],
    ),
    TouristPlace(
      id: 'local_rest_004',
      name: 'Restaurant Le Sahara',
      imagePath: 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=800&auto=format',
      description:
          'Le Sahara est le restaurant de référence pour les amateurs de cuisine traditionnelle '
          'mauritanienne. Les mets préparés selon des recettes ancestrales, notamment le riz au '
          'lait de chamelle, le pain maure cuit dans le sable et les dattes farcies aux amandes, '
          'font la réputation de cet établissement authentique au cœur de la ville.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Ksar',
      addressUrl: 'https://maps.google.com/?q=Ksar+Nouakchott+Mauritania',
      photos: [
        'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=800&auto=format',
        'https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=800&auto=format',
        'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&auto=format',
        'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?w=800&auto=format',
      ],
    ),
    TouristPlace(
      id: 'local_rest_005',
      name: 'Restaurant El Mouna',
      imagePath: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800&auto=format',
      description:
          'El Mouna est un restaurant de luxe offrant une cuisine internationale de qualité dans '
          'un cadre raffiné. Son menu propose des spécialités françaises, libanaises et '
          'mauritaniennes, accompagnées d\'une sélection de jus de fruits frais. Idéal pour '
          'les dîners d\'affaires et les occasions spéciales dans la capitale mauritanienne.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.google.com/?q=El+Mouna+Hotel+Nouakchott',
      photos: [
        'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800&auto=format',
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&auto=format',
        'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&auto=format',
        'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=800&auto=format',
      ],
    ),
    TouristPlace(
      id: 'local_rest_006',
      name: 'Restaurant Dar Beida',
      imagePath: 'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=800&auto=format',
      description:
          'Dar Beida est un restaurant marocain-mauritanien situé dans le quartier Tevragh Zeïna. '
          'Sa terrasse panoramique offre une vue magnifique sur la ville. Les tajines, les pastillas '
          'et les thés à la menthe sont les spécialités de la maison. Une expérience culinaire '
          'unique dans un décor oriental enchanteur, à deux pas du centre-ville.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Tevragh Zeïna',
      addressUrl: 'https://maps.google.com/?q=Dar+Beida+Tevragh+Zeina+Nouakchott',
      photos: [
        'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=800&auto=format',
        'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&auto=format',
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&auto=format',
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=800&auto=format',
      ],
    ),
    TouristPlace(
      id: 'local_rest_007',
      name: 'Restaurant Chez Cheikh',
      imagePath: 'https://images.unsplash.com/photo-1590846406792-0adc7f938f1d?w=800&auto=format',
      description:
          'Chez Cheikh est une institution à Nouakchott, connue pour ses grillades de viande et '
          'ses poissons frais du marché. Depuis plus de 20 ans, ce restaurant familial régale ses '
          'clients avec des recettes transmises de génération en génération. La viande hachée épicée '
          'et le poisson yassa sont les plats phares de l\'établissement, toujours bondé à l\'heure du déjeuner.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Nord',
      moughataa: 'Teyarett',
      addressUrl: 'https://maps.google.com/?q=Teyarett+Nouakchott+Mauritania',
      photos: [
        'https://images.unsplash.com/photo-1590846406792-0adc7f938f1d?w=800&auto=format',
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format',
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format',
      ],
    ),
    TouristPlace(
      id: 'local_rest_008',
      name: 'Restaurant Riviera',
      imagePath: 'https://images.unsplash.com/photo-1428515613728-6b4607e44363?w=800&auto=format',
      description:
          'Le Restaurant Riviera est un établissement moderne avec une vue imprenable sur '
          'l\'Atlantique. Il propose une cuisine de fruits de mer exceptionnelle avec des langoustes, '
          'crevettes et poissons frais pêchés chaque matin. C\'est l\'endroit idéal pour déguster '
          'les richesses maritimes de la Mauritanie dans un cadre contemporain et élégant face à l\'océan.',
      category: PlaceCategory.restaurants,
      wilaya: 'Nouakchott-Ouest',
      moughataa: 'Sebkha',
      addressUrl: 'https://maps.google.com/?q=Plage+Sebkha+Nouakchott+Mauritania',
      photos: [
        'https://images.unsplash.com/photo-1428515613728-6b4607e44363?w=800&auto=format',
        'https://images.unsplash.com/photo-1519984388953-d2406bc725e1?w=800&auto=format',
        'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=800&auto=format',
        'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=800&auto=format',
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
