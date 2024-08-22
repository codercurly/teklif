import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PdfCreator {
  final String companyName;
  final String authorizedPerson;
  final String address;
  final String phone;
  final String email;
  final String? logo;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> repairs;

  PdfCreator({
    required this.companyName,
    required this.authorizedPerson,
    required this.address,
    required this.phone,
    required this.email,
    this.logo,
    required this.products,
    required this.services,
    required this.repairs,
  });

  factory PdfCreator.fromForm(
      String companyName,
      String authorizedPerson,
      String address,
      String phone,
      String email,
      String logo,
      List<Map<String, dynamic>> products,
      List<Map<String, dynamic>> services,
      List<Map<String, dynamic>> repairs,
      ) {
    return PdfCreator(
      companyName: companyName,
      authorizedPerson: authorizedPerson,
      address: address,
      phone: phone,
      email: email,
      logo: logo,
      products: products,
      services: services,
      repairs: repairs,
    );
  }

  Future<Uint8List> _getImageFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Resim indirilemedi');
    }
  }

  Future<void> createPdf() async {
    final pdf = pw.Document();

    // Google Fonts kullanarak fontu yükleyin
    final pw.Font regularFont = await PdfGoogleFonts.robotoRegular(); // veya başka bir font
    final pw.Font boldFont = await PdfGoogleFonts.robotoBold(); // veya başka bir font

    // Font stilini oluşturun
    final regularTextStyle = pw.TextStyle(font: regularFont, fontSize: 18);
    final boldTextStyle = pw.TextStyle(font: boldFont, fontSize: 18);
    final headerText = pw.TextStyle(font: boldFont, fontSize: 19, color: PdfColors.orange);

    // Eğer logo URL'si varsa resmi indir
    pw.ImageProvider? logoImage;
    if (logo != null && logo!.isNotEmpty) {
      final Uint8List imageBytes = await _getImageFromUrl(logo!);
      logoImage = pw.MemoryImage(imageBytes);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null)
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Image(logoImage, width: 100, height: 100),
                  ),
                pw.Text('$companyName', style: headerText),
                pw.Text('Yetkili Kişi: $authorizedPerson', style: regularTextStyle),
                pw.Text('Adres: $address', style: regularTextStyle),
                pw.Text('Telefon: $phone', style: regularTextStyle),
                pw.Text('E-mail: $email', style: regularTextStyle),
                pw.SizedBox(height: 20),
                if (products.isNotEmpty) ...[
                  pw.Text('Ürün Bilgileri', style: boldTextStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  _buildProductTable(context, products, regularTextStyle),
                ],
                if (services.isNotEmpty) ...[
                  pw.Text('Hizmet Bilgileri', style: boldTextStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  _buildServiceTable(context, services, regularTextStyle),
                ],
                if (repairs.isNotEmpty) ...[
                  pw.Text('Tamir Bilgileri', style: boldTextStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  _buildRepairTable(context, repairs, regularTextStyle),
                ],
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/output.pdf";
    final file = File(filePath);
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    // PDF dosyasını aç
    await OpenFile.open(filePath);
  }

  static pw.Widget _buildProductTable(
      pw.Context context,
      List<Map<String, dynamic>> products,
      pw.TextStyle textStyle,
      ) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: <String>['Ürün Adı', 'Açıklama', 'Fiyat', 'Miktar', 'Toplam Fiyat'],
      data: products.map((product) {
        final productName = product['productName'] ?? '';
        final description = product['description'] ?? '';
        final price = product['price']?.toString() ?? '';
        final quantity = product['quantity']?.toString() ?? '';
        final totalPrice = (product['price'] != null && product['quantity'] != null)
            ? (product['price'] * product['quantity']).toString()
            : '';

        return [productName, description, price, quantity, totalPrice];
      }).toList(),
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      headerStyle: textStyle.copyWith(fontWeight: pw.FontWeight.bold),
      cellStyle: textStyle,
    );
  }

  static pw.Widget _buildServiceTable(
      pw.Context context,
      List<Map<String, dynamic>> services,
      pw.TextStyle textStyle,
      ) {
    return pw.Table.fromTextArray(
      context: context,
      headers: <String>['Hizmet Adı', 'Açıklama', 'Fiyat', 'Süre', 'Birim Fiyatı'],
      data: services.map((service) {
        String price = '${service['servicePrice']} ${service['unitPrice']}';
        price = price.replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
        final serviceName = service['serviceName'] ?? '';
        final description = service['serviceDescription'] ?? '';
       // final price = service['servicePrice']?.toString() ?? '' + service['unitPrice']?? '' ;
        final duration = service['serviceDuration'] ?? '';
        final unitPrice = service['unitPrice'] ?? '';

        return [serviceName, description, price, duration, unitPrice];
      }).toList(),
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      headerStyle: textStyle.copyWith(fontWeight: pw.FontWeight.bold),
      cellStyle: textStyle,
    );
  }

  static pw.Widget _buildRepairTable(
      pw.Context context,
      List<Map<String, dynamic>> repairs,
      pw.TextStyle textStyle,
      ) {
    return pw.Table.fromTextArray(
      context: context,
      headers: <String>[
        'Tamir Adı',
        'Açıklama',
        'Tamir Süresi',
        'Fiyat',
        'Tarih',
        'Para Birimi',
        'Cihaz Adı',
        'Cihaz Modeli',
        'Seri Numarası',
        'Sorun Açıklaması',
        'Garanti Durumu',

      ],
      data: repairs.map((repair) {
        final repairName = repair['repairName'] ?? '';
        final description = repair['repairDescription'] ?? '';
        final duration = repair['repairDuration'] ?? '';
        final price = repair['repairPrice']?.toString() ?? '';
        final date = repair['repairDate']?.toString() ?? '';
        final currency = repair['repairCurrency'] ?? '';
        final deviceName = repair['deviceName'] ?? '';
        final deviceModel = repair['deviceModel'] ?? '';
        final serialNumber = repair['serialNumber'] ?? '';
        final problemDescription = repair['problemDescription'] ?? '';
        final warrantyStatus = repair['warrantyStatus'] ? 'Evet' : 'Hayır';


        return [
          repairName,
          description,
          duration,
          price,
          date,
          currency,
          deviceName,
          deviceModel,
          serialNumber,
          problemDescription,
          warrantyStatus,

        ];
      }).toList(),
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      headerStyle: textStyle.copyWith(fontWeight: pw.FontWeight.bold),
      cellStyle: textStyle,
    );
  }
}
