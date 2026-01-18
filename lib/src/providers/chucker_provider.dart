import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_response.dart';
import '../services/database_service.dart';

/// State class for MimChucker
class MimChuckerState {
  /// List of API responses
  final List<ApiResponse> apiResponses;

  /// Theme mode
  final ThemeMode themeMode;

  /// Primary color
  final Color primaryColor;

  /// Secondary color
  final Color secondaryColor;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// Maximum body size for displaying in notification (in bytes)
  final int maxNotificationBodySize;

  /// Notification duration in seconds
  final int notificationDuration;

  /// Maximum number of stored requests
  final int maxStoredRequests;

  /// Active tab index
  final int activeTabIndex;

  /// Search term
  final String searchTerm;

  /// API name filter
  final String apiNameFilter;

  /// Method filter
  final String? methodFilter;

  /// Status code filter
  final int? statusCodeFilter;

  /// Whether data is currently loading
  final bool isLoading;

  const MimChuckerState({
    this.apiResponses = const [],
    this.themeMode = ThemeMode.system,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.teal,
    this.notificationsEnabled = true,
    this.maxNotificationBodySize = 1024,
    this.notificationDuration = 5,
    this.maxStoredRequests = 100,
    this.activeTabIndex = 0,
    this.searchTerm = '',
    this.apiNameFilter = '',
    this.methodFilter,
    this.statusCodeFilter,
    this.isLoading = true,
  });

  MimChuckerState copyWith({
    List<ApiResponse>? apiResponses,
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? secondaryColor,
    bool? notificationsEnabled,
    int? maxNotificationBodySize,
    int? notificationDuration,
    int? maxStoredRequests,
    int? activeTabIndex,
    String? searchTerm,
    String? apiNameFilter,
    String? methodFilter,
    int? statusCodeFilter,
    bool? isLoading,
    bool clearMethodFilter = false,
    bool clearStatusCodeFilter = false,
  }) {
    return MimChuckerState(
      apiResponses: apiResponses ?? this.apiResponses,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      maxNotificationBodySize:
          maxNotificationBodySize ?? this.maxNotificationBodySize,
      notificationDuration: notificationDuration ?? this.notificationDuration,
      maxStoredRequests: maxStoredRequests ?? this.maxStoredRequests,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      searchTerm: searchTerm ?? this.searchTerm,
      apiNameFilter: apiNameFilter ?? this.apiNameFilter,
      methodFilter:
          clearMethodFilter ? null : (methodFilter ?? this.methodFilter),
      statusCodeFilter: clearStatusCodeFilter
          ? null
          : (statusCodeFilter ?? this.statusCodeFilter),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get filtered API responses based on active filters
  List<ApiResponse> get filteredApiResponses {
    List<ApiResponse> filtered = List.from(apiResponses);

    // Apply search term filter
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((response) {
        // Search in URL
        if (response.baseUrl.toLowerCase().contains(searchTerm.toLowerCase()) ||
            response.path.toLowerCase().contains(searchTerm.toLowerCase())) {
          return true;
        }

        // Search in API name
        if (response.apiName.toLowerCase().contains(searchTerm.toLowerCase())) {
          return true;
        }

        // Search in search keywords
        if (response.searchKeywords.any((keyword) =>
            keyword.toLowerCase().contains(searchTerm.toLowerCase()))) {
          return true;
        }

        // Search in response body
        if (response.body is Map || response.body is List) {
          final jsonString = response.prettyJson;
          if (jsonString.toLowerCase().contains(searchTerm.toLowerCase())) {
            return true;
          }
        } else if (response.body is String) {
          final bodyString = response.body as String;
          if (bodyString.toLowerCase().contains(searchTerm.toLowerCase())) {
            return true;
          }
        }

        // Search in request body
        if (response.request is Map || response.request is List) {
          final jsonString = response.prettyJsonRequest;
          if (jsonString.toLowerCase().contains(searchTerm.toLowerCase())) {
            return true;
          }
        } else if (response.request is String) {
          final requestString = response.request as String;
          if (requestString.toLowerCase().contains(searchTerm.toLowerCase())) {
            return true;
          }
        }

        return false;
      }).toList();
    }

    // Apply API name filter
    if (apiNameFilter.isNotEmpty) {
      filtered = filtered
          .where((response) =>
              response.apiName.toLowerCase() == apiNameFilter.toLowerCase())
          .toList();
    }

    // Apply method filter
    if (methodFilter != null && methodFilter!.isNotEmpty) {
      filtered = filtered
          .where((response) =>
              response.method.toUpperCase() == methodFilter!.toUpperCase())
          .toList();
    }

    // Apply status code filter
    if (statusCodeFilter != null) {
      filtered = filtered
          .where((response) => response.statusCode == statusCodeFilter)
          .toList();
    }

    return filtered;
  }

  /// Get unique API names from all responses
  List<String> get uniqueApiNames {
    final names = <String>{};
    for (final response in apiResponses) {
      if (response.apiName.isNotEmpty) {
        names.add(response.apiName);
      }
    }
    return names.toList()..sort();
  }

  /// Get unique HTTP methods from all responses
  List<String> get uniqueMethods {
    final methods = <String>{};
    for (final response in apiResponses) {
      methods.add(response.method.toUpperCase());
    }
    return methods.toList()..sort();
  }

  /// Get unique status codes from all responses
  List<int> get uniqueStatusCodes {
    final codes = <int>{};
    for (final response in apiResponses) {
      if (response.statusCode > 0) {
        codes.add(response.statusCode);
      }
    }
    return codes.toList()..sort();
  }
}

/// Notifier for MimChucker state management (Riverpod 3)
class MimChuckerNotifier extends Notifier<MimChuckerState> {
  StreamSubscription<List<ApiResponse>>? _apiResponsesSubscription;

  @override
  MimChuckerState build() {
    // Use read instead of watch since DatabaseService is a singleton
    final databaseService = ref.read(databaseServiceProvider);

    // Load initial API responses asynchronously
    // Note: This is fire-and-forget, state will be updated via stream
    Future.microtask(() => _loadApiResponses(databaseService));

    // Listen for changes to API responses
    _apiResponsesSubscription =
        databaseService.apiResponses.listen((responses) {
      state = state.copyWith(apiResponses: responses);
    });

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _apiResponsesSubscription?.cancel();
    });

    return const MimChuckerState();
  }

  /// Set the theme mode
  void setThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  /// Set the primary color
  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }

  /// Set the secondary color
  void setSecondaryColor(Color color) {
    state = state.copyWith(secondaryColor: color);
  }

  /// Set whether notifications are enabled
  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  /// Set the maximum body size for displaying in notification
  void setMaxNotificationBodySize(int size) {
    state = state.copyWith(maxNotificationBodySize: size);
  }

  /// Set the notification duration in seconds
  void setNotificationDuration(int seconds) {
    state = state.copyWith(notificationDuration: seconds);
  }

  /// Set the maximum number of stored requests
  void setMaxStoredRequests(int count) async {
    state = state.copyWith(maxStoredRequests: count);
    await _trimOldRecords();
  }

  /// Set the active tab index
  void setActiveTabIndex(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  /// Set the search term
  void setSearchTerm(String term) {
    state = state.copyWith(searchTerm: term);
  }

  /// Set the API name filter
  void setApiNameFilter(String name) {
    state = state.copyWith(apiNameFilter: name);
  }

  /// Set the method filter
  void setMethodFilter(String? method) {
    state = state.copyWith(
      methodFilter: method,
      clearMethodFilter: method == null,
    );
  }

  /// Set the status code filter
  void setStatusCodeFilter(int? statusCode) {
    state = state.copyWith(
      statusCodeFilter: statusCode,
      clearStatusCodeFilter: statusCode == null,
    );
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchTerm: '',
      apiNameFilter: '',
      clearMethodFilter: true,
      clearStatusCodeFilter: true,
    );
  }

  /// Load API responses from database
  Future<void> _loadApiResponses(DatabaseService databaseService) async {
    state = state.copyWith(isLoading: true);
    final responses = await databaseService.getAllApiResponses();
    state = state.copyWith(apiResponses: responses, isLoading: false);
  }

  /// Reload API responses from database
  Future<void> reloadApiResponses() async {
    final databaseService = ref.read(databaseServiceProvider);
    await _loadApiResponses(databaseService);
  }

  /// Delete all API responses
  Future<void> deleteAllApiResponses() async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.deleteAllApiResponses();
    state = state.copyWith(apiResponses: []);
  }

  /// Delete a specific API response
  Future<void> deleteApiResponse(ApiResponse response) async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.deleteApiResponse(response);
    final updatedResponses = List<ApiResponse>.from(state.apiResponses)
      ..removeWhere((r) => r == response);
    state = state.copyWith(apiResponses: updatedResponses);
  }

  /// Search API responses
  Future<List<ApiResponse>> searchApiResponses({
    String? searchTerm,
    String? apiName,
    String? method,
    int? statusCode,
    String? path,
  }) async {
    final databaseService = ref.read(databaseServiceProvider);
    return await databaseService.searchApiResponses(
      searchTerm: searchTerm,
      apiName: apiName,
      method: method,
      statusCode: statusCode,
      path: path,
    );
  }

  /// Helper method to remove old records if we exceed the maximum
  Future<void> _trimOldRecords() async {
    final databaseService = ref.read(databaseServiceProvider);

    if (state.apiResponses.length > state.maxStoredRequests) {
      // Sort by request time descending
      final sortedResponses = List<ApiResponse>.from(state.apiResponses)
        ..sort((a, b) => b.requestTime.compareTo(a.requestTime));

      // Get the records to delete
      final recordsToDelete = sortedResponses.sublist(state.maxStoredRequests);

      // Delete from database
      for (final record in recordsToDelete) {
        await databaseService.deleteApiResponse(record);
      }

      // Update the list
      final updatedResponses =
          sortedResponses.sublist(0, state.maxStoredRequests);
      state = state.copyWith(apiResponses: updatedResponses);
    }
  }
}

/// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// MimChucker state provider
final mimChuckerProvider =
    NotifierProvider<MimChuckerNotifier, MimChuckerState>(
        MimChuckerNotifier.new);
