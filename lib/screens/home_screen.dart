import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Cache commonly used styles
  final _titleStyle = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  final _subtitleStyle = GoogleFonts.cairo(
    color: Colors.grey[600],
  );

  @override
  void initState() {
    super.initState();
    // Preload Google Fonts
    GoogleFonts.pendingFonts([
      GoogleFonts.cairo(),
    ]);
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Limit image size
        maxHeight: 1024,
        imageQuality: 85, // Compress image
      );
      if (image != null) {
        // TODO: Handle the picked image
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم اختيار الصورة بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    // TODO: Implement search functionality with debounce
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onBackground;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, colorScheme, textColor),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSearchBar(context, colorScheme, textColor),
                  _buildNearbySection(context, colorScheme, textColor),
                  _buildOrderSection(context, colorScheme, textColor),
                  _buildDailyOffersSection(context, colorScheme, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, colorScheme, textColor),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/messages'),
        child: const Icon(Icons.chat),
        elevation: 4,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.location_on, size: 16, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LocationMapScreen()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'المملكة العربية السعودية',
                style: GoogleFonts.cairo(fontSize: 16, color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _handleSearch,
        decoration: InputDecoration(
          hintText: 'ابحث عن سكن...',
          hintStyle: GoogleFonts.cairo(color: textColor),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قريب من موقعك',
                style: _titleStyle.copyWith(color: textColor),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/property'),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120, // Fixed height for better performance
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNearbyCard(
                'سكن طلابي',
                '2.5 كم',
                Icons.apartment,
                () => Navigator.pushNamed(context, '/property'),
                context,
                textColor,
              ),
              _buildNearbyCard(
                'عائلة مضيفة',
                '3.1 كم',
                Icons.home,
                () => Navigator.pushNamed(context, '/property'),
                context,
                textColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(String title, String distance, IconData icon, VoidCallback onTap, BuildContext context, Color textColor) {
    return SizedBox(
      width: 160,
      child: Card(
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: const Color(0xFF9C27B0)),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF9C27B0)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    distance,
                    style: GoogleFonts.cairo(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ماذا تريد أن تطلب؟',
            style: _titleStyle.copyWith(color: textColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderItem(context, 'سكن', Icons.home_work, '/property', textColor),
              _buildOrderItem(context, 'مطعم', Icons.restaurant, '/restaurants', textColor),
              _buildOrderItem(context, 'استكشاف', Icons.explore, '/explore', textColor),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String title, IconData icon, String route, Color textColor) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyOffersSection(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'عروض اليوم',
            style: _titleStyle.copyWith(color: textColor),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100, // Fixed height for better performance
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildOfferCard(
                'خصم 20%',
                'عرض خاص على السكن الطلابي',
                context,
                textColor,
              ),
              _buildOfferCard(
                'خصم 15%',
                'عرض خاص على المطاعم',
                context,
                textColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24), // Extra bottom padding
      ],
    );
  }

  Widget _buildOfferCard(String discount, String description, BuildContext context, Color textColor) {
    return SizedBox(
      width: 200,
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  discount,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  description,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9C27B0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildNavBarItem(Icons.home, 'الرئيسية', true, () {}, context, colorScheme, textColor),
                const SizedBox(width: 32),
                _buildNavBarItem(Icons.post_add, 'الإعلانات', false, () => Navigator.pushNamed(context, '/posts'), context, colorScheme, textColor),
              ],
            ),
            Row(
              children: [
                _buildNavBarItem(Icons.hotel, 'الإقامات', false, () => Navigator.pushNamed(context, '/stays'), context, colorScheme, textColor),
                const SizedBox(width: 32),
                _buildNavBarItem(Icons.person, 'الملف الشخصي', false, () => Navigator.pushNamed(context, '/profile'), context, colorScheme, textColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected, VoidCallback onTap, BuildContext context, ColorScheme colorScheme, Color textColor) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? colorScheme.primary : Colors.grey,
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected ? colorScheme.primary : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationMapScreen extends StatefulWidget {
  @override
  _LocationMapScreenState createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _location = Location();
  String? _error;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          setState(() => _error = 'خدمة الموقع غير مفعلة');
          return;
        }
      }

      PermissionStatus _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          setState(() => _error = 'تم رفض إذن الموقع');
          return;
        }
      }

      final locationData = await _location.getLocation();
      setState(() {
        _currentLocation = locationData;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'حدث خطأ أثناء جلب الموقع');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('موقعي الحالي', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: _error != null
          ? Center(child: Text(_error!, style: GoogleFonts.cairo(color: Colors.red)))
          : _currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: MarkerId('my_location'),
                      position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                      infoWindow: InfoWindow(title: 'موقعي الحالي'),
                    ),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                ),
    );
  }
}
