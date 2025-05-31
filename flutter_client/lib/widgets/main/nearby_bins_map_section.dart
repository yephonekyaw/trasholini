// widgets/nearby_bins_map_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Uncomment when you add Google Maps
// import 'package:geolocator/geolocator.dart'; // Uncomment when you add location services

class NearbyBinsMapSection extends ConsumerStatefulWidget {
  const NearbyBinsMapSection({super.key});

  @override
  ConsumerState<NearbyBinsMapSection> createState() => _NearbyBinsMapSectionState();
}

class _NearbyBinsMapSectionState extends ConsumerState<NearbyBinsMapSection> {
  // Mock trash bin locations - replace with real data from your API/database
  final List<Map<String, dynamic>> _mockTrashBins = [
    {
      'id': '1',
      'name': 'Central Park Bins',
      'latitude': 37.7749,
      'longitude': -122.4194,
      'distance': '0.2 km',
      'type': 'Mixed Recycling',
      'icon': Icons.recycling,
      'color': Colors.green,
    },
    {
      'id': '2', 
      'name': 'Shopping Mall Station',
      'latitude': 37.7849,
      'longitude': -122.4094,
      'distance': '0.5 km',
      'type': 'General Waste',
      'icon': Icons.delete,
      'color': Colors.grey,
    },
    {
      'id': '3',
      'name': 'University Campus',
      'latitude': 37.7649,
      'longitude': -122.4294,
      'distance': '0.8 km', 
      'type': 'Paper & Cardboard',
      'icon': Icons.description,
      'color': Colors.orange,
    },
    {
      'id': '4',
      'name': 'Metro Station',
      'latitude': 37.7549,
      'longitude': -122.4394,
      'distance': '1.2 km',
      'type': 'Plastic Only',
      'icon': Icons.local_drink,
      'color': Colors.blue,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Recycling', 'General', 'Paper', 'Plastic'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Nearby Bin Stations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  underline: Container(),
                  icon: Icon(Icons.filter_list, color: Colors.green[600], size: 16),
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  items: _filterOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Map Container (Placeholder for actual map)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                // Map placeholder (replace with actual Google Map)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/map_placeholder.png'), // Add your map image
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, color: Colors.green[600], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Interactive Map',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'Tap to view full map',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Map pins overlay (mock positions)
                ..._mockTrashBins.take(3).map((bin) => Positioned(
                  left: 50 + (_mockTrashBins.indexOf(bin) * 40.0),
                  top: 30 + (_mockTrashBins.indexOf(bin) * 20.0),
                  child: GestureDetector(
                    onTap: () => _showBinDetails(context, bin),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: bin['color'],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        bin['icon'],
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                )).toList(),
                
                // Full map button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _openFullMap(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.green[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Nearby bins list
          Text(
            'Nearest Locations',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Bins list
          ...(_getFilteredBins().take(3).map((bin) => _buildBinListItem(bin)).toList()),
          
          if (_getFilteredBins().length > 3)
            GestureDetector(
              onTap: () => _showAllBins(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View ${_getFilteredBins().length - 3} more locations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green[600],
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBins() {
    if (_selectedFilter == 'All') return _mockTrashBins;
    
    return _mockTrashBins.where((bin) {
      switch (_selectedFilter) {
        case 'Recycling':
          return bin['type'].contains('Recycling');
        case 'General':
          return bin['type'].contains('General');
        case 'Paper':
          return bin['type'].contains('Paper');
        case 'Plastic':
          return bin['type'].contains('Plastic');
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildBinListItem(Map<String, dynamic> bin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bin['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              bin['icon'],
              color: bin['color'],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bin['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  bin['type'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            bin['distance'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showBinDetails(BuildContext context, Map<String, dynamic> bin) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bin['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    bin['icon'],
                    color: bin['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bin['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bin['type'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.location_on, color: Colors.green[600]),
                    const SizedBox(height: 4),
                    Text(
                      bin['distance'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Distance', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue[600]),
                    const SizedBox(height: 4),
                    const Text(
                      '3 min',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Walk time', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.recycling, color: bin['color']),
                    const SizedBox(height: 4),
                    Text(
                      bin['type'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Type', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open navigation app
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openFullMap(BuildContext context) {
    // TODO: Navigate to full screen map page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening full map - Coming Soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAllBins(BuildContext context) {
    // TODO: Navigate to full bins list page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Showing all locations - Coming Soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}