import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utilities/date_utils.dart';

/// Shares export files (iOS share sheet; on the web the browser's share
/// sheet or a download) and picks backup files for restore. Kept separate
/// so the UI stays free of IO details.
class FileTransfer {
  const FileTransfer();

  static String fileName(String extension, DateTime t) =>
      'qazohisob_${t.year}${two(t.month)}${two(t.day)}_'
      '${two(t.hour)}${two(t.minute)}.$extension';

  /// UTF-8 bytes; CSV gets a BOM so spreadsheet apps detect the encoding.
  static Uint8List encode(String content, String extension) =>
      Uint8List.fromList(
        utf8.encode(extension == 'csv' ? '\uFEFF$content' : content),
      );

  Future<void> exportAndShare(
    BuildContext context, {
    required String content,
    required String extension,
    required String mimeType,
  }) async {
    final name = fileName(extension, DateTime.now());
    final bytes = encode(content, extension);
    final XFile file;
    if (kIsWeb) {
      file = XFile.fromData(bytes, name: name, mimeType: mimeType);
    } else {
      final dir = await getTemporaryDirectory();
      final f = await File('${dir.path}/$name')
          .writeAsBytes(bytes, flush: true);
      file = XFile(f.path, name: name, mimeType: mimeType);
    }
    if (!context.mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: [name],
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
    return utf8.decode(bytes);
  }
}
