// lib/services/location_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/web_js.dart';

class LocationResult {
  final LatLng coordinates;
  final double accuracy;
  final String? address;

  LocationResult({
    required this.coordinates,
    this.accuracy = 0.0,
    this.address,
  });
}

class LocationService {
  static const String _prefLatKey = 'last_known_lat';
  static const String _prefLngKey = 'last_known_lng';
  static const String _prefAddressKey = 'last_known_address';

  /// Request current GPS location from browser
  static Future<LocationResult?> getCurrentLocation() async {
    if (!kIsWeb) return null;

    final completer = Completer<LocationResult?>();

    try {
      WebJs.callMethod('goChefGetLocation', [
        (dynamic latVal, dynamic lngVal, dynamic accVal) async {
          final lat = (latVal as num).toDouble();
          final lng = (lngVal as num).toDouble();
          final acc = (accVal as num).toDouble();
          final loc = LatLng(lat, lng);

          // Save to local cache
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble(_prefLatKey, lat);
            await prefs.setDouble(_prefLngKey, lng);
          } catch (_) {}

          // Attempt reverse geocoding in background
          String? addressName;
          try {
            addressName = await getAddressFromCoordinates(lat, lng);
            if (addressName != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_prefAddressKey, addressName);
            }
          } catch (_) {}

          if (!completer.isCompleted) {
            completer.complete(LocationResult(
              coordinates: loc,
              accuracy: acc,
              address: addressName,
            ));
          }
        },
        (dynamic error) {
          debugPrint('GoChef Geolocation error: ');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ]);
    } catch (e) {
      debugPrint('GoChef Geolocation exception: ');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }

    // Safety timeout after 10 seconds
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  }

  /// Get cached last known location if available
  static Future<LatLng?> getLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_prefLatKey);
      final lng = prefs.getDouble(_prefLngKey);
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    } catch (_) {}
    return null;
  }

  /// Get cached last known address if available
  static Future<String?> getLastKnownAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefAddressKey);
    } catch (_) {}
    return null;
  }

  /// Reverse geocode coordinates to human readable address (City, Sub-district)
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat.toString() + '&lon=' + lng.toString() + '&zoom=14&addressdetails=1',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'GoChef-App-Web/1.0',
        'Accept-Language': 'id,en',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ?? address['town'] ?? address['city_district'] ?? address['municipality'] ?? address['county'] ?? address['state'];
          final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['village'] ?? address['quarter'] ?? address['road'];
          if (suburb != null && city != null) {
            return '$suburb, $city';
          }
          return (city ?? data['display_name'] ?? '').toString();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Forward geocode query to search for places/cities/neighborhoods
  static Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=' +
            Uri.encodeComponent(query.trim()) +
            '&limit=5&addressdetails=1',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'GoChef-App-Web/1.0',
        'Accept-Language': 'id,en',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) {
          return {
            'display_name': item['display_name']?.toString() ?? '',
            'lat': double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
            'lon': double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
          };
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
