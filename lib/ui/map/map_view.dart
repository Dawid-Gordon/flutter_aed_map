import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'map_view_model.dart';
import '../../core/constants/app_strings.dart';
import '../../core/base/locale_base.dart';

class MapView extends LocaleBase {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends LocaleBaseState<MapView> {
  MapboxMap? _mapboxMap;
  final MapViewModel _viewModel = MapViewModel();

  static const String sourceId = "features-source";
  static const String clusterLayerId = "clusters";
  static const String clusterCountLayerId = "cluster-count";
  static const String unclusteredLayerId = "unclustered-points";

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.geoJsonData != null && _mapboxMap != null) {
      _updateMapLayers();
    }
  }

  Future<void> _updateMapLayers() async {
    final style = _mapboxMap!.style;
    final geojson = _viewModel.geoJsonData!;

    // Remove existing layers and source if they exist
    if (await style.styleLayerExists(unclusteredLayerId)) await style.removeStyleLayer(unclusteredLayerId);
    if (await style.styleLayerExists(clusterCountLayerId)) await style.removeStyleLayer(clusterCountLayerId);
    if (await style.styleLayerExists(clusterLayerId)) await style.removeStyleLayer(clusterLayerId);
    if (await style.styleSourceExists(sourceId)) await style.removeStyleSource(sourceId);

    await style.addSource(GeoJsonSource(
      id: sourceId,
      data: geojson,
      cluster: true,
      clusterRadius: 100,
    ));

    // Layer for clustered points
    await style.addLayer(CircleLayer(
      id: clusterLayerId,
      sourceId: sourceId,
      filter: ["has", "point_count"],
      circleColor: Colors.blue.toARGB32(),
      circleRadius: 20.0,
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));

    // Layer for cluster counts
    await style.addLayer(SymbolLayer(
      id: clusterCountLayerId,
      sourceId: sourceId,
      filter: ["has", "point_count"],
      textFieldExpression: [
        "case",
        [">=", ["get", "point_count"], 1000],
        [
          "concat",
          [
            "to-string",
            ["/", ["round", ["/", ["get", "point_count"], 100]], 10.0]
          ],
          "k"
        ],
        ["to-string", ["get", "point_count"]]
      ],
      textSize: 12.0,
      textColor: Colors.white.toARGB32(),
    ));

    // Layer for unclustered points
    await style.addLayer(CircleLayer(
      id: unclusteredLayerId,
      sourceId: sourceId,
      filter: ["!", ["has", "point_count"]],
      circleColor: Colors.blue.toARGB32(),
      circleRadius: 8.0,
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));
  }

  void _onMapTap(MapContentGestureContext context) async {
    if (_mapboxMap == null) return;

    final screenCoordinate = await _mapboxMap!.pixelForCoordinate(context.point);

    // Query for unclustered points
    final unclusteredFeatures = await _mapboxMap!.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate),
      RenderedQueryOptions(layerIds: [unclusteredLayerId]),
    );

    if (unclusteredFeatures.isNotEmpty) {
      final feature = unclusteredFeatures.first?.queriedFeature.feature;
      if (feature != null) {
        final geometry = feature["geometry"] as Map<dynamic, dynamic>;
        final coordinates = geometry["coordinates"] as List<dynamic>;
        final properties = feature["properties"] as Map<dynamic, dynamic>?;

        if (properties != null) {
          if (!mounted) return;
          final screenHeight = MediaQuery.of(this.context).size.height;
          final bottomPadding = screenHeight * 0.45;

          _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(
                  coordinates: Position((coordinates[0] as num).toDouble(),
                      (coordinates[1] as num).toDouble())),
              zoom: 16.0,
              padding: MbxEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0),
            ),
            MapAnimationOptions(duration: 1000),
          );
          _showPinDetails(Map<String, dynamic>.from(properties)).then((_) {
            if (_mapboxMap != null) {
              _mapboxMap!.flyTo(
                CameraOptions(
                  padding: MbxEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                ),
                MapAnimationOptions(duration: 1000),
              );
            }
          });
        }
      }
      return;
    }

    // Query for clusters to zoom in
    final clusterFeatures = await _mapboxMap!.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate),
      RenderedQueryOptions(layerIds: [clusterLayerId]),
    );

    if (clusterFeatures.isNotEmpty) {
      final feature = clusterFeatures.first!.queriedFeature.feature;
      final geometry = feature["geometry"] as Map<dynamic, dynamic>;
      final coordinates = geometry["coordinates"] as List<dynamic>;

      final cameraState = await _mapboxMap!.getCameraState();
      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
              coordinates: Position((coordinates[0] as num).toDouble(),
                  (coordinates[1] as num).toDouble())),
          zoom: cameraState.zoom + 2,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  Future<void> _showPinDetails(Map<String, dynamic> data) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.pinDetails,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                _detailRow(AppStrings.longitude, (data['longitude'] as num).toStringAsFixed(6)),
                _detailRow(AppStrings.latitude, (data['latitude'] as num).toStringAsFixed(6)),
                const SizedBox(height: 8),
                _detailRow(AppStrings.type, data['type']?.toString() ?? AppStrings.na),
                _detailRow(AppStrings.checkDate, data['check_date']?.toString() ?? AppStrings.na),
                _detailRow(AppStrings.version, data['version']?.toString() ?? AppStrings.na),
                const Divider(),
                Text(
                  AppStrings.location,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data['location_desc']?.toString() ?? AppStrings.noDescription,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Future<void> _centerOnLocation() async {
    final point = await _viewModel.getCurrentLocation();
    if (_mapboxMap != null && point != null) {
      _mapboxMap!.flyTo(
        CameraOptions(
          center: point,
          zoom: 16.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  void _onStyleSelected(String styleUri) {
    _mapboxMap?.loadStyleURI(styleUri);
    Navigator.pop(context);
  }

  void _showStyleSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: Text(AppStrings.styleDefault),
                onTap: () => _onStyleSelected(MapboxStyles.MAPBOX_STREETS),
              ),
              ListTile(
                leading: const Icon(Icons.satellite),
                title: Text(AppStrings.styleSatellite),
                onTap: () => _onStyleSelected(MapboxStyles.SATELLITE_STREETS),
              ),
              ListTile(
                leading: const Icon(Icons.terrain),
                title: Text(AppStrings.styleOutdoors),
                onTap: () => _onStyleSelected(MapboxStyles.OUTDOORS),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppStrings.appTitle),
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        viewport: CameraViewportState(
          center: Point(coordinates: Position(19.1451, 51.9194)),
          zoom: 4,
        ),
        onMapCreated: (MapboxMap mapboxMap) {
          _mapboxMap = mapboxMap;
          _mapboxMap!.addInteraction(TapInteraction.onMap(_onMapTap));
          _centerOnLocation();

          // Move compass below the AppBar
          final statusBarHeight = MediaQuery.of(context).padding.top;
          const appBarHeight = kToolbarHeight;
          _mapboxMap!.compass.updateSettings(CompassSettings(
            marginTop: statusBarHeight + appBarHeight + 10.0,
          ));

          // Move scale bar to bottom left, above the Mapbox logo
          _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(
            position: OrnamentPosition.BOTTOM_LEFT,
            marginBottom: 50.0,
            marginLeft: 8.0,
          ));
        },
        onStyleLoadedListener: (styleLoadedEvent) {
          _viewModel.loadFeatures();
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _centerOnLocation,
            heroTag: "locationBtn",
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _showStyleSelector,
            heroTag: "layersBtn",
            child: const Icon(Icons.layers),
          ),
        ],
      ),
    );
  }
}
