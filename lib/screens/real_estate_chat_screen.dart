import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, canLaunchUrl, launchUrl;
import '../models/real_estate_office_model.dart';

class RealEstateChatScreen extends StatefulWidget {
  const RealEstateChatScreen({Key? key}) : super(key: key);

  @override
  State<RealEstateChatScreen> createState() => _RealEstateChatScreenState();
}

class _RealEstateChatScreenState extends State<RealEstateChatScreen> {
  late Future<List<RealEstateOffice>> _officesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _officesFuture = _getRealEstateOffices();
  }

  Future<List<RealEstateOffice>> _getRealEstateOffices() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('realEstateOffices')
          .get();

      print('عدد المكاتب المستلمة: ${querySnapshot.docs.length}');
      querySnapshot.docs.forEach((doc) {
        print('بيانات المكتب: ${doc.data()}');
      });

      return querySnapshot.docs.map((doc) => RealEstateOffice.fromDocument(doc)).toList();
    } catch (e) {
      print('خطأ في جلب المكاتب: $e');
      throw Exception('فشل في تحميل بيانات المكاتب');
    }
  }

  List<RealEstateOffice> _filterOffices(List<RealEstateOffice> offices, String query) {
    if (query.isEmpty) return offices;
    return offices.where((office) =>
        office.name.toLowerCase().contains(query.toLowerCase()) ||
        office.location.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<void> _refreshOffices() async {
    setState(() {
      _officesFuture = _getRealEstateOffices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("محادثة مع المكاتب العقارية"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOffices,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن مكتب...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshOffices,
              child: FutureBuilder<List<RealEstateOffice>>(
                future: _officesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'حدث خطأ: ${snapshot.error}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshOffices,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا يوجد مكاتب عقارية متاحة',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final filteredOffices = _filterOffices(snapshot.data!, _searchQuery);
                  
                  if (filteredOffices.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد نتائج مطابقة للبحث',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredOffices.length,
                    itemBuilder: (context, index) {
                      final office = filteredOffices[index];
                      return _buildOfficeCard(context, office);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, RealEstateOffice office) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // التنقل لصفحة التفاصيل
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // صورة المكتب
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.business, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المكتب مع تصميم مميز
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        office.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // معلومات المكتب
                    Text(
                      'الموقع: ${office.location}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'الهاتف: ${office.phone}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // أزرار التواصل
              Column(
                children: [
                  // زر الاتصال
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green, size: 28),
                    onPressed: () => _makePhoneCall(office.phone),
                    tooltip: 'اتصال هاتفي',
                  ),
                  // زر واتساب (باستخدام أيقونة بديلة)
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                    onPressed: () => _openWhatsApp(office.phone),
                    tooltip: 'فتح واتساب',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'تعذر فتح تطبيق الهاتف';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanedPhone');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'تعذر فتح تطبيق واتساب';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}