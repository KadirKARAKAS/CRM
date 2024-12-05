import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/Admin/add_user_page.dart';
import 'package:crm/Register/Login/PassReset/sign_in_page.dart';
import 'package:crm/Admin/edit_user_page.dart';
import 'package:crm/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crm/model/user_provider.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';
  int _sortColumnIndex = 0;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.users.where((user) {
      final matchesSearch =
          (user.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (user.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (user.role?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false);

      final matchesRole = (_selectedRole == 'All' ||
          user.role?.toLowerCase() == _selectedRole.toLowerCase());

      return matchesSearch && matchesRole;
    }).toList();

    if (_ascending) {
      users.sort((a, b) => _compare(a, b, _sortColumnIndex));
    } else {
      users.sort((a, b) => _compare(b, a, _sortColumnIndex));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Paneli',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddUserPage()),
              );
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
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
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.deepPurple),
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
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value!),
              items: ['All', 'admin', 'personel', 'user']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
              isExpanded: true,
              style: TextStyle(color: Colors.deepPurple),
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  header: Text('Kullanıcı Listesi',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    DataColumn(label: Text('İşlemler')),
                  ],
                  source: _UserDataSource(users, context, userProvider),
                  rowsPerPage: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _compare(UserModel a, UserModel b, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return a.name!.compareTo(b.name!);
      case 1:
        return a.email!.compareTo(b.email!);
      case 2:
        return a.role!.compareTo(b.role!);
      case 3:
        return (a.age ?? 0).compareTo(b.age ?? 0);
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List<UserModel> users;
  final BuildContext context;
  final UserProvider userProvider;

  _UserDataSource(this.users, this.context, this.userProvider);

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(cells: [
      DataCell(Text(user.name ?? '', style: TextStyle(fontSize: 16))),
      DataCell(Text(user.email ?? '', style: TextStyle(fontSize: 16))),
      DataCell(Text(user.role ?? '', style: TextStyle(fontSize: 16))),
      DataCell(
          Text(user.age?.toString() ?? '0', style: TextStyle(fontSize: 16))),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
                if (userDoc.exists) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserPage(userDoc: userDoc),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => userProvider.deleteUser(user.uid),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
