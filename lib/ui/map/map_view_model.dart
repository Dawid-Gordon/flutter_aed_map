import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import '../../data/repositories/features_repository.dart';

class MapViewModel extends ChangeNotifier {
  final FeaturesRepository _repository = FeaturesRepository();
  final loc.Location _location = loc.Location();

  String? _geoJsonData;
  String? get geoJsonData => _geoJsonData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadFeatures() async {
    _isLoading = true;
    notifyListeners();

    _geoJsonData = await _repository.getFeaturesAsGeoJson();

    _isLoading = false;
    notifyListeners();
  }

  Future<Point?> getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return null;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return null;
    }

    locationData = await _location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      return Point(coordinates: Position(locationData.longitude!, locationData.latitude!));
    }
    return null;
  }
}
