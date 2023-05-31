import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageAccountsScreen extends StatefulWidget {
  @override
  _ManageAccountsScreenState createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Accounts'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final accounts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (BuildContext context, int index) {
                  final account = accounts[index].data() as Map<String, dynamic>;
                  final userId = accounts[index].id;

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        account['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('Email: ${account['email']}'),
                          Text('Department: ${account['department']}'),
                          Text('Group: ${account['group']}'),
                          Text('Role: ${account['role']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteAccount(userId),
                      ),
                      onTap: () => _showEditDialog(userId, account),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add new account'),
        icon: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    String email = '';
    String password = '';
    String name = '';
    String department = '';
    String group = '';
    String role = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Account'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a department';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        department = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Group',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a group';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        group = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.verified_user),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a role';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        role = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addAccount(email, password, name, department, group, role);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(String userId, Map<String, dynamic> account) async {
    final formKey = GlobalKey<FormState>();
    String name = account['name'];
    String department = account['department'];
    String group = account['group'];
    String role = account['role'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Account'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: department,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a department';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        department = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: group,
                      decoration: InputDecoration(
                        labelText: 'Group',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a group';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        group = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: role,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.verified_user),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a role';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        role = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _updateAccount(userId, name, department, group, role);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAccount(String email, String password, String name, String department, String group, String role) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'department': department,
          'group': group,
          'role': role,
        });
      }
    } catch (e) {
      print('Error adding account: $e');
    }
  }

  Future<void> _updateAccount(String userId, String name, String department, String group, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'department': department,
        'group': group,
        'role': role,
      });
    } catch (e) {
      print('Error updating account: $e');
    }
  }

  Future<void> _deleteAccount(String userId) async {
    try {
      await _auth.currentUser?.delete();
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting account: $e');
    }
  }
}
