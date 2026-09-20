import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'gradient_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.mascot = true,
  });

  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final bool mascot;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mascot)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.mintSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusBtn),
                ),
                child: const Text(
                  '[星小助]',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            if (actionText != null) ...[
              const SizedBox(height: 20),
              GradientButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
