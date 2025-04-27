import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF9C27B0); // مثال على اللون البنفسجي

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: _buildLocationRow(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // زر الإشعارات (اختياري)
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // قسم البحث
              _buildSearchBar(primaryColor),
              // قسم Nearby
              _buildNearbySection(context),
              // قسم "What would you like to order?"
              _buildOrderSection(context),
              // قسم العروض اليومية
              _buildDailyOffersSection(context),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // شريط تنقل سفلي مع أيقونات
      bottomNavigationBar: _buildBottomNavigationBar(context, primaryColor),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
           Navigator.pushNamed(context, '/messages');
        },
        child: Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Icon(Icons.location_on),
        SizedBox(width: 8),
        Text(
          "Saudi Arabia",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Container(
      color: primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search ...",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Nearby your location",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              // مثال: الانتقال لشاشة العقارات
              Navigator.pushNamed(context, '/property');
            },
            child: Text(
              "See all",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What would you like to order?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderItem(context, "Housing", Icons.home_work, '/property'),
              _buildOrderItem(context, "Restaurant", Icons.restaurant, '/'),
              _buildOrderItem(context, "Explore", Icons.explore, '/student'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String title, IconData icon, String routeName) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(icon, size: 24),
          ),
          SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildDailyOffersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily offers",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOfferCard("50% OFF"),
                SizedBox(width: 10),
                _buildOfferCard("10% OFF"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String offerText) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        offerText,
        style: TextStyle(
          fontSize: 20,
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                // بالفعل على الصفحة الرئيسية
                Navigator.pushNamed(context, '/home');
              },
            ),
            // أيقونة Posts
            IconButton(
              icon: Icon(Icons.post_add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/posts');
              },
            ),
            SizedBox(width: 40), // مسافة لمكان الـ FAB
            // أيقونة Stays
            IconButton(
              icon: Icon(Icons.hotel, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/stays');
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
