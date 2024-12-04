import 'package:crm/Register/Login/PassReset/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personel Sayfası'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Çıkış yapılırken bir hata oluştu: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16.0),
            child: DataTable(
              columnSpacing: 16.0,
              headingRowHeight: 56.0,
              dataRowHeight: 56.0,
              columns: const [
                DataColumn(
                    label: Text('Ad',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Email',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Rol',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Yaş',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: users.map((userDoc) {
                var user = userDoc.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Text(user['name'] ?? '')),
                    DataCell(Text(user['email'] ?? '')),
                    DataCell(Text(user['role'] ?? '')),
                    DataCell(Text(user['age']?.toString() ?? '0')),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
