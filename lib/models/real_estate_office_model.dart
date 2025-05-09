import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RealEstateOffice {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;

  RealEstateOffice({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
  });

  /// نبني الموديل من مستند Firestore مباشرة
  factory RealEstateOffice.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RealEstateOffice(
      id: doc.id,
      name: data['officeName']   as String? ?? '',
      email: data['email']       as String? ?? '',
      phone: data['phoneNumber'] as String? ?? '',
      location: data['location'] as String? ?? '',
    );
  }
}

class RealEstateChatScreen extends StatefulWidget {
  const RealEstateChatScreen({Key? key}) : super(key: key);

  @override
  _RealEstateChatScreenState createState() => _RealEstateChatScreenState();
}

class _RealEstateChatScreenState extends State<RealEstateChatScreen> {
  late Future<List<RealEstateOffice>> _officesFuture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _officesFuture = _loadOffices();
  }

  Future<List<RealEstateOffice>> _loadOffices() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('realEstateOffices')
          .get();

      if (query.docs.isEmpty) {
        setState(() => _errorMessage = 'لا توجد مكاتب مسجلة بعد');
        return [];
      }

      final list = query.docs
          .map((doc) => RealEstateOffice.fromDocument(doc))
          .toList();

      return list;
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ في تحميل بيانات المكاتب');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكاتب العقارية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _officesFuture = _loadOffices();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<RealEstateOffice>>(
        future: _officesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || _errorMessage != null) {
            return _errorWidget(_errorMessage ?? 'حدث خطأ غير متوقع');
          }
          final offices = snapshot.data ?? [];
          if (offices.isEmpty) {
            return const Center(child: Text('لا توجد مكاتب متاحة'));
          }
          return ListView.builder(
            itemCount: offices.length,
            itemBuilder: (ctx, i) {
              final o = offices[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(o.name),
                  subtitle: Text(o.location),
                  onTap: () {
                    // تفاصيل المكتب
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _errorWidget(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _officesFuture = _loadOffices();
              });
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
