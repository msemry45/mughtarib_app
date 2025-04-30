import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchBar(context),
                _buildNearbySection(context),
                _buildOrderSection(context),
                _buildDailyOffersSection(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/messages'),
        child: Icon(Icons.chat, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Saudi Arabia',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        centerTitle: false,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby your location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/property'),
                child: Text('See all'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildNearbyCard(
                'Student Housing',
                '2.5 km away',
                Icons.apartment,
                () => Navigator.pushNamed(context, '/property'),
                context,
              ),
              _buildNearbyCard(
                'Host Family',
                '3.1 km away',
                Icons.home,
                () => Navigator.pushNamed(context, '/property'),
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(String title, String distance, IconData icon, VoidCallback onTap, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 16, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                distance,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to order?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderItem(context, 'Housing', Icons.home_work, '/property'),
              _buildOrderItem(context, 'Restaurant', Icons.restaurant, '/'),
              _buildOrderItem(context, 'Explore', Icons.explore, '/student'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String discount, String description, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 16),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                discount,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Daily Offers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildOfferCard('50% OFF', 'Student Housing', context),
              _buildOfferCard('10% OFF', 'Host Family Stay', context),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected, VoidCallback onTap, BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildNavBarItem(Icons.home, 'Home', true, () {}, context),
                SizedBox(width: 32),
                _buildNavBarItem(Icons.post_add, 'Posts', false, () => Navigator.pushNamed(context, '/posts'), context),
              ],
            ),
            Row(
              children: [
                _buildNavBarItem(Icons.hotel, 'Stays', false, () => Navigator.pushNamed(context, '/stays'), context),
                SizedBox(width: 32),
                _buildNavBarItem(Icons.person, 'Profile', false, () => Navigator.pushNamed(context, '/profile'), context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
