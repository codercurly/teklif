import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/product_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/model/events/product_events/add_product_event.dart';
import 'package:teklif/model/events/product_events/fetch_product_event.dart';
import 'package:teklif/model/events/product_events/imageupload_event.dart';
import 'package:teklif/model/events/product_events/update_product_event.dart';
import 'package:teklif/states/product_state.dart';

class UpdateProductPage extends StatefulWidget {
  final String productId;

  const UpdateProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<String> _images = [];
  List<String> currentimageslist = [];
  String selectedUnit = 'TL';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProductBloc>(context).add(FetchOneProductEvent(productId: widget.productId));
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Güncelle'),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is FetchProductSuccess) {
            setState(() {
              _productCodeController.text = state.productData[0]['productCode'];
              _productNameController.text = state.productData[0]['productName'];
              _quantityController.text = state.productData[0]['quantity'].toString();
              _priceController.text = state.productData[0]['price'].toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
              selectedUnit = state.productData[0]['priceUnit'];
              _images = List<String>.from(state.productData[0]['images']);
              currentimageslist = List<String>.from(state.productData[0]['images']);
            });

          } else if (state is FetchProductFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is UploadImageSuccess) {
            setState(() {
              _images.add(state.downloadUrl);
            });
          } else if (state is UploadImageFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Padding(
          padding: EdgeInsets.all(Dimension.getWidth15(context)),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    icon: Icons.numbers,
                    label: 'Ürün Kodu',
                    controller: _productCodeController,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    icon: Icons.production_quantity_limits,
                    label: 'Ürün Adı',
                    controller: _productNameController,
                  ),
                  SizedBox(height: 16),
                  _buildQuantityField(
                    label: 'Miktar',
                    controller: _quantityController,
                  ),
                  SizedBox(height: 16),
                  _buildPriceField(
                    label: 'Birim Fiyat',
                    controller: _priceController,
                  ),

                  SizedBox(height: 16),
                  Text(
                    "Resimlerinizi yükleyin",
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: Dimension.getFont18(context),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: Dimension.getFont20(context) * 9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimension.getRadius20(context)),
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 6,
                            offset: Offset(1, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.orange, width: Dimension.getWidth10(context) / 5),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: _images.isNotEmpty
                                  ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _images.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 3,
                                                blurRadius: 6,
                                                offset: Offset(1, 2),
                                              ),
                                            ],
                                          ),
                                          child:ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: _images[index].startsWith('http')
                                                ? Image.network(
                                              _images[index],
                                              fit: BoxFit.cover,
                                            )
                                                : Image.file(
                                              File(_images[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              _removeImage(index);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: Icon(
                                                Icons.cancel,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                                  : CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.add_a_photo),
                              ),
                            ),
                          ),
                          _images.isNotEmpty
                              ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.all(Dimension.getWidth10(context)),
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  child: Icon(Icons.add_a_photo),
                                ),
                              ),
                            ),
                          )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "En fazla 3 adet resim seçebilirsiniz",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed:(){ _submitForm();},
                      child: CustomText(
                        text: 'Güncelle',
                        color: Colors.white,
                        fontSize: Dimension.getFont18(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shadowColor: Colors.grey,
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    IconData? icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.all(Dimension.getWidth10(context) / 5),
      margin: EdgeInsets.all(Dimension.getHeight10(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          icon: icon != null ? Icon(icon) : null,
          iconColor: Colors.orange.shade300,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: Dimension.getHeight15(context), horizontal: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildQuantityField({
    required String label,
    required TextEditingController controller,
  }) {
    if (controller.text.isEmpty) {
      controller.text = '1';
    }

    return Container(
      padding: EdgeInsets.all(Dimension.getWidth10(context) / 5),
      margin: EdgeInsets.all(Dimension.getHeight10(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() {
              if (int.parse(controller.text) > 1) {
                controller.text = (int.parse(controller.text) - 1).toString();
              }
            }),
            icon: Icon(Icons.remove),
            iconSize: 30,
            color: Colors.orange,
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration(label, Icons.production_quantity_limits),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label boş bırakılamaz';
                }
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              controller.text = (int.parse(controller.text) + 1).toString();
            }),
            icon: Icon(Icons.add),
            iconSize: 30,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }


  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      icon: Icon(icon),
      iconColor: Colors.orange.shade300,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: Dimension.getHeight15(context), horizontal: 0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.orange),
      ),
    );
  }


  Widget _buildPriceField({
    required String label,
    required TextEditingController controller,
  }) {
    // Varsayılan birim ve birimler listesi

    List<String> _units = ['TL', 'USD', 'EUR', 'GBP'];

    return Container(
      padding: EdgeInsets.all(Dimension.getWidth10(context) / 5),
      margin: EdgeInsets.all(Dimension.getHeight10(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    vertical: Dimension.getHeight15(context), horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(Dimension.getRadius15(context)),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label boş bırakılamaz';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir fiyat girin';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: selectedUnit,
              items: _units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue!;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    vertical: Dimension.getHeight15(context), horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(Dimension.getRadius15(context)),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      BlocProvider.of<ProductBloc>(context).add(UploadImageEvent(imagePath: image.path));
    }
  }




  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print("Form geçerli, güncelleniyor");

      final String productCode = _productCodeController.text;
      final String productName = _productNameController.text;
      final int quantity = int.parse(_quantityController.text);
      final double price = double.parse(_priceController.text);

      print("ProductName: $productName");

      // _images listesinin URL formatında olduğundan emin olun
      final List<String> imageUrls = _images;

      // Bloc'a UpdateProductEvent ekle
      BlocProvider.of<ProductBloc>(context).add(UpdateProductEvent(
        currentImages: currentimageslist,
        productId: widget.productId,
        productCode: productCode,
        productName: productName,
        quantity: quantity,
        price: price,
        priceUnit: selectedUnit,
        newImages: imageUrls,
      ));
    } else {
      print("Form geçersiz");
    }
  }




}

