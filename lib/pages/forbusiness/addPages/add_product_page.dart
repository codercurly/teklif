import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/product_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/model/events/product_events/add_product_event.dart';
import 'package:teklif/states/product_state.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<File> _images = [];
  String selectedUnit = 'TL';
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
    return BlocListener<ProductBloc, ProductState>(listener: (context, state)

    {
      if (state is AddProductLoading) {
        // Loading durumunda bir spinner gösterebilirsiniz
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      } else if (state is AddProductSuccess) {
        Navigator.pop(context); // Loading spinner'ı kapat

        MySuccessSnackbar.show(context, 'Ürün başarıyla eklendi');

        _formKey.currentState!.reset();
        _productCodeController.clear();
        _productNameController.clear();
        _quantityController.clear();
        _priceController.clear();
        setState(() {
          _images.clear();
        });
        // Snackbar kapatıldıktan sonra sayfayı kapatma işlemi
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (state is AddProductFailure) {
        Navigator.pop(context); // Loading spinner'ı kapat

      MyFailureSnackbar.show(context, 'Hata: ${state.error}')  ;

      }
    },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange.shade500, Colors.orange.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('Ürün Ekle'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  // Diğer alanlar arasında kullanımı
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
                        fontSize: Dimension.getFont18(context)),
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: Dimension.getFont20(context) * 9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            Dimension.getRadius20(context)),
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 6,
                            offset: Offset(1, 2),
                          ),
                        ],
                        border: Border.all(
                            color: Colors.orange,
                            width: Dimension.getWidth10(context) / 5),
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
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  return Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                spreadRadius: 3,
                                                blurRadius: 6,
                                                offset: Offset(1, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            child: Image.file(
                                              _images[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
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
                              margin: EdgeInsets.all(
                                  Dimension.getWidth10(context)),
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
                      onPressed: _submitForm,
                      child: CustomText(
                        text: 'Kaydet',
                        color: Colors.white,
                        fontSize: Dimension.getFont18(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
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
        decoration: _buildInputDecoration(label, icon ?? Icons.description),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      icon: Icon(icon),
      iconColor: Colors.orange.shade300,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
          vertical: Dimension.getHeight15(context), horizontal: 0),
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

  Widget _buildQuantityField({
    required String label,
    required TextEditingController controller,
  }) {
    // Başlangıç değeri ayarlayın, eğer boşsa '1' yapın
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
            icon: Icon(Icons.remove, color: Colors.orange.shade300),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 1;
              if (currentValue > 1) {
                setState(() {
                  controller.text = (currentValue - 1).toString();
                });
              }
            },
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                label: Text("Miktar"),
                hintText: "miktar",
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    vertical: Dimension.getHeight15(context)),
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
                if (int.tryParse(value) == null || int.parse(value) < 1) {
                  return 'Geçerli bir miktar girin';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.orange.shade300),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 1;
              setState(() {
                controller.text = (currentValue + 1).toString();
              });
            },
          ),
        ],
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
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      List<String> imagePaths = _images.map((file) => file.path).toList();

      BlocProvider.of<ProductBloc>(context).add(
        SubmitProductEvent(
          productCode: _productCodeController.text,
          productName: _productNameController.text,
          quantity: int.parse(_quantityController.text),
          price: double.parse(_priceController.text),
          priceUnit: selectedUnit,
          images: imagePaths,
        ),
      );

    }
  }


  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("En fazla 3 adet resim seçebilirsiniz"),
        ),
      );
      return;
    }

    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    } else {
      print('No image selected.');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }
}
