import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl, LaunchMode;
import '../models/host_family_model.dart';

class HostFamiliesChatScreen extends StatefulWidget {
  const HostFamiliesChatScreen({Key? key}) : super(key: key);

  @override
  State<HostFamiliesChatScreen> createState() => _HostFamiliesChatScreenState();
}

class _HostFamiliesChatScreenState extends State<HostFamiliesChatScreen> {
  late Future<List<HostFamily>> _familiesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _familiesFuture = _getHostFamilies();
  }

  Future<List<HostFamily>> _getHostFamilies() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('hostFamilies')
          .get();

      print('عدد الأسر المستلمة: ${querySnapshot.docs.length}');
      querySnapshot.docs.forEach((doc) {
        print('بيانات الأسرة: ${doc.data()}');
      });

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HostFamily.fromDocument(doc);
      }).toList();
    } catch (e) {
      print('خطأ في جلب الأسر المضيفة: $e');
      throw Exception('فشل في تحميل بيانات الأسر المضيفة');
    }
  }

  List<HostFamily> _filterFamilies(List<HostFamily> families, String query) {
    if (query.isEmpty) return families;
    return families.where((family) =>
        family.familyName.toLowerCase().contains(query.toLowerCase()) ||
        family.location.toLowerCase().contains(query.toLowerCase()) ||
        family.phoneNumber.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<void> _refreshFamilies() async {
    setState(() {
      _familiesFuture = _getHostFamilies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("محادثة مع الأسر المضيفة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFamilies,
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
                hintText: 'ابحث عن أسرة...',
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
              onRefresh: _refreshFamilies,
              child: FutureBuilder<List<HostFamily>>(
                future: _familiesFuture,
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
                            onPressed: _refreshFamilies,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد أسر مضيفة متاحة',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final filteredFamilies = _filterFamilies(snapshot.data!, _searchQuery);
                  
                  if (filteredFamilies.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد نتائج مطابقة للبحث',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredFamilies.length,
                    itemBuilder: (context, index) {
                      final family = filteredFamilies[index];
                      return _buildFamilyCard(context, family);
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

  Widget _buildFamilyCard(BuildContext context, HostFamily family) {
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
              // صورة الأسرة
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.family_restroom, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        family.familyName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // معلومات الأسرة
                    Text(
                      'الاسم: ${family.familyName}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'المدينة: ${family.location}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'الهاتف: ${family.phoneNumber}',
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
                    icon: const Icon(Icons.phone, color: Colors.blue, size: 28),
                    onPressed: () => _makePhoneCall(family.phoneNumber),
                    tooltip: 'اتصال هاتفي',
                  ),
                  // زر واتساب
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                    onPressed: () => _openWhatsApp(family.phoneNumber),
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