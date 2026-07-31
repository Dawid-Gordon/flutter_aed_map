import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DbHelper {
  static Database? _database;
  static const String tableName = 'features';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS $tableName');
          await _createTable(db);
        }
      },
    );
  }

  Future<void> _createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $tableName('
      'id TEXT PRIMARY KEY, '
      'longitude REAL, '
      'latitude REAL, '
      'version INTEGER, '
      'type TEXT, '
      'check_date TEXT, '
      'location_desc TEXT'
      ')',
    );
  }

  Future<void> upsertFeature(Map<String, dynamic> feature) async {
    final db = await database;
    final properties = feature['properties'] as Map<String, dynamic>;
    final id = properties['@osm_id']?.toString();
    
    if (id == null) return;

    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final lng = (coordinates[0] as num).toDouble();
    final lat = (coordinates[1] as num).toDouble();

    await db.insert(
      tableName,
      {
        'id': id,
        'longitude': lng,
        'latitude': lat,
        'version': properties['@osm_version'],
        'type': properties['emergency'],
        'check_date': properties['check_date'],
        'location_desc': properties['defibrillator:location:pl'] ?? properties['defibrillator:location'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> importGeoJsonFromAssets(String assetPath) async {
    try {
      final startTime = DateTime.now();
      print('Start importing features from $assetPath');
      
      final String response = await rootBundle.loadString(assetPath);
      
      // Move JSON decoding to a background isolate
      final data = await compute(jsonDecode, response);
      final List<dynamic> features = data['features'];

      final db = await database;
      final batch = db.batch();

      for (var feature in features) {
        final map = feature as Map<String, dynamic>;
        final properties = map['properties'] as Map<String, dynamic>;
        final id = properties['@osm_id']?.toString();
        
        if (id == null) continue;

        final geometry = map['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;
        final lng = (coordinates[0] as num).toDouble();
        final lat = (coordinates[1] as num).toDouble();

        batch.insert(
          tableName,
          {
            'id': id,
            'longitude': lng,
            'latitude': lat,
            'version': properties['@osm_version'],
            'type': properties['emergency'],
            'check_date': properties['check_date'],
            'location_desc': properties['defibrillator:location:pl'] ?? properties['defibrillator:location'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      print('Imported ${features.length} features from $assetPath');
      print('Total time = ${DateTime.now().difference(startTime)}');
    } catch (e) {
      print('Error importing GeoJSON: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllFeatures() async {
    final db = await database;
    return await db.query(tableName);
  }
}
