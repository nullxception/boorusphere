import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PrivateTextField extends HookWidget {
  const PrivateTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.imeIncognito,
  });

  final TextEditingController controller;
  final String label;
  final bool imeIncognito;

  @override
  Widget build(BuildContext context) {
    final showText = useState(false);
    return TextFormField(
      controller: controller,
      obscureText: !showText.value,
      enableIMEPersonalizedLearning: false,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(showText.value ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            showText.value = !showText.value;
          },
        ),
      ),
    );
  }
}
