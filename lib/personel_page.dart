import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PersonelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personel Sayfası'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, index) {
              return ListTile(
                title: Text(users[index]['email']),
                subtitle: Text('Rol: ${users[index]['role']}'),
              );
            },
          );
        },
      ),
    );
  }
}
