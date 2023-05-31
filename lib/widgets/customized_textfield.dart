import 'package:flutter/material.dart';

class CustomizedTextfield extends StatefulWidget {
  final TextEditingController myController;
  final String? hintText;
  final bool? isPassword;

  const CustomizedTextfield({
    Key? key,
    required this.myController,
    this.hintText,
    this.isPassword,
  }) : super(key: key);

  @override
  _CustomizedTextfieldState createState() => _CustomizedTextfieldState();
}

class _CustomizedTextfieldState extends State<CustomizedTextfield> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        keyboardType: widget.isPassword!
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        enableSuggestions: widget.isPassword! ? false : true,
        autocorrect: widget.isPassword! ? false : true,
        obscureText: widget.isPassword! && _obscureText,
        controller: widget.myController,
        decoration: InputDecoration(
          suffixIcon: widget.isPassword!
              ? IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff5aa087), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff5aa087), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: const Color(0xffE8ECF4),
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 20), // Set the desired font size
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
