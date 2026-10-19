import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import 'widgets/polaroid_collage.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    super.key,
    required this.photoSeeds,
    required this.onStart,
    required this.onSignIn,
  });

  final List<String> photoSeeds;
  final VoidCallback onStart;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: tokens.gradients.mistDawn),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: s.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: s.xxl),
                    PolaroidCollage(seeds: photoSeeds),
                    SizedBox(height: s.xxxl),
                    Text(
                      'Your private diary of places',
                      style: tokens.text.displayL,
                    ),
                    SizedBox(height: s.md),
                    Text(
                      'Pin the corners of the world you loved, keep honest '
                      'notes, and revisit them like an old scrapbook.',
                      style: tokens.text.body.copyWith(
                        color: tokens.colors.inkMuted,
                      ),
                    ),
                    SizedBox(height: s.xxl),
                    PrimaryButton(label: 'Start my diary', onPressed: onStart),
                    SizedBox(height: s.md),
                    GhostButton(
                      label: 'I already have an account',
                      onPressed: onSignIn,
                    ),
                    SizedBox(height: s.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          WanderIcons.lock,
                          size: s.lg,
                          color: tokens.colors.inkMuted,
                        ),
                        SizedBox(width: s.xs),
                        Flexible(
                          child: Text(
                            'Private by default. You choose what to share.',
                            style: tokens.text.caption.copyWith(
                              color: tokens.colors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
