import 'package:flutter/material.dart';

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _postController = TextEditingController();
  // لون أساسي (مثال)
  final Color primaryColor = Color(0xFF9C27B0);

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
        child: Column(
          children: [
            // مربع الكتابة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: _postController,
                    maxLines: null, // يسمح بتمدد الكتابة
                    decoration: InputDecoration(
                      hintText: "What's happening?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // شريط الأدوات السفلي (أيقونات لإضافة صورة، موقع، إلخ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: primaryColor),
                    onPressed: () {
                      // منطق إضافة صورة
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: primaryColor),
                    onPressed: () {
                      // منطق فتح الكاميرا
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on_outlined, color: primaryColor),
                    onPressed: () {
                      // منطق إضافة موقع
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add_box_outlined, color: primaryColor),
                    onPressed: () {
                      // منطق إضافة مرفقات إضافية
                    },
                  ),
                ],
              ),
            ),
          ],
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
}
