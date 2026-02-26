import 'package:flutter/services.dart';

class TitleCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    newText = newText
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
    );
  }
}
