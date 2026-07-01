import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PremiumPanel extends StatelessWidget {
  final Widget child;
  final bool highlighted;
  final EdgeInsetsGeometry padding;

  const PremiumPanel({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppTheme.premiumDecoration(highlighted: highlighted),
      child: child,
    );
  }
}
