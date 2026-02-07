import 'dart:convert';
import 'dart:io';
import 'package:noteapp/core/utils/exceptions.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  static Future<void> exportAsJSON(List<DiaryEntryModel> entries) async {
    try {
      final jsonList = entries.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'diary_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);
    } catch (e) {
      throw ExportException(
        message: 'Failed to export as JSON: $e',
        code: 'JSON_EXPORT_ERROR',
      );
    }
  }

  static Future<File> exportAsPDF(List<DiaryEntryModel> entries) async {
    try {
      final pdf = pw.Document();

      // Add title
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            children: [
              pw.Text(
                'Digital Diary Export',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Exported on ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // Add entries
      for (var entry in entries) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.title,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${entry.mood} - ${entry.createdAt}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 16),
                pw.Text(entry.body, style: pw.TextStyle(fontSize: 11)),
                if (entry.tags.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Wrap(
                    spacing: 5,
                    children: entry.tags
                        .map(
                          (tag) => pw.Container(
                            padding: pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(),
                            ),
                            child: pw.Text(
                              tag,
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'diary_export_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      throw ExportException(
        message: 'Failed to export as PDF: $e',
        code: 'PDF_EXPORT_ERROR',
      );
    }
  }
}
