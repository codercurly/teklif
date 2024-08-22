import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:teklif/model/product_model.dart';

class CustomRow {
  final String itemName;
  final String itemPrice;
  final String amount;
  final String total;
  final String vat;

  CustomRow(this.itemName, this.itemPrice, this.amount, this.total, this.vat);
}

class PdfInvoiceService {
  Future<Uint8List> createInvoice(List<Product> soldProducts) async {
    final pdf = pw.Document();

    // Load the NotoSans font
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    final List<CustomRow> elements = [
      CustomRow("Item Name", "Item Price", "Amount", "Total", "Vat"),
      for (var product in soldProducts)
        CustomRow(
          product.name,
          product.price.toStringAsFixed(2),
          product.amount.toStringAsFixed(2),
          (product.price * product.amount).toStringAsFixed(2),
          (product.vatInPercent * product.price).toStringAsFixed(2),
        ),
      CustomRow(
        "Sub Total",
        "",
        "",
        "",
        "${getSubTotal(soldProducts)} EUR",
      ),
      CustomRow(
        "Vat Total",
        "",
        "",
        "",
        "${getVatTotal(soldProducts)} EUR",
      ),
      CustomRow(
        "Vat Total",
        "",
        "",
        "",
        "${(double.parse(getSubTotal(soldProducts)) + double.parse(getVatTotal(soldProducts))).toStringAsFixed(2)} EUR",
      )
    ];

    final image = (await rootBundle.load("assets/logo.png"))
        .buffer
        .asUint8List();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Image(pw.MemoryImage(image),
                  width: 150, height: 150, fit: pw.BoxFit.cover),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text("Customer Name", style: pw.TextStyle(font: font)),
                      pw.Text("Customer Address", style: pw.TextStyle(font: font)),
                      pw.Text("Customer City", style: pw.TextStyle(font: font)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text("Max Weber", style: pw.TextStyle(font: font)),
                      pw.Text("Weird Street Name 1", style: pw.TextStyle(font: font)),
                      pw.Text("77662 Not my City", style: pw.TextStyle(font: font)),
                      pw.Text("Vat-id: 123456", style: pw.TextStyle(font: font)),
                      pw.Text("Invoice-Nr: 00001", style: pw.TextStyle(font: font)),
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text(
                  "Dear Customer, thanks for buying at Flutter Explained, feel free to see the list of items below.",
                  style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 25),
              itemColumn(elements, font),
              pw.SizedBox(height: 25),
              pw.Text("Thanks for your trust, and till the next time.",
                  style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 25),
              pw.Text("Kind regards,", style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 25),
              pw.Text("Max Weber", style: pw.TextStyle(font: font))
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Expanded itemColumn(List<CustomRow> elements, pw.Font font) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          for (var element in elements)
            pw.Row(
              children: [
                pw.Expanded(
                    child: pw.Text(element.itemName,
                        textAlign: pw.TextAlign.left, style: pw.TextStyle(font: font))),
                pw.Expanded(
                    child: pw.Text(element.itemPrice,
                        textAlign: pw.TextAlign.right, style: pw.TextStyle(font: font))),
                pw.Expanded(
                    child: pw.Text(element.amount,
                        textAlign: pw.TextAlign.right, style: pw.TextStyle(font: font))),
                pw.Expanded(
                    child: pw.Text(element.total,
                        textAlign: pw.TextAlign.right, style: pw.TextStyle(font: font))),
                pw.Expanded(
                    child: pw.Text(element.vat,
                        textAlign: pw.TextAlign.right, style: pw.TextStyle(font: font))),
              ],
            )
        ],
      ),
    );
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
   // await OpenDocument.openDocument(filePath: filePath);
  }

  String getSubTotal(List<Product> products) {
    return products
        .fold(0.0,
            (double prev, element) => prev + (element.amount * element.price))
        .toStringAsFixed(2);
  }

  String getVatTotal(List<Product> products) {
    return products
        .fold(
      0.0,
          (double prev, next) =>
      prev + ((next.price / 100 * next.vatInPercent) * next.amount),
    )
        .toStringAsFixed(2);
  }
}
