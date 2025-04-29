import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.text,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onSaved,
    this.onInputChanged,
    this.hideText = false,
  });

  final String text;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(int, String, String)? onInputChanged;
  final bool hideText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        obscureText: hideText ? true : false,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          label: Text(text, style: TextStyle(fontSize: 18)),
        ),
        validator: validator,
        onSaved: onSaved,
        onChanged: (value) {
          if (onInputChanged == null) {
            return;
          }
          onInputChanged!(0, '', value);
        },
      ),
    );
  }
}
