import 'package:crm/add_user_page.dart';
import 'package:crm/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          IconButton(onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddUserPage(),));

          }, icon: Icon(Icons.add,size: 26,)),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();  
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => SignUpPage())  
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
}class RoleDialog extends StatefulWidget {
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
      title: Text(
        'Rol Seçin',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Material(
          color: Colors.white, // Saydam bir arka plan kullan
          child: InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedRole = newValue;
                      });
                    }
                  },
                  isExpanded: true,
                  underline: SizedBox(), // Alt çizgiyi kaldırdık
                  iconSize: 30, // Ok simgesinin boyutunu artırdık
                  iconEnabledColor: Colors.white, // Ok simgesinin rengi
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  items: <String>['admin', 'personel', 'user']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                role,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'İptal',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(selectedRole);
          },
          child: Text('Kaydet',style: TextStyle(color: Colors.black),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
