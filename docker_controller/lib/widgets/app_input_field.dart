import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_colors.dart';

/// A styled text form field with optional password-toggle.
class AppInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? initialValue;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;

  const AppInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.enabled = true,
    this.validator,
    this.keyboardType,
    this.initialValue,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      obscureText: widget.isPassword ? _obscureText : false,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: AppColors.white),
        floatingLabelStyle: const TextStyle(color: AppColors.white),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.white)
            : null,
        suffixIcon: widget.suffixIcon ??
            (widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.white,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.inputBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.white),
        ),
      ),
    );
  }
}