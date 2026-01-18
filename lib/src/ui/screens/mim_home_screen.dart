import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;

import '../../models/api_response.dart';
import '../../providers/chucker_provider.dart';
import '../widgets/api_list_item.dart';
import '../widgets/search_filter_bar.dart';
import 'mim_detail_screen.dart';
import 'settings_screen.dart';
import '../../utils/chucker_utils.dart';

class MimHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const MimHomeScreen({super.key, this.onClose});

  @override
  ConsumerState<MimHomeScreen> createState() => _ApiListScreenState();
}

class _ApiListScreenState extends ConsumerState<MimHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Restore active tab index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(mimChuckerProvider);
      setState(() {
        _selectedIndex = state.activeTabIndex;
      });
    });

    // Setup search controller
    _searchController.addListener(() {
      ref
          .read(mimChuckerProvider.notifier)
          .setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            _buildFilters(),
            Expanded(
              child: _buildApiClientList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
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
            onPressed: () {
              if (widget.onClose != null && !Navigator.of(context).canPop()) {
                widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Icon(lucide.LucideIcons.x, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _isSearching
                ? ShadInput(
                    controller: _searchController,
                    placeholder: const Text('Search API requests...'),
                    // Assuming trailing or similar slot exists if suffix failed.
                    // If suffix is missing, it might be 'trailing'.
                    // Retrying with 'trailing' if it matches common patterns, or just regular decoration if accessible.
                    // Checking shadcn_ui docs mentally: it definitely has prefix/suffix usually.
                    // Maybe it is 'suffix' but I'm on a version where it's named differently or valid only in specific way?
                    // Error was specific. Let's try 'trailing'. If that fails, I'll check available source.
                    // Actually, let's use 'decoration' compatible way or just a Row for now to be safe if slots are tricky.
                    // But ShadInput should be simple. Let's try 'trailing'.
                    trailing: ShadButton.ghost(
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                      child: const Icon(lucide.LucideIcons.x, size: 16),
                    ),
                  )
                : Text(
                    "Mim Chucker",
                    style: ShadTheme.of(context).textTheme.h4,
                  ),
          ),
          if (!_isSearching)
            ShadButton.ghost(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              child: const Icon(lucide.LucideIcons.search, size: 20),
            ),
          ShadButton.ghost(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: _showFilterDialog,
            child: const Icon(lucide.LucideIcons.filter, size: 20),
          ),
          ShadButton.ghost(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: const Icon(lucide.LucideIcons.settings, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      'All',
      '2XX',
      '3XX',
      '4XX',
      '5XX',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          Color? tabColor;
          if (index == 1) {
            tabColor = Color(MimChuckerUtils.getStatusCodeColor(200));
          }
          if (index == 2) {
            tabColor = Color(MimChuckerUtils.getStatusCodeColor(300));
          }
          if (index == 3) {
            tabColor = Color(MimChuckerUtils.getStatusCodeColor(400));
          }
          if (index == 4) {
            tabColor = Color(MimChuckerUtils.getStatusCodeColor(500));
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: isSelected
                  ? ShadButton(
                      size: ShadButtonSize.sm,
                      backgroundColor: tabColor,
                      foregroundColor: tabColor != null ? Colors.white : null,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        ref
                            .read(mimChuckerProvider.notifier)
                            .setActiveTabIndex(index);
                      },
                      child: Text(
                        tabs[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : ShadButton.secondary(
                      size: ShadButtonSize.sm,
                      foregroundColor: tabColor,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        ref
                            .read(mimChuckerProvider.notifier)
                            .setActiveTabIndex(index);
                      },
                      child: Text(
                        tabs[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(mimChuckerProvider);
        final hasFilters = state.apiNameFilter.isNotEmpty ||
            state.methodFilter != null ||
            state.statusCodeFilter != null;

        return hasFilters
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SearchFilterBar(),
              )
            : const SizedBox(height: 8);
      },
    );
  }

  Widget _buildApiClientList() {
    int? statusCodePrefix;
    if (_selectedIndex == 1) statusCodePrefix = 200;
    if (_selectedIndex == 2) statusCodePrefix = 300;
    if (_selectedIndex == 3) statusCodePrefix = 400;
    if (_selectedIndex == 4) statusCodePrefix = 500;

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(mimChuckerProvider);
        List<ApiResponse> filteredResponses = state.filteredApiResponses;

        if (statusCodePrefix != null) {
          filteredResponses = filteredResponses.where((response) {
            final statusCode = response.statusCode;
            return statusCode >= statusCodePrefix! &&
                statusCode < statusCodePrefix + 100;
          }).toList();
        }

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filteredResponses.isEmpty) {
          return Center(
            child: Text(
              'No API requests found',
              style: ShadTheme.of(context).textTheme.muted,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(mimChuckerProvider.notifier).reloadApiResponses();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filteredResponses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final apiResponse = filteredResponses[index];
              return ApiListItem(
                apiResponse: apiResponse,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MimDetailScreen(apiResponse: apiResponse),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget? _buildFab() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(mimChuckerProvider);
        if (state.apiResponses.isEmpty) {
          return const SizedBox.shrink();
        }

        return ShadButton(
          width: 50,
          height: 50,
          padding: EdgeInsets.zero,
          onPressed: _showClearConfirmationDialog,
          child: const Icon(lucide.LucideIcons.trash2),
        );
      },
    );
  }

  void _showFilterDialog() {
    final state = ref.read(mimChuckerProvider);
    final notifier = ref.read(mimChuckerProvider.notifier);

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Requests',
                        style: ShadTheme.of(context).textTheme.h4,
                      ),
                      ShadButton.ghost(
                        child: const Text('Clear All'),
                        onPressed: () {
                          notifier.clearFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('API Name'),
                  const SizedBox(height: 8),
                  ShadSelect<String>(
                    placeholder: const Text('Select API Name'),
                    options: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                        child: Text(
                          'All',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ),
                      ...state.uniqueApiNames.map(
                        (name) => ShadOption(value: name, child: Text(name)),
                      ),
                    ],
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) {
                      setState(() {
                        notifier.setApiNameFilter(value ?? '');
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('HTTP Method'),
                  const SizedBox(height: 8),
                  ShadSelect<String>(
                    placeholder: const Text('Select HTTP Method'),
                    options: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                        child: Text(
                          'All',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ),
                      ...state.uniqueMethods.map(
                        (method) =>
                            ShadOption(value: method, child: Text(method)),
                      ),
                    ],
                    selectedOptionBuilder: (context, value) => Text(value),
                    onChanged: (value) {
                      setState(() {
                        notifier.setMethodFilter(value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Status Code'),
                  const SizedBox(height: 8),
                  ShadSelect<int>(
                    placeholder: const Text('Select Status Code'),
                    options: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                        child: Text(
                          'All',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ),
                      ...state.uniqueStatusCodes.map(
                        (code) => ShadOption(
                            value: code, child: Text(code.toString())),
                      ),
                    ],
                    selectedOptionBuilder: (context, value) =>
                        Text(value.toString()),
                    onChanged: (value) {
                      setState(() {
                        notifier.setStatusCodeFilter(value);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ShadButton(
                    width: double.infinity,
                    child: const Text('Apply Filters'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return ShadDialog(
          title: const Text('Clear All Requests'),
          description:
              const Text('Are you sure you want to delete all API requests?'),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ShadButton.destructive(
              child: const Text('Clear'),
              onPressed: () {
                ref.read(mimChuckerProvider.notifier).deleteAllApiResponses();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
