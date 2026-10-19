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
    required this.onToggleBoard,
    required this.onClose,
    required this.onSave,
  });

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

    final missing = <String>[
      if (draft.name.trim().isEmpty) 'a name',
      if (draft.photos.isEmpty) 'a photo',
      if (draft.boardIds.isEmpty) 'a board',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(WanderIcons.close),
          onPressed: onClose,
        ),
        title: Text(isEditing ? 'Edit review' : 'New place'),
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
            section(
              'Photos',
              hint: '${draft.photos.length}/$maxPhotos selected',
            ),
            MockPhotoPicker(
              library: library,
              selected: draft.photos,
              onToggle: onTogglePhoto,
              onCamera: onOpenCamera,
            ),
            section('The place'),
            TextField(
              controller: nameController,
              onChanged: (_) => onTextChanged(),
              textCapitalization: TextCapitalization.words,
              style: tokens.text.body,
              decoration: const InputDecoration(hintText: 'Place name'),
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
                    decoration: const InputDecoration(hintText: 'City'),
                  ),
                ),
                SizedBox(width: s.md),
                Expanded(
                  child: TextField(
                    controller: countryController,
                    onChanged: (_) => onTextChanged(),
                    textCapitalization: TextCapitalization.words,
                    style: tokens.text.body,
                    decoration: const InputDecoration(hintText: 'Country'),
                  ),
                ),
              ],
            ),
            section('How did it feel?'),
            RatingCircles(rating: draft.rating, onChanged: onRatingChanged),
            section('Private note', hint: 'Only you can read this'),
            TextField(
              controller: noteController,
              onChanged: (_) => onTextChanged(),
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              style: tokens.text.body,
              decoration: const InputDecoration(
                hintText: 'What do you want to remember about it?',
              ),
            ),
            section('Pin to boards'),
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
              label: isEditing ? 'Save changes' : 'Save to diary',
              icon: WanderIcons.check,
              onPressed: draft.canSave ? onSave : null,
            ),
            if (missing.isNotEmpty) ...[
              SizedBox(height: s.sm),
              Text(
                'Add ${missing.join(', ')} to save.',
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
