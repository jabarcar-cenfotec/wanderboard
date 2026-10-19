import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/wander_tokens.dart';

/// Presents the app inside a phone-sized frame on wide viewports.
///
/// The mockup is shared as a web build, but every screen is designed for a
/// phone. On a desktop browser this centers a fixed [screenSize] device and
/// overrides [MediaQuery] so layouts behave exactly as on a handset. Viewports
/// narrower than [breakpoint] (an actual phone) get the app full-screen.
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.child, this.enabled = kIsWeb});

  /// Logical size of an iPhone 14 screen.
  static const screenSize = Size(390, 844);

  /// Viewports narrower than this are treated as real phones.
  static const breakpoint = 600.0;

  @visibleForTesting
  static const bezelKey = ValueKey('device-frame-bezel');

  static const _safeArea = EdgeInsets.only(top: 47, bottom: 34);
  static const _bezelWidth = 12.0;
  static const _screenRadius = 44.0;
  static const _islandSize = Size(120, 34);

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (!enabled || media.size.width < breakpoint) return child;

    final tokens = context.wander;
    final colors = tokens.colors;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.gradients.mistDawn),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              key: bezelKey,
              padding: const EdgeInsets.all(_bezelWidth),
              decoration: BoxDecoration(
                color: colors.ink,
                borderRadius: BorderRadius.circular(
                  _screenRadius + _bezelWidth,
                ),
                boxShadow: tokens.shadowLift,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_screenRadius),
                child: SizedBox.fromSize(
                  size: screenSize,
                  child: Stack(
                    children: [
                      MediaQuery(
                        data: media.copyWith(
                          size: screenSize,
                          padding: _safeArea,
                          viewPadding: _safeArea,
                          viewInsets: EdgeInsets.zero,
                        ),
                        child: child,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 11),
                          child: IgnorePointer(
                            child: Container(
                              width: _islandSize.width,
                              height: _islandSize.height,
                              decoration: BoxDecoration(
                                color: colors.ink,
                                borderRadius: BorderRadius.circular(
                                  _islandSize.height / 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
