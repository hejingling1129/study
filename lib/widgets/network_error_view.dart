import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'gradient_button.dart';

class NetworkErrorView extends StatelessWidget {
  const NetworkErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '暂时连接不上星助校园',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '请检查网络连接后重试。',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: '重新连接',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
