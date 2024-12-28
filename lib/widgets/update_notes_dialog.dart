import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/widgets/update_note_item.dart';

class UpdateNotesDialog extends StatelessWidget {
  final String version;
  final String notes;

  const UpdateNotesDialog({
    super.key,
    required this.version,
    required this.notes,
  });

  List<String> _parseNotes() {
    return notes.split('•').where((note) => note.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notesList = _parseNotes();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Constants.responsiveSpacing(context, 20),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الجديد؟',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Constants.responsiveFontSize(context, 24),
                          ),
                    ),
                    Text(
                      'النسخة $version',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: Constants.responsiveFontSize(context, 14),
                          ),
                    ),
                  ],
                ),
                SizedBox(width: Constants.responsiveSpacing(context, 12)),
                Container(
                  padding: EdgeInsets.all(Constants.responsiveSpacing(context, 8)),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.new_releases,
                    color: Colors.green,
                    size: Constants.responsiveSpacing(context, 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: Constants.responsiveSpacing(context, 20)),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: notesList
                      .map((note) => UpdateNoteItem(note: note.trim()))
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: Constants.responsiveSpacing(context, 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: Constants.responsiveSpacing(context, 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Constants.responsiveSpacing(context, 12),
                    ),
                  ),
                ),
                child: Text(
                  'تمام يغالي عاش هجربهم',
                  style: TextStyle(
                    fontSize: Constants.responsiveFontSize(context, 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
