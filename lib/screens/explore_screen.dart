import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final LatLng _center = LatLng(24.7136, 46.6753); // Riyadh coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'استكشاف',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF9C27B0),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildFeatureCard(
                  'السكن الطلابي',
                  'ابحث عن سكن طلابي قريب من جامعتك',
                  Icons.apartment,
                  () => Navigator.pushNamed(context, '/property'),
                ),
                _buildFeatureCard(
                  'الأسر المضيفة',
                  'ابحث عن أسرة مضيفة للعيش معها',
                  Icons.family_restroom,
                  () => Navigator.pushNamed(context, '/host-families'),
                ),
                _buildFeatureCard(
                  'المطاعم',
                  'استكشف المطاعم القريبة منك',
                  Icons.restaurant,
                  () => Navigator.pushNamed(context, '/restaurants'),
                ),
                _buildFeatureCard(
                  'العيادات',
                  'ابحث عن العيادات القريبة',
                  Icons.medical_services,
                  () => Navigator.pushNamed(context, '/clinics'),
                ),
                _buildFeatureCard(
                  'الإعلانات',
                  'تصفح الإعلانات المضافة حديثاً',
                  Icons.post_add,
                  () => Navigator.pushNamed(context, '/posts'),
                ),
                _buildFeatureCard(
                  'الرسائل',
                  'تواصل مع الآخرين',
                  Icons.chat,
                  () => Navigator.pushNamed(context, '/messages'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF9C27B0),
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.cairo(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 