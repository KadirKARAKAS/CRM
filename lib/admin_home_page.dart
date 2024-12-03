import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getUsers() async {
    // 'users' koleksiyonundaki tüm kullanıcıları alıyoruz
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> _deleteUser(String userId) async {
    // Kullanıcıyı silme işlemi
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    // Kullanıcının rolünü güncelleme işlemi
    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Ana Sayfa')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Kullanıcı bulunamadı.'));
          }

          // Kullanıcı listesi
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var user = snapshot.data![index];
              String userId = user['uid'];
              String userName = user['name'] ?? 'Kullanıcı adı yok';
              String userEmail = user['email'] ?? 'Email yok';
              String userRole = user['role'] ?? 'unknown';

              return ListTile(
                title: Text(userName),
                subtitle: Text('$userEmail\nRol: $userRole'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        // Rol değiştirme işlemi
                        String? newRole = await showDialog<String>(
                          context: context,
                          builder: (context) => RoleDialog(userRole: userRole),
                        );
                        if (newRole != null && newRole != userRole) {
                          _updateUserRole(userId, newRole);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Kullanıcıyı silme işlemi
                        _deleteUser(userId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RoleDialog extends StatelessWidget {
  final String userRole;

  RoleDialog({required this.userRole});

  @override
  Widget build(BuildContext context) {
    String selectedRole = userRole;

    return AlertDialog(
      title: Text('Rol Seçin'),
      content: DropdownButton<String>(
        value: selectedRole,
        onChanged: (String? newValue) {
          if (newValue != null) {
            selectedRole = newValue;
          }
        },
        items: <String>['admin', 'personnel', 'user']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('İptal'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Kaydet'),
          onPressed: () {
            Navigator.of(context).pop(selectedRole);
          },
        ),
      ],
    );
  }
}
