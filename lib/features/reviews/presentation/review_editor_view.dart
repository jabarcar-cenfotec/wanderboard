import 'package:flutter/material.dart';

import '../../../core/theme/wander_tokens.dart';
import '../../../shared/icons/wander_icons.dart';
import '../../../shared/widgets/atoms/rating_circles.dart';
import '../../../shared/widgets/atoms/tag_chip.dart';
import '../../../shared/widgets/atoms/wander_buttons.dart';
import '../../boards/domain/board.dart';
import '../../places/domain/place.dart';
import '../domain/review_draft.dart';
import 'widgets/mock_photo_picker.dart';

class ReviewEditorView extends StatelessWidget {
  const ReviewEditorView({
    super.key,
    required this.title,
    required this.isEditing,
    required this.draft,
    required this.boards,
    required this.library,
    required this.maxPhotos,
    required this.nameController,
    required this.cityController,
    required this.countryController,
    required this.noteController,
    required this.onTextChanged,
    required this.onTogglePhoto,
    required this.onOpenCamera,
    required this.onRatingChanged,
    required this.onStatusChanged,
    required this.onToggleBoard,
    required this.onClose,
    required this.onSave,
  });

  final String title;
  final bool isEditing;
  final ReviewDraft draft;
  final List<Board> boards;
  final List<PlacePhoto> library;
  final int maxPhotos;
  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController noteController;
  final VoidCallback onTextChanged;
  final ValueChanged<PlacePhoto> onTogglePhoto;
  final VoidCallback onOpenCamera;
  final ValueChanged<int> onRatingChanged;
  final ValueChanged<PlaceStatus> onStatusChanged;
  final ValueChanged<String> onToggleBoard;
  final VoidCallback onClose;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wander;
    final s = tokens.spacing;
    final c = tokens.colors;

    Widget section(String title, {String? hint}) => Padding(
      padding: EdgeInsets.only(top: s.xl, bottom: s.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: tokens.text.titleM)),
          if (hint != null)
            Text(hint, style: tokens.text.caption.copyWith(color: c.inkMuted)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cerrar',
          icon: const Icon(WanderIcons.close),
          onPressed: onClose,
        ),
        title: Text(title),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            s.screen,
            0,
            s.screen,
            s.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            section('El lugar'),
            TextField(
              controller: nameController,
              onChanged: (_) => onTextChanged(),
              textCapitalization: TextCapitalization.words,
              style: tokens.text.body,
              decoration: const InputDecoration(hintText: 'Nombre del lugar'),
            ),
            SizedBox(height: s.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    onChanged: (_) => onTextChanged(),
                    textCapitalization: TextCapitalization.words,
                    style: tokens.text.body,
                    decoration: const InputDecoration(hintText: 'Ciudad'),
                  ),
                ),
                SizedBox(width: s.md),
                Expanded(
                  child: TextField(
                    controller: countryController,
                    onChanged: (_) => onTextChanged(),
                    textCapitalization: TextCapitalization.words,
                    style: tokens.text.body,
                    decoration: const InputDecoration(hintText: 'País'),
                  ),
                ),
              ],
            ),
            section('Estado'),
            Wrap(
              spacing: s.sm,
              runSpacing: s.sm,
              children: [
                for (final status in PlaceStatus.values)
                  TagChip(
                    label: status.label,
                    selected: draft.status == status,
                    onTap: () => onStatusChanged(status),
                  ),
              ],
            ),
            if (!draft.status.isPending) ...[
              section('Valoración', hint: 'Opcional'),
              RatingCircles(rating: draft.rating, onChanged: onRatingChanged),
            ],
            section('Nota privada', hint: 'Solo tú puedes leerla'),
            TextField(
              controller: noteController,
              onChanged: (_) => onTextChanged(),
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              style: tokens.text.body,
              decoration: const InputDecoration(
                hintText: '¿Qué quieres recordar de este lugar?',
              ),
            ),
            section(
              'Fotos',
              hint: '${draft.photos.length}/$maxPhotos · opcional',
            ),
            MockPhotoPicker(
              library: library,
              selected: draft.photos,
              onToggle: onTogglePhoto,
              onCamera: onOpenCamera,
            ),
            section('Colecciones', hint: 'Opcional'),
            Wrap(
              spacing: s.sm,
              runSpacing: s.sm,
              children: [
                for (final board in boards)
                  TagChip(
                    label: board.title,
                    selected: draft.boardIds.contains(board.id),
                    onTap: () => onToggleBoard(board.id),
                  ),
              ],
            ),
            SizedBox(height: s.xxl),
            PrimaryButton(
              label: isEditing ? 'Guardar cambios' : 'Guardar',
              icon: WanderIcons.check,
              onPressed: draft.canSave ? onSave : null,
            ),
            if (!draft.canSave) ...[
              SizedBox(height: s.sm),
              Text(
                'Agrega el nombre del lugar para guardar.',
                textAlign: TextAlign.center,
                style: tokens.text.caption.copyWith(color: c.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
