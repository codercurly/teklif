import 'package:pdf/widgets.dart' as pw;

class PdfFonts {
  final pw.Font font;
  final String text;
  final bool isBold;

  PdfFonts({required this.font, required this.text, this.isBold = false});

  pw.TextStyle get textStyle {
    return pw.TextStyle(
      font: font,
      fontSize: 18,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
  }

  pw.Widget buildText() {
    return pw.Text(text, style: textStyle);
  }
}
