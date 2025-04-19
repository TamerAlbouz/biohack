import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({
    super.key,
    required this.initialLocation,
  });

  static Route<LatLng> route(LatLng initialLocation) {
    return MaterialPageRoute<LatLng>(
      builder: (_) => LocationPickerScreen(initialLocation: initialLocation),
    );
  }

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation;
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: MyColors.cardBackground,
        elevation: 0,
        title: const Text(
          'Select Clinic Location',
          style: TextStyle(
            color: MyColors.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Confirm'),
            style: TextButton.styleFrom(
              foregroundColor: MyColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(_selectedLocation);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for an address',
                  hintStyle: const TextStyle(
                      color: MyColors.textGrey, fontSize: Font.mediumSmall),
                  prefixIcon: const Icon(Icons.search, color: MyColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: MyColors.textGrey),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (value) {
                  // You would implement geocoding here to convert address to coordinates
                  // For demonstration purposes, we're just showing a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Geocoding service would be implemented here'),
                    ),
                  );
                },
              ),
            ),
          ),

          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColors.grey.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 14.0,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onTap: (position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('clinic'),
                          position: _selectedLocation,
                          draggable: true,
                          onDragEnd: (newPosition) {
                            setState(() {
                              _selectedLocation = newPosition;
                            });
                          },
                        ),
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                    ),

                    // Custom zoom controls
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: "zoomIn",
                            onPressed: () {
                              _mapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                            backgroundColor: Colors.white,
                            foregroundColor: MyColors.primary,
                            elevation: 4,
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: "zoomOut",
                            onPressed: () {
                              _mapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                            backgroundColor: Colors.white,
                            foregroundColor: MyColors.primary,
                            elevation: 4,
                            child: const Icon(Icons.remove),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instructions
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: MyColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: MyColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'How to set your clinic location:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Tap anywhere on the map to place a marker\n• Drag the marker to adjust the precise location\n• Use the search bar to find a specific address\n• Confirm when you\'re satisfied with the location',
                  style: TextStyle(
                    fontSize: 13,
                    color: MyColors.textBlack,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding
          kGap30,
        ],
      ),
    );
  }
}
