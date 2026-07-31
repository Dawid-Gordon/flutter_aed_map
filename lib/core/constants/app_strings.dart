class AppStrings {
  static String _locale = 'en';

  static void setLocale(String locale) {
    if (_localizedValues.containsKey(locale)) {
      _locale = locale;
    } else {
      _locale = 'en'; // Fallback to English
    }
  }

  static String get locale => _locale;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'AED Map',
      'styleDefault': 'Default',
      'styleSatellite': 'Satellite',
      'styleOutdoors': 'Outdoors',
      'longitude': 'Longitude',
      'latitude': 'Latitude',
      'magnitude': 'Magnitude',
      'address': 'Address',
      'pinDetails': 'Pin Details',
      'type': 'Type',
      'checkDate': 'Check Date',
      'version': 'Version',
      'location': 'Location:',
      'noDescription': 'No description',
      'ok': 'OK',
      'na': 'N/A',
    },
    'pl': {
      'appTitle': 'AED Map',
      'styleDefault': 'Domyślny',
      'styleSatellite': 'Satelitarny',
      'styleOutdoors': 'Terenowy',
      'longitude': 'Długość',
      'latitude': 'Szerokość',
      'magnitude': 'Magnituda',
      'address': 'Adres',
      'pinDetails': 'Szczegóły punktu',
      'type': 'Typ',
      'checkDate': 'Data sprawdzenia',
      'version': 'Wersja',
      'location': 'Lokalizacja:',
      'noDescription': 'Brak opisu',
      'ok': 'OK',
      'na': 'Brak danych',
    },
    'de': {
      'appTitle': 'AED Map',
      'styleDefault': 'Standard',
      'styleSatellite': 'Satellit',
      'styleOutdoors': 'Outdoor',
      'longitude': 'Längengrad',
      'latitude': 'Breitengrad',
      'magnitude': 'Magnitude',
      'address': 'Adresse',
      'pinDetails': 'Pin-Details',
      'type': 'Typ',
      'checkDate': 'Prüfdatum',
      'version': 'Version',
      'location': 'Standort:',
      'noDescription': 'Keine Beschreibung',
      'ok': 'OK',
      'na': 'N/V',
    },
    'es': {
      'appTitle': 'AED Map',
      'styleDefault': 'Predeterminado',
      'styleSatellite': 'Satélite',
      'styleOutdoors': 'Aire libre',
      'longitude': 'Longitud',
      'latitude': 'Latitud',
      'magnitude': 'Magnitud',
      'address': 'Dirección',
      'pinDetails': 'Detalles del pin',
      'type': 'Tipo',
      'checkDate': 'Fecha de verificación',
      'version': 'Versión',
      'location': 'Ubicación:',
      'noDescription': 'Sin descripción',
      'ok': 'OK',
      'na': 'N/D',
    },
    'it': {
      'appTitle': 'AED Map',
      'styleDefault': 'Predefinito',
      'styleSatellite': 'Satellite',
      'styleOutdoors': 'All\'aperto',
      'longitude': 'Longitudine',
      'latitude': 'Latitudine',
      'magnitude': 'Magnitudo',
      'address': 'Indirizzo',
      'pinDetails': 'Dettagli pin',
      'type': 'Tipo',
      'checkDate': 'Data di verifica',
      'version': 'Versione',
      'location': 'Posizione:',
      'noDescription': 'Nessuna descrizione',
      'ok': 'OK',
      'na': 'N/D',
    },
  };

  static String get appTitle => _localizedValues[_locale]!['appTitle']!;
  static String get styleDefault => _localizedValues[_locale]!['styleDefault']!;
  static String get styleSatellite => _localizedValues[_locale]!['styleSatellite']!;
  static String get styleOutdoors => _localizedValues[_locale]!['styleOutdoors']!;
  static String get longitude => _localizedValues[_locale]!['longitude']!;
  static String get latitude => _localizedValues[_locale]!['latitude']!;
  static String get magnitude => _localizedValues[_locale]!['magnitude']!;
  static String get address => _localizedValues[_locale]!['address']!;
  static String get pinDetails => _localizedValues[_locale]!['pinDetails']!;
  static String get type => _localizedValues[_locale]!['type']!;
  static String get checkDate => _localizedValues[_locale]!['checkDate']!;
  static String get version => _localizedValues[_locale]!['version']!;
  static String get location => _localizedValues[_locale]!['location']!;
  static String get noDescription => _localizedValues[_locale]!['noDescription']!;
  static String get ok => _localizedValues[_locale]!['ok']!;
  static String get na => _localizedValues[_locale]!['na']!;
}
