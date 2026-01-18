import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;

import '../../models/api_response.dart';

/// Widget for displaying an API response in a list
class ApiListItem extends StatelessWidget {
  /// The API response to display
  final ApiResponse apiResponse;

  /// Callback when tapped
  final VoidCallback onTap;

  /// Constructor
  const ApiListItem({
    super.key,
    required this.apiResponse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color
    Color statusColor = ShadTheme.of(context).colorScheme.foreground;
    if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
      statusColor = Colors.green;
    } else if (apiResponse.statusCode >= 300 && apiResponse.statusCode < 400) {
      statusColor = Colors.orange;
    } else if (apiResponse.statusCode >= 400) {
      statusColor = Colors.red;
    }

    // Determine method color
    Color methodColor = ShadTheme.of(context).colorScheme.primary;
    if (apiResponse.method == 'GET') {
      methodColor = Colors.blue;
    } else if (apiResponse.method == 'POST') {
      methodColor = Colors.orange;
    } else if (apiResponse.method == 'PUT') {
      methodColor = Colors.purple;
    } else if (apiResponse.method == 'DELETE') {
      methodColor = Colors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShadBadge(
                      backgroundColor: methodColor,
                      foregroundColor: Colors.white,
                      child: Text(
                        apiResponse.method,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShadBadge.outline(
                      child: Text(
                        apiResponse.statusCode.toString(),
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatTimestamp(apiResponse.requestTime),
                  style: ShadTheme.of(context)
                      .textTheme
                      .muted
                      .copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              apiResponse.path, // Using path as per model
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ShadTheme.of(context).textTheme.p.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  lucide.LucideIcons.clock,
                  size: 12,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '${apiResponse.duration} ms',
                  style: ShadTheme.of(context)
                      .textTheme
                      .muted
                      .copyWith(fontSize: 10),
                ),
                const SizedBox(width: 12),
                Icon(
                  lucide.LucideIcons.arrowDownUp,
                  size: 12,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatBytes(apiResponse.responseSize),
                  style: ShadTheme.of(context)
                      .textTheme
                      .muted
                      .copyWith(fontSize: 10),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String _formatBytes(num bytes) {
    if (bytes < 1024) return '${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
