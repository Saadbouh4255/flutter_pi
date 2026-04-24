import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/tourist_place.dart';

class AppState extends ChangeNotifier {
  List<TouristPlace> _places = [];
  Timer? _timer;

  List<TouristPlace> get places => _places;

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
      final response = await http.get(Uri.parse('https://nouakchott-backend-3.onrender.com/api/places'));
      if (response.statusCode == 200) {
        if (_lastResponseBody == response.body) {
          return; // No changes, skip rebuilding UI
        }
        _lastResponseBody = response.body;

        final dynamic decodedData = json.decode(response.body);
        final List<dynamic> data = decodedData is List ? decodedData : (decodedData['places'] ?? []);
        
        final List<TouristPlace> parsed = [];
        for (var item in data) {
          try {
            parsed.add(TouristPlace.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            print('Failed to parse place: $e');
          }
        }
        _places = parsed;
        notifyListeners();
      } else {
        print('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading places: $e');
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
