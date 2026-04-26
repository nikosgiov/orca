import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_decorations.dart';
import '../constants/app_paddings.dart';

class AppModalSheet extends StatelessWidget {
  const AppModalSheet({
    super.key,
    required this.child,
    this.padding,
    this.isScrollControlled = true,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isScrollControlled;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.transparent,
      builder: (context) => AppModalSheet(
        padding: padding,
        isScrollControlled: isScrollControlled,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.modal,
      constraints: const BoxConstraints(minHeight: 300),
      padding: EdgeInsets.only(
        left: padding?.resolve(Directionality.of(context)).left ?? 0,
        right: padding?.resolve(Directionality.of(context)).right ?? 0,
        top:
            padding?.resolve(Directionality.of(context)).top ??
            AppPaddings.card.top,
        bottom:
            (padding?.resolve(Directionality.of(context)).bottom ??
                AppPaddings.card.bottom) +
            MediaQuery.of(context).padding.bottom +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: child,
    );
  }
}
