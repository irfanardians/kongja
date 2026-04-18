import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewComposerResult {
  const ReviewComposerResult({
    required this.rating,
    required this.comment,
    this.attachmentPath,
  });

  final int rating;
  final String comment;
  final String? attachmentPath;
}

Future<ReviewComposerResult?> showReviewComposerSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String targetName,
  required String targetAvatar,
  required String sessionLabel,
  String confirmLabel = 'Confirm Review',
}) {
  return showModalBottomSheet<ReviewComposerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReviewComposerSheet(
      title: title,
      subtitle: subtitle,
      targetName: targetName,
      targetAvatar: targetAvatar,
      sessionLabel: sessionLabel,
      confirmLabel: confirmLabel,
    ),
  );
}

class _ReviewComposerSheet extends StatefulWidget {
  const _ReviewComposerSheet({
    required this.title,
    required this.subtitle,
    required this.targetName,
    required this.targetAvatar,
    required this.sessionLabel,
    required this.confirmLabel,
  });

  final String title;
  final String subtitle;
  final String targetName;
  final String targetAvatar;
  final String sessionLabel;
  final String confirmLabel;

  @override
  State<_ReviewComposerSheet> createState() => _ReviewComposerSheetState();
}

class _ReviewComposerSheetState extends State<_ReviewComposerSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _rating = 0;
  String? _attachmentPath;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF1E3),
                    child: Icon(Icons.photo_library_rounded),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select a review photo from gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF1E3),
                    child: Icon(Icons.photo_camera_rounded),
                  ),
                  title: const Text('Take with Camera'),
                  subtitle: const Text('Capture a new photo now'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final file = await _imagePicker.pickImage(source: source, imageQuality: 88);
    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _attachmentPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _rating > 0 && _commentController.text.trim().isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.72,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8CCC0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF241B15),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(color: Color(0xFF887F79)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(widget.targetAvatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.targetName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.sessionLabel,
                            style: const TextStyle(
                              color: Color(0xFF8B837D),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Star Rating',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(
                  5,
                  (index) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 44),
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      Icons.star_rounded,
                      size: 36,
                      color: index < _rating
                          ? const Color(0xFFF1B62D)
                          : const Color(0xFFE1D8CF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Share your experience, what went well, and any helpful notes.',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE8DDD1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE8DDD1)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add Photo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_attachmentPath != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8DDD1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_attachmentPath!),
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Photo attached to your review.',
                          style: TextStyle(
                            color: Color(0xFF5F5751),
                            height: 1.4,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _attachmentPath = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickAttachment,
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('Add from Gallery or Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C241F),
                    side: const BorderSide(color: Color(0xFFE8DDD1)),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: canSubmit
                    ? () {
                        Navigator.pop(
                          context,
                          ReviewComposerResult(
                            rating: _rating,
                            comment: _commentController.text.trim(),
                            attachmentPath: _attachmentPath,
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2B211C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD5CCC2),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(widget.confirmLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}
