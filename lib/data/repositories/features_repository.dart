import 'dart:convert';
import '../database/db_helper.dart';

class FeaturesRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<void> importGeoJson(String assetPath) async {
    await _dbHelper.importGeoJsonFromAssets(assetPath);
  }

  Future<String> getFeaturesAsGeoJson() async {
    final features = await _dbHelper.getAllFeatures();

    final geojson = {
      "type": "FeatureCollection",
      "features": features.map((f) {
        return {
          "type": "Feature",
          "id": f['id'],
          "geometry": {
            "type": "Point",
            "coordinates": [f['longitude'], f['latitude']]
          },
          "properties": {
            "id": f['id'],
            "longitude": f['longitude'],
            "latitude": f['latitude'],
            "type": f['type'],
            "check_date": f['check_date'],
            "version": f['version'],
            "location_desc": f['location_desc'],
          }
        };
      }).toList()
    };

    return jsonEncode(geojson);
  }
}
