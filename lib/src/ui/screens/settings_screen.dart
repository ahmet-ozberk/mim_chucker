import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;

import '../../providers/chucker_provider.dart';
import '../../utils/chucker_utils.dart';
import '../notification/notification_service.dart';

/// Settings screen for MimChucker
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: ShadTheme.of(context).textTheme.large,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ShadButton.ghost(
          child: const Icon(lucide.LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(mimChuckerProvider);
          final notifier = ref.read(mimChuckerProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNotificationSection(context, state, notifier),
              const SizedBox(height: 32),
              _buildStorageSection(context, state, notifier),
              const SizedBox(height: 32),
              _buildInfoSection(context),
            ],
          );
        },
      ),
    );
  }

  /// Build notification settings section
  Widget _buildNotificationSection(
    BuildContext context,
    MimChuckerState state,
    MimChuckerNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: ShadTheme.of(context).textTheme.h4,
        ),
        const SizedBox(height: 16),
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Show Notifications'),
                      Text(
                        'Show in-app notifications for API requests',
                        style: ShadTheme.of(context)
                            .textTheme
                            .muted
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  ShadSwitch(
                    value: state.notificationsEnabled,
                    onChanged: (value) {
                      notifier.setNotificationsEnabled(value);
                      NotificationService.setNotificationsEnabled(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Max Notification Body Size'),
                      Text(
                        MimChuckerUtils.formatBytes(
                            state.maxNotificationBodySize.toDouble()),
                        style: ShadTheme.of(context)
                            .textTheme
                            .muted
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  ShadSelect<int>(
                    placeholder: const Text('Size'),
                    initialValue: state.maxNotificationBodySize,
                    options: const [
                      ShadOption(value: 512, child: Text('512 B')),
                      ShadOption(value: 1024, child: Text('1 KB')),
                      ShadOption(value: 2048, child: Text('2 KB')),
                      ShadOption(value: 4096, child: Text('4 KB')),
                    ],
                    selectedOptionBuilder: (context, value) {
                      return Text(
                          MimChuckerUtils.formatBytes(value.toDouble()));
                    },
                    onChanged: state.notificationsEnabled
                        ? (value) {
                            if (value != null) {
                              notifier.setMaxNotificationBodySize(value);
                            }
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notification Duration'),
                      Text(
                        '${state.notificationDuration} seconds',
                        style: ShadTheme.of(context)
                            .textTheme
                            .muted
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  ShadSelect<int>(
                    placeholder: const Text('Duration'),
                    initialValue: state.notificationDuration,
                    options: const [
                      ShadOption(value: 3, child: Text('3s')),
                      ShadOption(value: 5, child: Text('5s')),
                      ShadOption(value: 8, child: Text('8s')),
                      ShadOption(value: 10, child: Text('10s')),
                    ],
                    selectedOptionBuilder: (context, value) =>
                        Text('${value}s'),
                    onChanged: state.notificationsEnabled
                        ? (value) {
                            if (value != null) {
                              notifier.setNotificationDuration(value);
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build storage settings section
  Widget _buildStorageSection(
    BuildContext context,
    MimChuckerState state,
    MimChuckerNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage',
          style: ShadTheme.of(context).textTheme.h4,
        ),
        const SizedBox(height: 16),
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Maximum Stored Requests'),
                      Text(
                        'Older requests will be deleted automatically',
                        style: ShadTheme.of(context)
                            .textTheme
                            .muted
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: ShadSelect<int>(
                      placeholder: const Text('Select'),
                      initialValue: state.maxStoredRequests,
                      options: const [
                        ShadOption(value: 50, child: Text('50')),
                        ShadOption(value: 100, child: Text('100')),
                        ShadOption(value: 200, child: Text('200')),
                        ShadOption(value: 500, child: Text('500')),
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(value.toString()),
                      onChanged: (value) {
                        if (value != null) {
                          notifier.setMaxStoredRequests(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clear All Data'),
                      Text(
                        'Delete all stored API requests',
                        style: ShadTheme.of(context)
                            .textTheme
                            .muted
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () => _showClearDataDialog(context, notifier),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build info section
  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: ShadTheme.of(context).textTheme.h4,
        ),
        const SizedBox(height: 16),
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mim Chucker',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('An HTTP requests inspector for Flutter',
                  style: ShadTheme.of(context).textTheme.muted),
              const SizedBox(height: 16),
              const Text('Features',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '• Shadcn UI Design\n'
                '• Isolate support for background processing\n'
                '• Advanced search by API name\n'
                '• Support for Dio, Chopper, and HttpClient\n',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show clear data confirmation dialog
  void _showClearDataDialog(
    BuildContext context,
    MimChuckerNotifier notifier,
  ) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return ShadDialog(
          title: const Text('Clear All Data'),
          description: const Text(
            'Are you sure you want to delete all stored API requests? This action cannot be undone.',
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ShadButton.destructive(
              onPressed: () {
                notifier.deleteAllApiResponses();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
