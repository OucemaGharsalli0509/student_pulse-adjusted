import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({Key? key}) : super(key: key);

  @override
  _DepartmentScreenState createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final TextEditingController _departmentNameController =
  TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  late Stream<QuerySnapshot<Map<String, dynamic>>> _departmentsStream;

  @override
  void initState() {
    super.initState();
    _departmentsStream = FirebaseFirestore.instance
        .collection('departments')
        .orderBy('departmentName')
        .snapshots();
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _addDepartment() async {
    final departmentName = _departmentNameController.text;

    if (departmentName.isNotEmpty) {
      final departmentId = FirebaseFirestore.instance
          .collection('departments')
          .doc()
          .id; // Generate a unique departmentId

      await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .set({
        'departmentId': departmentId,
        'departmentName': departmentName,
        'groups': [],
      });

      _departmentNameController.clear();
    }
  }

  Future<void> _editDepartment(
      String departmentId, String newDepartmentName) async {
    await FirebaseFirestore.instance
        .collection('departments')
        .doc(departmentId)
        .update({'departmentName': newDepartmentName});
  }

  Future<void> _addGroup(String departmentId) async {
    final groupName = _groupNameController.text;

    if (groupName.isNotEmpty) {
      final departmentRef =
      FirebaseFirestore.instance.collection('departments').doc(departmentId);

      await departmentRef.update({
        'groups': FieldValue.arrayUnion([groupName])
      });

      _groupNameController.clear();
    }
  }

  Future<void> _editGroup(
      String departmentId, String oldGroupName, String newGroupName) async {
    final departmentRef =
    FirebaseFirestore.instance.collection('departments').doc(departmentId);

    await departmentRef.update({
      'groups': FieldValue.arrayRemove([oldGroupName])
    });

    await departmentRef.update({
      'groups': FieldValue.arrayUnion([newGroupName])
    });
  }

  Future<void> _deleteGroup(String departmentId, String groupName) async {
    final departmentRef =
    FirebaseFirestore.instance.collection('departments').doc(departmentId);

    await departmentRef.update({
      'groups': FieldValue.arrayRemove([groupName])
    });
  }

  Future<void> _deleteDepartment(String departmentId) async {
    final departmentRef =
    FirebaseFirestore.instance.collection('departments').doc(departmentId);

    await departmentRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Departments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _departmentNameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
              ),
            ),
            ElevatedButton(
              onPressed: _addDepartment,
              child: const Text('Add Department'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Departments',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _departmentsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final departments = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        final department = departments[index].data();
                        final departmentId = department['departmentId'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(department['departmentName']),
                            subtitle: Text(
                                'Groups: ${department['groups'].length}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteDepartment(departmentId),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final editDepartmentController =
                                  TextEditingController(
                                      text: department['departmentName']);

                                  return AlertDialog(
                                    title: const Text('Edit Department'),
                                    content: TextField(
                                      controller: editDepartmentController,
                                      decoration: const InputDecoration(
                                        labelText: 'Department Name',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _editDepartment(
                                            departmentId,
                                            editDepartmentController.text,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Manage Groups'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _groupNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Group Name',
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _addGroup(departmentId),
                                          child: const Text('Add Group'),
                                        ),
                                        const SizedBox(height: 8.0),
                                        const Text(
                                          'Groups',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        ...department['groups'].map<Widget>(
                                              (group) => ListTile(
                                            title: Text(group),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => _deleteGroup(
                                                departmentId,
                                                group,
                                              ),
                                            ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  final editGroupController =
                                                  TextEditingController(
                                                      text: group);

                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Edit Group'),
                                                    content: TextField(
                                                      controller:
                                                      editGroupController,
                                                      decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                        'Group Name',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                        const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _editGroup(
                                                            departmentId,
                                                            group,
                                                            editGroupController
                                                                .text,
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                        const Text('Save'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text('Error occurred while loading departments.');
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
