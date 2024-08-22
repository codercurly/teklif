import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';

class CustomDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final List<String> labels;
  final void Function(int) onEditPressed;
  final void Function(int) onDeletePressed;

  const CustomDataTable({
    Key? key,
    required this.rows,
    required this.labels,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dinamik sütun başlıkları
    List<DataColumn> dataColumns = labels.map((label) => DataColumn(label: Text(label))).toList();

    // Dinamik veri satırları
    List<DataRow> dataRows = rows.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> data = entry.value;

      // Her sütun için farklı arka plan renkleri
      List<Color> colors = [
        Colors.orange.withOpacity(0.1),
        Colors.blue.withOpacity(0.1),
        Colors.green.withOpacity(0.1),
        Colors.red.withOpacity(0.1),
        Colors.grey.withOpacity(0.1),
      ];

      List<DataCell> cells = data.keys.map((key) {
        if (key == 'Logo') {
          return DataCell(
            Padding(
              padding: EdgeInsets.all(Dimension.getHeight10(context) / 2),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimension.getRadius15(context) / 2),
                  child: _buildLogoWidget(data[key], context),
                ),
              ),
            ),
          );
        } else if (key == 'images' && data[key] is List) {
          List<String> images = data[key] != null && (data[key] as List).isNotEmpty
              ? List<String>.from(data[key])
              : ['assets/default.png']; // Boşsa yerel asset resmi kullan
          return DataCell(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var imageUrl in images)
                    Padding(
                      padding: EdgeInsets.all(Dimension.getHeight10(context) / 2),
                      child: GestureDetector(
                        onTap: () => _showImagePopup(context, imageUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
                          child: imageUrl.startsWith('http') // Eğer URL ise networkten yükle
                              ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/default.png', // Varsayılan logo
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset( // Değilse yerel asset resmi kullan
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return DataCell(
          Container(
            color: colors[data.keys.toList().indexOf(key) % colors.length],
            child: key == 'image'
                ? _buildImageCell(data[key], context)
                : Text(
              data[key].toString(),
              style: TextStyle(fontSize: Dimension.getFont18(context)),
            ),
          ),
        );
      }).toList();

      // Düzenleme ve silme işlemleri için ikon butonları
      cells.add(DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEditPressed(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, index),
            ),
          ],
        ),
      ));

      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          border: const TableBorder(
            verticalInside: BorderSide(
              width: 1,
              style: BorderStyle.solid,
              color: Colors.white,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade200, // Tablo arka plan rengi
            borderRadius: BorderRadius.circular(15), // Köşe yuvarlama
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Gölgelendirme rengi
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Gölgelendirme ofset
              ),
            ],
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          headingTextStyle: TextStyle(
            fontSize: Dimension.getFont18(context),
            fontWeight: FontWeight.bold,
            color: Colors.white, // Başlık metin rengi
          ),
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              // Başlık satırı rengi, states durumuna göre değişebilir
              if (states.contains(MaterialState.hovered)) {
                return Colors.orange.withOpacity(0.8); // Fare üstüne gelindiğinde
              }
              return Colors.orange; // Normal durumda
            },
          ),
          columnSpacing: 18,
          columns: dataColumns,
          rows: dataRows,
        ),
      ),
    );
  }


  Widget _buildLogoWidget(String? imageUrl, BuildContext context) {
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/default.png', // Varsayılan logo
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ); // Hata durumunda varsayılan logo göster
        },
      );
    } else {
      return Image.asset(
        'assets/default.png', // Varsayılan logo
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildImageCell(String imageUrl, BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showImagePopup(context, imageUrl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
            child: imageUrl.startsWith('http') // Eğer URL ise networkten yükle
                ? Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            )
                : Image.asset( // Değilse yerel asset resmi kullan
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            child: InteractiveViewer(
              child: imageUrl.startsWith('http') // Eğer URL ise networkten yükle
                  ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
              )
                  : Image.asset( // Değilse yerel asset resmi kullan
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Silme Onayı"),
          content: Text("Bu öğeyi silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Sil"),
              onPressed: () {
                Navigator.of(context).pop();
                onDeletePressed(index);
              },
            ),
          ],
        );
      },
    );
  }
}
