import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: Constants.responsiveSpacing(context, 60),
            ),
            SizedBox(height: Constants.responsiveSpacing(context, 16)),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: Constants.responsiveFontSize(context, Theme.of(context).textTheme.titleMedium?.fontSize ?? 16),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: Constants.responsiveSpacing(context, 16)),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: Constants.responsiveSpacing(context, 24)),
                label: Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontSize: Constants.responsiveFontSize(context, 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
