import 'package:flutter/material.dart';

class EditQuestionsScreen extends StatefulWidget {
  final String formQuestionId;
  final String title;
  final List<dynamic> questions;

  const EditQuestionsScreen({
    Key? key,
    required this.formQuestionId,
    required this.title,
    required this.questions,
  }) : super(key: key);

  @override
  _EditQuestionsScreenState createState() => _EditQuestionsScreenState();
}

class _EditQuestionsScreenState extends State<EditQuestionsScreen> {
  late TextEditingController _titleController;
  List<dynamic> updatedQuestions = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    updatedQuestions = List.from(widget.questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Form Questions'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: updatedQuestions.length,
                itemBuilder: (context, index) {
                  final question = updatedQuestions[index] as String;
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        question,
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            updatedQuestions.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _addQuestion();
        },
      ),
    );
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) {
        String newQuestion = '';

        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Question',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    newQuestion = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      updatedQuestions.add(newQuestion);
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
