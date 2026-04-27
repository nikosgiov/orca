import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AdvancedDrawer extends StatefulWidget {
  const AdvancedDrawer({
    super.key,
    required this.stayLoggedIn,
    required this.useTls,
    required this.onStayLoggedInChanged,
    required this.onUseTlsChanged,
  });
  final bool stayLoggedIn;
  final bool useTls;
  final Function(bool) onStayLoggedInChanged;
  final Function(bool) onUseTlsChanged;

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
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.slate400;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.slate400.withValues(alpha: 0.3);
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
              AppLocalizations.of(context)!.advancedOptions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.slate400,
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(switchTheme: _buildSwitchTheme()),
              child: SwitchListTile(
                title: Text(
                  AppLocalizations.of(context)!.rememberThisConnection,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.slate400,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.saveHostCredentials,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.slate400,
                  ),
                ),
                value: _localStayLoggedIn,
                onChanged: (value) {
                  setState(() => _localStayLoggedIn = value);
                  widget.onStayLoggedInChanged(value);
                },
                activeThumbColor: AppColors.primary,
                inactiveThumbColor: AppColors.slate400,
                inactiveTrackColor: AppColors.slate400.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 8),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(switchTheme: _buildSwitchTheme()),
              child: SwitchListTile(
                title: Text(
                  AppLocalizations.of(context)!.useTls,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.slate400,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.enableSecureConnection,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.slate400,
                  ),
                ),
                value: _localUseTls,
                onChanged: (value) {
                  setState(() => _localUseTls = value);
                  widget.onUseTlsChanged(value);
                },
                activeThumbColor: AppColors.primary,
                inactiveThumbColor: AppColors.slate400,
                inactiveTrackColor: AppColors.slate400.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
