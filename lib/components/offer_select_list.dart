import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/components/custom_text.dart';

class OfferSelectList extends StatefulWidget {
  final List<dynamic> items;
  final Function(int) onDelete;
  final Function(int, int) onQuantityChanged;
  final String nameKey;
  final String priceKey;
  final String unitPrice;

  OfferSelectList({
    required this.items,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.nameKey,
    required this.priceKey,
    required this.unitPrice,
  });

  @override
  _OfferSelectListState createState() => _OfferSelectListState();
}

class _OfferSelectListState extends State<OfferSelectList> {
  Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant OfferSelectList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _controllers.clear();
    for (int i = 0; i < widget.items.length; i++) {
      _controllers[i] = TextEditingController(
        text: '1',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(Dimension.getWidth10(context)),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return Container(
          margin: EdgeInsets.all(Dimension.getHeight10(context)/2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(Dimension.getWidth10(context)),
            leading: item['images'] != null && item['images'].isNotEmpty
                ? Image.network(
              item['images'][0],
              width: Dimension.getWidth30(context) * 1.2,
              height: Dimension.getHeight30(context) * 1.3,
              fit: BoxFit.cover,
            )
                : Container(
              width: Dimension.getWidth30(context) * 1.2,
              height: Dimension.getHeight30(context) * 1.3,
              color: Colors.grey.shade200,
              child: Icon(Icons.miscellaneous_services),
            ),
            title: CustomText(
              text: item[widget.nameKey] ?? '',
              fontSize: Dimension.getFont18(context),
            ),
            subtitle: CustomText(
              text: ((item[widget.priceKey]?.toString() ?? '0')).toString() +
                  (item[widget.unitPrice] != "0" ? " " + (item[widget.unitPrice] ?? '') : ''),
              fontSize: Dimension.getFont12(context),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                widget.onDelete(index);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
