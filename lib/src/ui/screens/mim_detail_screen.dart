import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;

import '../../models/api_response.dart';
import '../../providers/chucker_provider.dart';
import '../../utils/chucker_utils.dart';
import '../widgets/json_viewer_panel.dart';
import '../widgets/key_value_widget.dart';

class MimDetailScreen extends ConsumerStatefulWidget {
  final ApiResponse apiResponse;

  const MimDetailScreen({
    super.key,
    required this.apiResponse,
  });

  @override
  ConsumerState<MimDetailScreen> createState() => _MimDetailScreenState();
}

class _MimDetailScreenState extends ConsumerState<MimDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ShadButton.ghost(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(lucide.LucideIcons.arrowLeft, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.apiResponse.method,
                  style: ShadTheme.of(context).textTheme.large.copyWith(
                        color: ShadTheme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  widget.apiResponse.path,
                  style: ShadTheme.of(context).textTheme.muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ShadButton.ghost(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: () {
              // ignore: deprecated_member_use
              Share.share(widget.apiResponse.toString());
            },
            child: const Icon(lucide.LucideIcons.share2, size: 20),
          ),
          ShadButton.ghost(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: widget.apiResponse.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Icon(lucide.LucideIcons.copy, size: 20),
          ),
          ShadButton.ghost(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: _showDeleteConfirmationDialog,
            child: const Icon(lucide.LucideIcons.trash2, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Request', 'Response', 'Error'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 4),
              child: isSelected
                  ? ShadButton(
                      size: ShadButtonSize.sm,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() => _selectedTabIndex = index);
                      },
                      child: Text(tabs[index],
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    )
                  : ShadButton.secondary(
                      size: ShadButtonSize.sm,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() => _selectedTabIndex = index);
                      },
                      child: Text(tabs[index],
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildRequestTab();
      case 2:
        return _buildResponseTab();
      case 3:
        return _buildErrorTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('General Info'),
          KeyValueWidget(
              keyText: 'URL',
              valueText:
                  '${widget.apiResponse.baseUrl}${widget.apiResponse.path}'),
          KeyValueWidget(
              keyText: 'Method', valueText: widget.apiResponse.method),
          KeyValueWidget(
              keyText: 'Status Code',
              valueText: widget.apiResponse.statusCode.toString()),
          KeyValueWidget(
              keyText: 'Request Time',
              valueText:
                  MimChuckerUtils.formatDate(widget.apiResponse.requestTime)),
          KeyValueWidget(
              keyText: 'Duration',
              valueText: '${widget.apiResponse.duration.inMilliseconds} ms'),
          const SizedBox(height: 24),
          _buildSectionTitle('Response Headers'),
          if (widget.apiResponse.headers.isEmpty)
            Text('No headers', style: ShadTheme.of(context).textTheme.muted)
          else
            ...widget.apiResponse.headers.entries.map(
              (e) =>
                  KeyValueWidget(keyText: e.key, valueText: e.value.toString()),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Query Parameters'),
          if (widget.apiResponse.queryParameters.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text('No query parameters',
                  style: ShadTheme.of(context).textTheme.muted),
            )
          else
            ...widget.apiResponse.queryParameters.entries.map(
              (e) =>
                  KeyValueWidget(keyText: e.key, valueText: e.value.toString()),
            ),
          _buildSectionTitle('Request Body'),
          _buildRequestBodyWidget(),
        ],
      ),
    );
  }

  Widget _buildRequestBodyWidget() {
    if (widget.apiResponse.request == null) {
      return Text('No request body',
          style: ShadTheme.of(context).textTheme.muted);
    }
    // Assuming JsonViewerPanel can handle Map/List or String.
    // If request is dynamic, JsonViewerPanel should handle it or we pass a map.
    return JsonViewerPanel(
        jsonData: widget.apiResponse.request, title: 'Request Body');
  }

  Widget _buildResponseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Response Body'),
          _buildResponseBodyWidget(),
        ],
      ),
    );
  }

  Widget _buildResponseBodyWidget() {
    final contentType = widget.apiResponse.contentType ?? '';
    if (contentType.toString().startsWith('image/')) {
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Image Response'),
              const SizedBox(height: 8),
              Image.network(
                '${widget.apiResponse.baseUrl}${widget.apiResponse.path}',
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
            ],
          ),
        ),
      );
    }

    return JsonViewerPanel(
        jsonData: widget.apiResponse.body, title: 'Response Body');
  }

  Widget _buildErrorTab() {
    if (widget.apiResponse.statusCode < 400) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(lucide.LucideIcons.checkCircle,
                size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text('No errors', style: ShadTheme.of(context).textTheme.h4),
          ],
        ),
      );
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ShadAlert.destructive(
          icon: const Icon(lucide.LucideIcons.alertCircle),
          title: const Text('Error Occurred'),
          description: Text('Status Code: ${widget.apiResponse.statusCode}'),
        )
        // Note: Body is already shown in Response tab. We could duplicate it here if needed,
        // but simpler is just status code and alert.
        );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: ShadTheme.of(context).textTheme.h4,
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return ShadDialog(
          title: const Text('Delete Request'),
          description:
              const Text('Are you sure you want to delete this API request?'),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ShadButton.destructive(
              onPressed: () {
                ref
                    .read(mimChuckerProvider.notifier)
                    .deleteApiResponse(widget.apiResponse);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
