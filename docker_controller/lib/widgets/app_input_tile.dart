import 'package:docker_controller/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

/// A tappable [InputDecorator] tile that looks like a form field but opens a
/// bottom sheet or modal on tap (e.g. auth type, advanced options).
class AppInputTile extends StatelessWidget {
  const AppInputTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.borderColor,
    required this.labelColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color borderColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.inputBorderRadius);
    final side = BorderSide(color: borderColor);
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor),
          floatingLabelStyle: TextStyle(color: labelColor),
          border: OutlineInputBorder(borderRadius: radius, borderSide: side),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: side,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: side,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          prefixIcon: Icon(icon, color: borderColor),
          suffixIcon: Icon(Icons.arrow_drop_down, color: borderColor),
        ),
        child: Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500, color: borderColor),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
