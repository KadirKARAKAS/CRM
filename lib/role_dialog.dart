import 'package:flutter/material.dart';

class RoleDialog extends StatelessWidget {
  final String currentRole;

  RoleDialog({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    String selectedRole = currentRole;

    return AlertDialog(
      title: Text('Rolü Değiştir'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mevcut Rol: $currentRole'),
          SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedRole,
            onChanged: (String? newRole) {
              if (newRole != null) {
                selectedRole = newRole;
              }
            },
            items: ['admin', 'personel', 'uye']
                .map((role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.toUpperCase()),
                    ))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();  // Kapatma işlemi
          },
          child: Text('Vazgeç'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(selectedRole);  // Seçilen rolü döndürme
          },
          child: Text('Onayla'),
        ),
      ],
    );
  }
}
