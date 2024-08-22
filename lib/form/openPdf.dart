import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfOpener {
  Future<void> openPdf() async {
    final outputFile = await _getOutputFile();
    final file = File(outputFile.path);

    final result = await OpenFile.open(file.path);

    if (result.type != ResultType.done) {
      print('Dosya açılırken hata oluştu: ${result.message}');
    }
  }

  Future<File> _getOutputFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/output.pdf';
    return File(path);
  }
}
