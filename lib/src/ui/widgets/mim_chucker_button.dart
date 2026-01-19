import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:mim_chucker/mim_chucker.dart';

/// A draggable button to launch MimChucker
class MimChuckerButton extends StatefulWidget {
  const MimChuckerButton({super.key});

  @override
  State<MimChuckerButton> createState() => _MimChuckerButtonState();
}

class _MimChuckerButtonState extends State<MimChuckerButton> {
  // Initial position (bottom-right area)
  Offset _position = const Offset(20, 64);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MimChucker.isOverlayActive,
      builder: (context, isOverlayActive, child) {
        if (isOverlayActive) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: _position.dx,
          bottom: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position -= details.delta;
              });
            },
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ShadTheme(
                data: ShadThemeData(
                  brightness: Brightness.light,
                  colorScheme: const ShadZincColorScheme.light(),
                ),
                child: ShadButton(
                  width: 46,
                  height: 46,
                  padding: EdgeInsets.zero,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  onPressed: () {
                    MimChucker.launch(context);
                  },
                  child: const Icon(lucide.LucideIcons.network, size: 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
