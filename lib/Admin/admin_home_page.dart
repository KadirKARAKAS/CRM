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
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  TextEditingController _searchController = TextEditingController();
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
        title: Text('Admin Paneli'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddUserPage()),
              );
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            icon: Icon(Icons.logout),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                labelText: 'Ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value!),
              items: ['All', 'admin', 'personel', 'user']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              isExpanded: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PaginatedDataTable(
                header: Text('Kullanıcı Listesi'),
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
                rowsPerPage: 8,
              ),
            ),
          ),
        ],
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
        Text(title),
        if (_sortColumnIndex == columnIndex)
          Icon(
            _ascending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
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
      DataCell(Text(user.name ?? '')),
      DataCell(Text(user.email ?? '')),
      DataCell(Text(user.role ?? '')),
      DataCell(Text(user.age?.toString() ?? '0')),
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
