import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class QualificationViewer {
  static Future<void> open(
    BuildContext context,
    String url,
  ) async {
    final extension = p.extension(url).toLowerCase();

    switch (extension) {
      case ".jpg":
      case ".jpeg":
      case ".png":
      case ".gif":
      case ".webp":
        _showImage(context, url);
        break;

      case ".pdf":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _PdfViewerScreen(
              pdfUrl: url,
            ),
          ),
        );
        break;

      case ".doc":
      case ".docx":
        await _openOfficeDocument(url);
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unsupported document type.",
            ),
          ),
        );
    }
  }

  static void _showImage(
    BuildContext context,
    String url,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Hero(
            tag: url,
            child: Image.network(
              url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _openOfficeDocument(
    String url,
  ) async {
    final directory =
        await getTemporaryDirectory();

    final filename = p.basename(url);

    final file = File(
      "${directory.path}/$filename",
    );

    await Dio().download(
      url,
      file.path,
    );

    await OpenFilex.open(file.path);
  }
}

class _PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const _PdfViewerScreen({
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Qualification"),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
      ),
    );
  }
}