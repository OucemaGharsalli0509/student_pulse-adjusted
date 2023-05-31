import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_question_screen.dart';
import 'formbuilder_screen.dart';

class ManageFormQuestionsScreen extends StatefulWidget {
  const ManageFormQuestionsScreen({Key? key}) : super(key: key);

  @override
  _ManageFormQuestionsScreenState createState() =>
      _ManageFormQuestionsScreenState();
}

class _ManageFormQuestionsScreenState extends State<ManageFormQuestionsScreen> {
  final CollectionReference formQuestionsCollection =
  FirebaseFirestore.instance.collection('form_questions');
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Form Questions'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return _buildWideLayout();
          } else {
            return _buildNormalLayout();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add new question'),
        icon: const Icon(Icons.add),
        onPressed: () {
          _addFormQuestion();
        },
      ),
    );
  }

  Widget _buildNormalLayout() {
    return StreamBuilder<QuerySnapshot>(
      stream: formQuestionsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final formQuestions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: formQuestions.length,
            itemBuilder: (context, index) {
              final formQuestion = formQuestions[index];
              final formQuestionId = formQuestion.id;
              final title = formQuestion['title'] as String;
              final questions = formQuestion['questions'] as List<dynamic>;

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Number of Questions: ${questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      _deleteFormQuestion(formQuestionId);
                    },
                  ),
                  onTap: () {
                    _editFormQuestion(formQuestionId, title, questions);
                  },
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Text('Error fetching form questions');
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildWideLayout() {
    return StreamBuilder<QuerySnapshot>(
      stream: formQuestionsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final formQuestions = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
            ),
            itemCount: formQuestions.length,
            itemBuilder: (context, index) {
              final formQuestion = formQuestions[index];
              final formQuestionId = formQuestion.id;
              final title = formQuestion['title'] as String;
              final questions = formQuestion['questions'] as List<dynamic>;

              return Card(
                elevation: 2,
                margin: EdgeInsets.all(8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Number of Questions: ${questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      _deleteFormQuestion(formQuestionId);
                    },
                  ),
                  onTap: () {
                    _editFormQuestion(formQuestionId, title, questions);
                  },
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Text('Error fetching form questions');
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void _addFormQuestion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormBuilderScreen(),
      ),
    );
  }

  void _editFormQuestion(
      String formQuestionId, String title, List<dynamic> questions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionsScreen(
          formQuestionId: formQuestionId,
          title: title,
          questions: questions,
        ),
      ),
    );
  }

  Future<void> _deleteFormQuestion(String formQuestionId) async {
    try {
      await formQuestionsCollection.doc(formQuestionId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete form question'),
        ),
      );
    }
  }
}
