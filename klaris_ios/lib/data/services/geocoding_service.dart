import 'package:flutter/services.dart';

/// Forward geocoding via native CLGeocoder MethodChannel.
/// Native side: ios/Runner/GeocodingBridge.swift
class GeocodingService {
  GeocodingService._();
  static final instance = GeocodingService._();

  static const _ch = MethodChannel('ai.klarisapp.klaris_ios/geocoding');

  /// Returns (latitude, longitude) for a free-form address string. Null on failure.
  Future<({double lat, double lng})?> forward(String address) async {
    if (address.trim().isEmpty) return null;
    try {
      final res = await _ch.invokeMapMethod<String, double>('forward', {'address': address});
      if (res == null || res['lat'] == null || res['lng'] == null) return null;
      return (lat: res['lat']!, lng: res['lng']!);
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
