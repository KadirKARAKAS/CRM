import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcıları Firestore'dan çekmek için metod
  Future<List<Map<String, dynamic>>> _getUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  // Kullanıcıyı silme işlemi
  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kullanıcı başarıyla silindi.')));
    } catch (e) {
      print("Kullanıcı silinirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kullanıcı silinirken hata oluştu: $e')));
    }
  }

  // Kullanıcının rolünü güncelleme işlemi
  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rol başarıyla güncellendi')));
    } catch (e) {
      print('Rol güncellenirken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rol güncellenirken hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Ana Sayfa')),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _getUsers(), // Kullanıcıları çekiyoruz
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

              // null kontrolü ekleniyor
              String userId = user['uid'] ?? 'Unknown UID';
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
                          await _updateUserRole(userId, newRole);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Kullanıcıyı silme işlemi
                        await _deleteUser(userId);
                        setState(() {
                          // Kullanıcıyı silip listeyi güncelliyoruz
                        });
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

// Kullanıcı rolünü değiştirmek için kullanılan dialog
class RoleDialog extends StatefulWidget {
  final String userRole;

  RoleDialog({required this.userRole});

  @override
  _RoleDialogState createState() => _RoleDialogState();
}

class _RoleDialogState extends State<RoleDialog> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.userRole; // Başlangıçta mevcut rol seçili olsun
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rol Seçin'),
      content: DropdownButton<String>(
        value: selectedRole,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedRole = newValue;
            });
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
