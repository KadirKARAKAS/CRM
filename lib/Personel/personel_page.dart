import 'package:crm/Register/Login/PassReset/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonelPage extends StatefulWidget {
  @override
  _PersonelPageState createState() => _PersonelPageState();
}

class _PersonelPageState extends State<PersonelPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';
  int _sortColumnIndex = 0;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Sayfası',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                labelText: 'Arama yapın...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DropdownButton<String>(
                value: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
                items: ['All', 'admin', 'personel', 'user']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
                isExpanded: true,
                style: const TextStyle(color: Colors.deepPurple),
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data?.docs ?? [];

                  final filteredUsers = users.where((userDoc) {
                    var user = userDoc.data() as Map<String, dynamic>;
                    final matchesSearch = (user['name']
                                ?.toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ??
                            false) ||
                        (user['email']
                                ?.toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ??
                            false) ||
                        (user['role']
                                ?.toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ??
                            false);
                    final matchesRole = (_selectedRole == 'All' ||
                        user['role']?.toLowerCase() ==
                            _selectedRole.toLowerCase());

                    return matchesSearch && matchesRole;
                  }).toList();

                  if (_ascending) {
                    filteredUsers
                        .sort((a, b) => _compare(a, b, _sortColumnIndex));
                  } else {
                    filteredUsers
                        .sort((a, b) => _compare(b, a, _sortColumnIndex));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16.0,
                      headingRowHeight: 56.0,
                      dataRowHeight: 56.0,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _ascending,
                      columns: [
                        DataColumn(
                          label: _buildColumnHeader('Ad', 0),
                          onSort: (columnIndex, ascending) =>
                              _onSort(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildColumnHeader('Email', 1),
                          onSort: (columnIndex, ascending) =>
                              _onSort(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildColumnHeader('Rol', 2),
                          onSort: (columnIndex, ascending) =>
                              _onSort(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildColumnHeader('Yaş', 3),
                          onSort: (columnIndex, ascending) =>
                              _onSort(columnIndex, ascending),
                        ),
                      ],
                      rows: filteredUsers.map((userDoc) {
                        var user = userDoc.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: [
                            DataCell(Text(user['name'] ?? '',
                                style: const TextStyle(fontSize: 16))),
                            DataCell(Text(user['email'] ?? '',
                                style: const TextStyle(fontSize: 16))),
                            DataCell(Text(user['role'] ?? '',
                                style: const TextStyle(fontSize: 16))),
                            DataCell(Text(user['age']?.toString() ?? '0',
                                style: const TextStyle(fontSize: 16))),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _compare(
      QueryDocumentSnapshot a, QueryDocumentSnapshot b, int columnIndex) {
    final userA = a.data() as Map<String, dynamic>;
    final userB = b.data() as Map<String, dynamic>;

    switch (columnIndex) {
      case 0:
        return userA['name']!.compareTo(userB['name']!);
      case 1:
        return userA['email']!.compareTo(userB['email']!);
      case 2:
        return userA['role']!.compareTo(userB['role']!);
      case 3:
        return (userA['age'] ?? 0).compareTo(userB['age'] ?? 0);
      default:
        return 0;
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _ascending = ascending;
    });
  }

  Widget _buildColumnHeader(String title, int columnIndex) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
