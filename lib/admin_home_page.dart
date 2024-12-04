import 'package:crm/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crm/sign_in_page.dart';
import 'package:crm/model/user_model.dart';
import 'package:crm/model/user_provider.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    // Kullanıcıları başlatmak için
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Paneli'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();  // Firebase çıkış işlemi
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => SignUpPage())  // Login sayfasına yönlendir
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Çıkış yapılırken bir hata oluştu: $e'))
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.users.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(  // Kaydırılabilir yapı
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              shrinkWrap: true,  // Yükseklik konusunda sınırlama
              physics: NeverScrollableScrollPhysics(), // Scroll'u devre dışı bırak
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                UserModel user = userProvider.users[index];
            
                return Card(
                  color: Colors.blue[50],
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email ve Role bilgilerini tam sol tarafa hizaladık
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text('Email: ${user.email}', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Rol: ${user.role}', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            String? newRole = await showDialog<String>(
                              context: context,
                              builder: (context) => RoleDialog(userRole: user.role ?? 'user'),
                            );
                            if (newRole != null && newRole != user.role) {
                              userProvider.updateUserRole(user.uid, newRole);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            userProvider.deleteUser(user.uid);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

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
    selectedRole = widget.userRole;
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
            .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
            .toList(),
      ),
      actions: [
        TextButton(
          child: Text('İptal'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Kaydet'),
          onPressed: () => Navigator.of(context).pop(selectedRole),
        ),
      ],
    );
  }
}
