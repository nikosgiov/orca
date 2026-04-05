import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_paddings.dart';

class AdvancedDrawer extends StatefulWidget {
  final bool stayLoggedIn;
  final bool useTls;
  final Function(bool) onStayLoggedInChanged;
  final Function(bool) onUseTlsChanged;

  const AdvancedDrawer({
    super.key,
    required this.stayLoggedIn,
    required this.useTls,
    required this.onStayLoggedInChanged,
    required this.onUseTlsChanged,
  });

  @override
  State<AdvancedDrawer> createState() => _AdvancedDrawerState();
}

class _AdvancedDrawerState extends State<AdvancedDrawer> {
  late bool _localStayLoggedIn;
  late bool _localUseTls;

  @override
  void initState() {
    super.initState();
    _localStayLoggedIn = widget.stayLoggedIn;
    _localUseTls = widget.useTls;
  }

  SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryCyan;
        return AppColors.inputIcon;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryCyan.withValues(alpha: 0.5);
        }
        return AppColors.inputIcon.withValues(alpha: 0.3);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.card,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.advancedOptions,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.inputIcon),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(switchTheme: _buildSwitchTheme()),
              child: SwitchListTile(
                title: Text(AppStrings.rememberThisConnection,
                    style: AppTextStyles.body.copyWith(color: AppColors.inputIcon)),
                subtitle: Text(AppStrings.saveHostCredentials,
                    style: AppTextStyles.caption.copyWith(color: AppColors.inputIcon)),
                value: _localStayLoggedIn,
                onChanged: (value) {
                  setState(() => _localStayLoggedIn = value);
                  widget.onStayLoggedInChanged(value);
                },
                activeThumbColor: AppColors.primaryCyan,
                inactiveThumbColor: AppColors.inputIcon,
                inactiveTrackColor: AppColors.inputIcon.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 8),
            Theme(
              data: Theme.of(context).copyWith(switchTheme: _buildSwitchTheme()),
              child: SwitchListTile(
                title: Text(AppStrings.useTls,
                    style: AppTextStyles.body.copyWith(color: AppColors.inputIcon)),
                subtitle: Text(AppStrings.enableSecureConnection,
                    style: AppTextStyles.caption.copyWith(color: AppColors.inputIcon)),
                value: _localUseTls,
                onChanged: (value) {
                  setState(() => _localUseTls = value);
                  widget.onUseTlsChanged(value);
                },
                activeThumbColor: AppColors.primaryCyan,
                inactiveThumbColor: AppColors.inputIcon,
                inactiveTrackColor: AppColors.inputIcon.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
