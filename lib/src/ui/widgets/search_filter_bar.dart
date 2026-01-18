import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;

import '../../providers/chucker_provider.dart';

/// Widget to display active search filters
class SearchFilterBar extends ConsumerWidget {
  /// Constructor
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mimChuckerProvider);
    final notifier = ref.read(mimChuckerProvider.notifier);

    final hasFilters = state.apiNameFilter.isNotEmpty ||
        state.methodFilter != null ||
        state.statusCodeFilter != null;

    if (!hasFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: ShadTheme.of(context).colorScheme.muted.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(lucide.LucideIcons.filter, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (state.apiNameFilter.isNotEmpty)
                    _buildFilterChip(
                      context,
                      'API: ${state.apiNameFilter}',
                      () => notifier.setApiNameFilter(''),
                    ),
                  if (state.methodFilter != null)
                    _buildFilterChip(
                      context,
                      'Method: ${state.methodFilter}',
                      () => notifier.setMethodFilter(null),
                    ),
                  if (state.statusCodeFilter != null)
                    _buildFilterChip(
                      context,
                      'Status: ${state.statusCodeFilter}',
                      () => notifier.setStatusCodeFilter(null),
                    ),
                ],
              ),
            ),
          ),
          ShadButton.ghost(
            width: 24,
            height: 24,
            padding: EdgeInsets.zero,
            onPressed: () => notifier.clearFilters(),
            child: const Icon(lucide.LucideIcons.trash, size: 16),
          ),
        ],
      ),
    );
  }

  /// Build a filter chip widget using ShadButton
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    VoidCallback onRemove,
  ) {
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ShadBadge.secondary(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(lucide.LucideIcons.x, size: 12),
              )
            ],
          ),
        ));
  }
}
