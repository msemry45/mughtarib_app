import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantsScreen extends StatefulWidget {
  @override
  _RestaurantsScreenState createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  String _selectedCategory = 'جميع المطاعم';

  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'اختر مصدر الصورة',
          style: GoogleFonts.cairo(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('الكاميرا', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('معرض الصور', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المطاعم',
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
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن مطعم...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('جميع المطاعم', Icons.restaurant),
                _buildCategoryChip('بيتزا', Icons.local_pizza),
                _buildCategoryChip('وجبات سريعة', Icons.fastfood),
                _buildCategoryChip('كافيهات', Icons.coffee),
                _buildCategoryChip('حلويات', Icons.cake),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildRestaurantCard(
                  'مطعم الشرق',
                  'assets/images/restaurant1.jpg',
                  4.5,
                  '30-45',
                  '50 ريال',
                ),
                _buildRestaurantCard(
                  'بيتزا هت',
                  'assets/images/restaurant2.jpg',
                  4.2,
                  '20-35',
                  '40 ريال',
                ),
                _buildRestaurantCard(
                  'كافيه السعادة',
                  'assets/images/restaurant3.jpg',
                  4.8,
                  '15-30',
                  '30 ريال',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        child: Icon(Icons.add_a_photo),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
  }

  Widget _buildCategoryChip(String title, IconData icon) {
    final isSelected = _selectedCategory == title;
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Color(0xFF9C27B0),
            ),
            SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = title;
            });
          }
        },
        backgroundColor: Colors.white,
        selectedColor: Color(0xFF9C27B0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color(0xFF9C27B0),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    String name,
    String imagePath,
    double rating,
    String deliveryTime,
    String minOrder,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'وقت التوصيل: $deliveryTime دقيقة',
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.shopping_bag,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'الحد الأدنى للطلب: $minOrder',
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 