import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool important;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: important ? AppTheme.gold.withOpacity(0.20) : AppTheme.backgroundSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: important ? AppTheme.gold : AppTheme.cardBorder),
          ),
          child: Icon(icon, color: important ? AppTheme.goldSoft : AppTheme.mutedText),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
