import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentsScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الطلاب')),
      body: FutureBuilder<List<Student>>(
        future: apiService.fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في جلب البيانات'));
          }
          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.email),
                leading: CircleAvatar(child: Text(student.name[0])),
              );
            },
          );
        },
      ),
    );
  }
} 