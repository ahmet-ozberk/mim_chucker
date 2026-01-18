library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/ui/notification/notification_service.dart';
import 'src/ui/screens/mim_home_screen.dart';
import 'src/utils/chucker_utils.dart';

export 'src/interceptors/chopper_interceptor.dart';
export 'src/interceptors/dio_interceptor.dart';
export 'src/interceptors/http_client.dart';

import 'src/ui/widgets/mim_overlay_wrapper.dart';
import 'src/ui/widgets/mim_chucker_button.dart';
export 'src/ui/widgets/mim_chucker_button.dart';

/// Main entry point for MimChucker package
class MimChucker {
  /// Whether to show MimChucker on release builds
  static bool get showOnRelease => MimChuckerUtils.showOnRelease;

  /// Set whether to show MimChucker on release builds
  static set showOnRelease(bool value) {
    MimChuckerUtils.showOnRelease = value;
  }

  /// The navigator observer for MimChucker
  static NavigatorObserver get navigatorObserver =>
      MimChuckerUtils.navigatorObserver;

  /// Value Notifier for overlay active state
  static final ValueNotifier<bool> isOverlayActive = ValueNotifier(false);

  /// Launch the MimChucker UI
  static OverlayEntry? _overlayEntry;
  static GlobalKey<MimOverlayWrapperState>? _overlayKey;

  /// Dismiss the MimChucker UI
  static void dismiss() {
    if (_overlayEntry == null) return;

    if (_overlayKey?.currentState != null) {
      _overlayKey!.currentState!.animateOut();
    } else {
      _cleanup();
    }
  }

  /// Cleanup overlay resources
  static void _cleanup() {
    try {
      _overlayEntry?.remove();
    } catch (e) {
      debugPrint('MimChucker: Error dismissing overlay: $e');
    } finally {
      _overlayEntry = null;
      _overlayKey = null;
      isOverlayActive.value = false;
    }
  }

  /// App wrapper to easily integrate MimChucker button
  static Widget app({required Widget child, bool enabled = true}) {
    if (!enabled) return child;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        const MimChuckerButton(),
      ],
    );
  }

  /// Launch the MimChucker UI
  static void launch(BuildContext context) {
    if (_overlayEntry != null) return;

    try {
      OverlayState? overlay = Overlay.maybeOf(context);

      // Fallback: Try to find overlay via Navigator
      overlay ??= Navigator.maybeOf(context)?.overlay;

      // Fallback: Try to find overlay via attached NavigatorObserver
      overlay ??= navigatorObserver.navigator?.overlay;

      if (overlay == null) {
        debugPrint('MimChucker: No Overlay found in context');
        return;
      }

      _overlayEntry = OverlayEntry(
        builder: (ctx) {
          return MimOverlayWrapper(
            key: _overlayKey,
            onDismissed: _cleanup,
            child: ShadApp(
              debugShowCheckedModeBanner: false,
              theme: ShadThemeData(
                brightness: Brightness.light,
                colorScheme: const ShadZincColorScheme.light(),
              ),
              darkTheme: ShadThemeData(
                brightness: Brightness.dark,
                colorScheme: const ShadZincColorScheme.dark(),
              ),
              themeMode: ThemeMode.system,
              home: const ProviderScope(
                child: MimHomeScreen(
                  onClose: dismiss,
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(_overlayEntry!);
      isOverlayActive.value = true;
    } catch (e) {
      debugPrint('MimChucker: Failed to launch overlay: $e');
      _overlayEntry = null;
      _overlayKey = null;
      isOverlayActive.value = false;
    }
  }

  /// Initialize MimChucker with the provided overlay state
  static void initialize(OverlayState overlayState) {
    NotificationService.setOverlayState(overlayState);
  }

  /// Set whether notifications are enabled
  static void setNotificationsEnabled(bool enabled) {
    NotificationService.setNotificationsEnabled(enabled);
  }

  /// Set notification duration in seconds
  static void setNotificationDuration(int seconds) {
    NotificationService.setNotificationDuration(seconds);
  }
}
