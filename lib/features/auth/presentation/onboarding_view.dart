import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import 'widgets/polaroid_collage.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    super.key,
    required this.photoSeeds,
    required this.nameController,
    required this.onNameChanged,
    required this.onStart,
    required this.onSignIn,
  });

  final List<String> photoSeeds;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;

  /// Null until a name is typed.
  final VoidCallback? onStart;
  final VoidCallback? onSignIn;

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
                      'Tu diario privado de lugares',
                      style: tokens.text.displayL,
                    ),
                    SizedBox(height: s.md),
                    Text(
                      'Guarda los lugares que quieres conocer, registra tus '
                      'visitas y vuelve a ellas como a un álbum de recuerdos.',
                      style: tokens.text.body.copyWith(
                        color: tokens.colors.inkMuted,
                      ),
                    ),
                    SizedBox(height: s.xl),
                    TextField(
                      controller: nameController,
                      onChanged: onNameChanged,
                      textCapitalization: TextCapitalization.words,
                      style: tokens.text.body,
                      decoration: const InputDecoration(hintText: 'Tu nombre'),
                    ),
                    SizedBox(height: s.lg),
                    PrimaryButton(
                      label: 'Empezar mi diario',
                      onPressed: onStart,
                    ),
                    SizedBox(height: s.md),
                    GhostButton(
                      label: 'Ya tengo una cuenta',
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
                            'Privado por defecto. Tú decides qué compartir.',
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
