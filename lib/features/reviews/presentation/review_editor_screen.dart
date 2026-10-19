import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../core/navigation/routes.dart';
import '../../places/domain/place.dart';
import '../data/mock_photo_library.dart';
import '../domain/review_draft.dart';
import 'review_editor_view.dart';
import 'widgets/saved_drop_in_dialog.dart';

/// Container for Add / Edit review. Owns the draft; the view is stateless.
class ReviewEditorScreen extends StatefulWidget {
  const ReviewEditorScreen({super.key, this.placeId, this.initialBoardId});

  /// Set when editing an existing place.
  final String? placeId;

  /// Preselected board when adding from a board.
  final String? initialBoardId;

  @override
  State<ReviewEditorScreen> createState() => _ReviewEditorScreenState();
}

class _ReviewEditorScreenState extends State<ReviewEditorScreen> {
  static const maxPhotos = 4;

  late ReviewDraft _draft;
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _note = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final existing = widget.placeId == null
        ? null
        : AppScope.of(context).places.byId(widget.placeId!);
    _draft = existing != null
        ? ReviewDraft.fromPlace(existing)
        : ReviewDraft(rating: 4, boardIds: [?widget.initialBoardId]);
    _name.text = _draft.name;
    _city.text = _draft.city;
    _country.text = _draft.country;
    _note.text = _draft.note;
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _country.dispose();
    _note.dispose();
    super.dispose();
  }

  void _update(ReviewDraft draft) => setState(() => _draft = draft);

  void _syncText() {
    _update(
      _draft.copyWith(
        name: _name.text,
        city: _city.text,
        country: _country.text,
        note: _note.text,
      ),
    );
  }

  void _togglePhoto(PlacePhoto photo) {
    final photos = List.of(_draft.photos);
    final index = photos.indexWhere((p) => p.seed == photo.seed);
    if (index >= 0) {
      photos.removeAt(index);
    } else if (photos.length < maxPhotos) {
      photos.add(photo);
    }
    _update(_draft.copyWith(photos: photos));
  }

  void _toggleBoard(String boardId) {
    final ids = List.of(_draft.boardIds);
    ids.contains(boardId) ? ids.remove(boardId) : ids.add(boardId);
    _update(_draft.copyWith(boardIds: ids));
  }

  void _showMock(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    _syncText();
    if (!_draft.canSave || _saving) return;
    setState(() => _saving = true);

    final places = AppScope.of(context).places;
    final place = SaveReview(places)(_draft);
    // Edits return to the detail view; only new pins drop into a board grid.
    if (_draft.isEditing) places.takeJustSavedId();
    await showSavedDropIn(context, place);
    if (!mounted) return;

    if (_draft.isEditing) {
      context.pop();
    } else {
      context.pushReplacement(Routes.board(place.boardIds.first));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final library = [
      ..._draft.photos.where(
        (p) => !mockPhotoLibrary.any((m) => m.seed == p.seed),
      ),
      ...mockPhotoLibrary,
    ];

    return ReviewEditorView(
      isEditing: _draft.isEditing,
      draft: _draft,
      boards: scope.boards.all(),
      library: library,
      maxPhotos: maxPhotos,
      nameController: _name,
      cityController: _city,
      countryController: _country,
      noteController: _note,
      onTextChanged: _syncText,
      onTogglePhoto: _togglePhoto,
      onOpenCamera: () =>
          _showMock('The camera is not available in this mockup'),
      onRatingChanged: (rating) => _update(_draft.copyWith(rating: rating)),
      onToggleBoard: _toggleBoard,
      onClose: () => context.canPop() ? context.pop() : context.go(Routes.home),
      onSave: _saving ? null : _save,
    );
  }
}
