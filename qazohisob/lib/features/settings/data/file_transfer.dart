import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utilities/date_utils.dart';

/// Writes export files and hands them to the iOS share sheet; picks backup
/// files for restore. Kept separate so the UI stays free of IO details.
class FileTransfer {
  const FileTransfer();

  Future<File> writeExport({
    required String content,
    required String extension,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final dir = await getTemporaryDirectory();
    final name =
        'qazohisob_${t.year}${two(t.month)}${two(t.day)}_'
        '${two(t.hour)}${two(t.minute)}.$extension';
    final file = File('${dir.path}/$name');
    // A BOM lets spreadsheet apps detect UTF-8 in CSV files.
    final data = extension == 'csv' ? '﻿$content' : content;
    return file.writeAsString(data, encoding: utf8, flush: true);
  }

  Future<void> share(BuildContext context, File file, String mimeType) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: 'QazoHisob ma’lumotlari',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  /// Returns the picked JSON file contents, or null if cancelled.
  Future<String?> pickBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (files.isEmpty) return null;
    final bytes = await files.first.readAsBytes();
    return utf8.decode(bytes, allowMalformed: false);
  }
}
