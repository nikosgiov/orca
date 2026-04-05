import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_dimensions.dart';
import '../../models/connection_config.dart';

class AuthDrawer extends StatefulWidget {
  final AuthType selectedAuthType;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? authError;
  final Function(AuthType) onAuthTypeChanged;

  const AuthDrawer({
    super.key,
    required this.selectedAuthType,
    required this.usernameController,
    required this.passwordController,
    this.authError,
    required this.onAuthTypeChanged,
  });

  @override
  State<AuthDrawer> createState() => _AuthDrawerState();
}

class _AuthDrawerState extends State<AuthDrawer> {
  bool _obscurePassword = true;
  late AuthType _localAuthType;

  @override
  void initState() {
    super.initState();
    _localAuthType = widget.selectedAuthType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.card,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                AppStrings.authentication,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.inputIcon),
              ),
            ),
            if (widget.authError != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.authError!,
                        style: AppTextStyles.errorMessage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
            if (_localAuthType == AuthType.basic) ...[
               _buildModalTextField(
                controller: widget.usernameController,
                labelText: AppStrings.username,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              _buildModalTextField(
                controller: widget.passwordController,
                labelText: AppStrings.password,
                prefixIcon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 16),
            ],
            RadioGroup<AuthType>(
              groupValue: _localAuthType,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _localAuthType = value);
                  widget.onAuthTypeChanged(value);
                }
              },
              child: Column(
                children: AuthType.values.map((type) => RadioListTile<AuthType>(
                      title: Text(type.displayName,
                          style: AppTextStyles.body.copyWith(color: AppColors.inputIcon)),
                      subtitle: Text(type.description,
                          style: AppTextStyles.caption.copyWith(color: AppColors.inputIcon)),
                      value: type,
                      activeColor: AppColors.secondaryBlue,
                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                        return states.contains(WidgetState.selected)
                            ? AppColors.secondaryBlue
                            : AppColors.inputIcon;
                      }),
                      overlayColor:
                          WidgetStateProperty.all(AppColors.secondaryBlue.withValues(alpha: 0.1)),
                    )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    final radius = BorderRadius.circular(AppDimensions.inputBorderRadius);
    final side = const BorderSide(color: AppColors.inputIcon);
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: AppColors.inputIcon),
      cursorColor: AppColors.inputIcon,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.inputIcon),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: radius, borderSide: side),
        focusedBorder: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
        prefixIcon: Icon(prefixIcon, color: AppColors.inputIcon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.inputIcon,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
      ),
    );
  }
}
