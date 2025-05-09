import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl, LaunchMode;

class HostFamily {
  final String id;
  final String familyName;
  final String email;
  final String phoneNumber;
  final String location;
  final int hostFamilyID;

  HostFamily({
    required this.id,
    required this.familyName,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.hostFamilyID,
  });

  factory HostFamily.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HostFamily(
      id: doc.id,
      familyName: data['familyName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      location: data['location'] as String? ?? '',
      hostFamilyID: (data['hostFamilyID'] as int?) ?? 0,
    );
  }
}

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

      return querySnapshot.docs.map((doc) => HostFamily.fromDocument(doc)).toList();
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
        title: const Text("الأسر المضيفة"),
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
                        'لا توجد أسر مضيفة مسجلة',
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
                      return _buildFamilyCard(family);
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

  Widget _buildFamilyCard(HostFamily family) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.family_restroom, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    family.familyName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '#${family.hostFamilyID}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, family.location),
            _buildInfoRow(Icons.phone, family.phoneNumber),
            _buildInfoRow(Icons.email, family.email),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _makePhoneCall(family.phoneNumber),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  onPressed: () => _openWhatsApp(family.phoneNumber),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
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