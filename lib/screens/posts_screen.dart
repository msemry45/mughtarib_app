import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  final _postController = TextEditingController();
  // لون أساسي (مثال)
  final Color primaryColor = Color(0xFF9C27B0);

  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _images.add(image);
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
              leading: Icon(Icons.camera_alt, color: Color(0xFF9C27B0)),
              title: Text(
                'الكاميرا',
                style: GoogleFonts.cairo(),
              ),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF9C27B0)),
              title: Text(
                'معرض الصور',
                style: GoogleFonts.cairo(),
              ),
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
      // AppBar بأزرار Drafts و Post
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "New Post",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // منطق حفظ في Drafts
              print("Draft saved");
            },
            child: Text("Drafts", style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              // منطق النشر (Post)
              print("Post clicked: ${_postController.text}");
            },
            child: Text("Post", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _postController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'اكتب إعلانك هنا...',
                  hintStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9C27B0)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Color(0xFF9C27B0)),
                    onPressed: _showImageSourceDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_library, color: Color(0xFF9C27B0)),
                    onPressed: () => _getImage(ImageSource.gallery),
                  ),
                ],
              ),
              if (_images.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_images[index].path as dynamic),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // زر عائم يؤدي إلى صفحة الرسائل
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/messages');
        },
        child: Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // شريط تنقل سفلي مشابه للشاشات الأخرى
      bottomNavigationBar: _buildBottomNavigationBar(context, primaryColor),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, Color primaryColor) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: primaryColor,
      notchMargin: 6.0,
      child: Container(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // أيقونة الصفحة الرئيسية
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            // أيقونة Post (الشاشة الحالية)
            IconButton(
              icon: Icon(Icons.post_add, color: Colors.white),
              onPressed: () {
                // نحن بالفعل في صفحة البوست
              },
            ),
            SizedBox(width: 40), // مساحة للـ FAB في المنتصف
            // أيقونة Category
            IconButton(
              icon: Icon(Icons.category, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/category');
              },
            ),
            // أيقونة Profile
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
