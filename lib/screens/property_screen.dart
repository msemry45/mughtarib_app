import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PropertyScreen extends StatefulWidget {
  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'الكل';
  String _selectedType = 'الكل';
  String _selectedPriceRange = 'الكل';
  bool _showMap = false;
  Set<Marker> _markers = {};
  late TabController _tabController;
  String _selectedProvider = 'all'; // 'all', 'office', 'family'

  // قائمة المدن السعودية
  final List<String> saudiCities = [
    'الكل',
    // منطقة الجوف
    'سكاكا',
    'دومة الجندل',
    'القريات',
    'طبرجل',
    'المرير',
    'صوير',
    'الحديثة',
    'اللقايط',
    'النبك أبو قصر',
    'النبك العام',
    'النبك الخاص',
    'النبك الصناعية',
    'النبك الشمالية',
    'النبك الجنوبية',
    'النبك الشرقية',
    'النبك الغربية',
    // المدن الكبرى
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الطائف',
    'تبوك',
    'الأحساء',
    'حائل',
    'جازان',
    'أبها',
    'القطيف',
    'خميس مشيط',
    'الجبيل',
    'ينبع',
    'بريدة',
    'عنيزة',
    'الخرج',
    'الدرعية',
    'رنية',
    'رابغ',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedProvider = 'all';
            break;
          case 1:
            _selectedProvider = 'office';
            break;
          case 2:
            _selectedProvider = 'family';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Property>> fetchProperties() async {
    Query query = FirebaseFirestore.instance.collection('properties');
    
    // تصفية حسب نوع المزود
    if (_selectedProvider != 'all') {
      query = query.where('providerType', isEqualTo: _selectedProvider);
    }
    
    // تطبيق الفلاتر الأخرى
    if (_selectedCity != 'الكل') {
      query = query.where('city', isEqualTo: _selectedCity);
    }
    if (_selectedType != 'الكل') {
      query = query.where('type', isEqualTo: _selectedType);
    }
    if (_selectedPriceRange != 'الكل') {
      final ranges = {
        'اقتصادي': [0, 1000],
        'متوسط': [1000, 2000],
        'فاخر': [2000, double.infinity],
      };
      final range = ranges[_selectedPriceRange]!;
      query = query.where('price', isGreaterThanOrEqualTo: range[0])
                  .where('price', isLessThanOrEqualTo: range[1]);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Property.fromDocument(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Widget _buildPropertyCard(Property property, int index) {
    final List<String> houseImages = [
      'assets/images/house1.png',
      'assets/images/house2.png',
      'assets/images/house3.png',
      'assets/images/house4.png',
      'assets/images/house5.png',
      'assets/images/house6.png',
      'assets/images/house7.png',
      'assets/images/house8.png',
    ];
    final String imagePath = houseImages[index % houseImages.length];
    // إضافة الأنيميشن
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان والتقييم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            '${property.rating}',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          Text(' (${property.reviewCount})'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // الموقع
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${property.city}, ${property.address}',
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // المواصفات
                  Row(
                    children: [
                      _buildFeature(Icons.bed, '${property.bedrooms} غرف'),
                      SizedBox(width: 16),
                      _buildFeature(Icons.bathtub_outlined, '${property.bathrooms} حمامات'),
                      SizedBox(width: 16),
                      _buildFeature(Icons.square_foot, '${property.area} ${property.areaUnit}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // السعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${property.price} ${property.currency}',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailsScreen(property: property),
                            ),
                          );
                        },
                        child: Text('عرض التفاصيل'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text(text, style: GoogleFonts.cairo(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('المدن', _selectedCity, saudiCities),
          SizedBox(width: 8),
          _buildFilterChip('النوع', _selectedType, ['الكل', 'شقة', 'فيلا', 'منزل']),
          SizedBox(width: 8),
          _buildFilterChip('السعر', _selectedPriceRange, ['الكل', 'اقتصادي', 'متوسط', 'فاخر']),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, List<String> options) {
    return PopupMenuButton<String>(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(label),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onSelected: (value) {
        setState(() {
          if (label == 'المدن') _selectedCity = value;
          else if (label == 'النوع') _selectedType = value;
          else if (label == 'السعر') _selectedPriceRange = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "العقارات المتاحة",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'الكل'),
            Tab(text: 'سكن طلابي'),
            Tab(text: 'عائلة مضيفة'),
          ],
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن عقار...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // الفلاتر
          _buildFilterChips(),
          
          // عرض الخريطة أو القائمة
          Expanded(
            child: _showMap
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(24.7136, 46.6753), // الرياض
                      zoom: 11,
                    ),
                    markers: _markers,
                  )
                : FutureBuilder<List<Property>>(
                    future: fetchProperties(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('حدث خطأ أثناء جلب البيانات'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('لا توجد عقارات متاحة'));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return _buildPropertyCard(snapshot.data![index], index);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;
  const PropertyDetailsScreen({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل السكن'),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.apartment, color: colorScheme.primary),
                      SizedBox(width: 8),
                      Text(property.type, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(property.description, style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                  Divider(height: 32, thickness: 1),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colorScheme.secondary),
                      SizedBox(width: 8),
                      Text('${property.city}, ${property.address}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.bed, color: colorScheme.primary),
                      SizedBox(width: 8),
                      Text('عدد الغرف: ${property.bedrooms}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: colorScheme.primary),
                      SizedBox(width: 8),
                      Text('السعر: ${property.price} ${property.currency}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      SizedBox(width: 8),
                      Text('الحالة: ${property.status}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.date_range, color: colorScheme.primary),
                      SizedBox(width: 8),
                      Text('تاريخ الإدراج: ${property.createdAt.toString().split(' ').first}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  // Add more fields as needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
