import 'package:flutter/material.dart';
import 'package:manzoma/shared/widgets/custom_input.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      controller: controller,
      label: label,
      hintText: hint,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon is Icon ? (prefixIcon as Icon).icon : null,
      validator: validator,
    );
  }
}
