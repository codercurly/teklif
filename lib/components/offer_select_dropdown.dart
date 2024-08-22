import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/components/mysuccess_buton.dart';

class OfferSelectDropdown extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String?) onChanged;
  final String hintText;
  final void Function() onAddNewItem;

  OfferSelectDropdown({
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.hintText,
    required this.onAddNewItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimension.getWidth10(context)),
      child: DropdownSearch<String>(
        dropdownButtonProps: DropdownButtonProps(
          padding: EdgeInsets.all(Dimension.getWidth10(context)),
          isVisible: true,
          icon: Icon(Icons.search, size: 16),
        ),
        popupProps: PopupProps.dialog(
          interceptCallBacks: true,
          title: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              hintText,
              style: TextStyle(
                fontFamily: "Kreon Light",
                fontSize: Dimension.getFont18(context),
              ),
            ),
          ),
          dialogProps: DialogProps(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          loadingBuilder: (context, item) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
                backgroundColor: Colors.greenAccent,
              ),
            );
          },
          searchFieldProps: TextFieldProps(
            cursorColor: Colors.blue,
          ),
          emptyBuilder: (context, searchEntry) => Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'Bulunamadı',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimension.getFont18(context),
                    ),
                  ),
                ),
                MySuccessButton(
                  onPressed: onAddNewItem,
                  text: "Yeni Ekle",
                  icon: Icons.add_box,
                ),
              ],
            ),
          ),
          showSelectedItems: true,
          showSearchBox: true,
        ),
        items: items,
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: TextStyle(fontSize: 18),
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.all(Dimension.getWidth10(context)),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: Dimension.getFont18(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimension.getRadius20(context)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimension.getRadius30(context)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimension.getRadius30(context)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        onChanged: onChanged,
        selectedItem: selectedItem,
      ),
    );
  }
}
