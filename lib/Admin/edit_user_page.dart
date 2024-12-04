import 'package:crm/Admin/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final DocumentSnapshot userDoc;

  EditUserPage({required this.userDoc});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController ageController;
  late TextEditingController roleController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    ageController =
        TextEditingController(text: widget.userDoc['age']?.toString() ?? '');
    roleController = TextEditingController(text: widget.userDoc['role']);
    nameController = TextEditingController(text: widget.userDoc['name']);
  }

  Future<void> updateUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDoc.id)
          .update({
        'age': int.tryParse(ageController.text) ?? 0,
        'role': roleController.text,
        'name': nameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı başarıyla güncellendi')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kullanıcı Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Ad'),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Yaş'),
            ),
            TextField(
              controller: roleController,
              decoration: InputDecoration(labelText: 'Rol'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUser,
              child: Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
