import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfSharer {
  Future<void> sharePdf() async {
    final outputFile = await _getOutputFile();
    final file = File(outputFile.path);

    if (await file.exists()) {
      Share.shareXFiles(
        [XFile(file.path)],
        text: 'PDF dosyasını paylaş',
      );
    } else {
      print('PDF dosyası bulunamadı');
    }
  }

  Future<File> _getOutputFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/output.pdf';
    return File(path);
  }
}
