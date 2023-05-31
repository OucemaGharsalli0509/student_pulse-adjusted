import 'package:flutter/material.dart';
import '../../../services/admin_services/formbuilder_service.dart';
import 'manage_form_question_screen.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({Key? key}) : super(key: key);

  @override
  _FormBuilderScreenState createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = [];
  TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Builder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 16.0,),
              Text('Form Title',
                style: TextStyle(
                    fontSize: 20.0,
                    color: Color(0xff5aa087)
                ),
              ),
              SizedBox(height: 16.0,),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter a title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  // Save the title
                },
              ),
              //SizedBox(height: 16.0,),
              //Text('Choose the Group',
              // style: TextStyle(
              //fontSize: 20.0,
              //  color: Color(0xff5aa087)
              //),
              //),
              //SizedBox(height: 16.0,),
              //TextFormField(
              //controller: _titleController,
              //decoration: const InputDecoration(
              //hintText: '',
              //border: OutlineInputBorder(),
              //),
              //validator: (value) {
              //if (value!.isEmpty) {
              //return 'Please enter a title';
              //}
              //return null;
              //},
              //onSaved: (value) {
              // Save the title
              //},
              //),
              SizedBox(height: 16.0,),
              ..._controllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                        hintText: 'Enter a question',
                        border: OutlineInputBorder()
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a question';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Save the question
                    },
                  ),
                );
              }).toList(),
              SizedBox(height: 16.0,),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final List<String> questions =
                    _controllers.map((controller) => controller.text).toList();
                    final String title = _titleController.text;

                    try {
                      await FormBuilderService.addForm(title, questions);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Form saved successfully.'),
                      ));
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context){
                            return ManageFormQuestionsScreen();
                          }));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString()),
                      ));
                    }
                  }
                },
                child: const Text('Save'),
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _controllers.add(TextEditingController());
          });
        },
        label: Text('Add Question' ,),
        icon: const Icon(Icons.add),

      ),
    );
  }
}
//     );