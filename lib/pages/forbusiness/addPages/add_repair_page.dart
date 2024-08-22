import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/repair_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/repair_state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:teklif/model/events/repair_events/add_repair_event.dart';

class AddRepairPage extends StatefulWidget {
  @override
  _AddRepairPageState createState() => _AddRepairPageState();
}

class _AddRepairPageState extends State<AddRepairPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _repairNameController = TextEditingController();
  final TextEditingController _repairDescriptionController = TextEditingController();
  final TextEditingController _repairDurationController = TextEditingController();
  final TextEditingController _repairPriceController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceModelController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _problemDescriptionController = TextEditingController();
  String? _repairStatus;
  bool _warrantyStatus = false;
  String selectedUnit = 'TL';
  DateTime? _selectedDate;
  TextEditingController _repairDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Intl yerel ayarları Türkçe olarak ayarla
   initializeDateFormatting('tr_TR', null);
  }

  @override
  void dispose() {
    _repairNameController.dispose();
    _repairDescriptionController.dispose();
    _repairDurationController.dispose();
    _repairPriceController.dispose();
    _deviceNameController.dispose();
    _deviceModelController.dispose();
    _serialNumberController.dispose();
    _problemDescriptionController.dispose();
    _repairDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<RepairBloc, RepairState>(
        listener: (context, state) {
          if (state is RepairLoading) {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else if (state is RepairSuccess) {
            if (mounted) {
              Navigator.pop(context);
              MySuccessSnackbar.show(context, 'Tamir başarıyla eklendi');

              _formKey.currentState!.reset();
              _repairNameController.clear();
              _repairDescriptionController.clear();
              _repairDurationController.clear();
              _repairPriceController.clear();
              _deviceNameController.clear();
              _deviceModelController.clear();
              _serialNumberController.clear();
              _problemDescriptionController.clear();
              setState(() {
                _repairStatus = null;
                _warrantyStatus = false;
              });

              Future.delayed(Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pop(context); // Close the page
                  Navigator.pop(context);
                }
              });
            }
          } else if (state is RepairFailure) {
            if (mounted) {
              Navigator.pop(context); // Close loading indicator
            }
            MyFailureSnackbar.show(context, 'Hata: ${state.error}');
          } else if (state is  RepairAuthFailure && state.authError) {
            if (mounted) {
              Navigator.pop(context); // Close loading indicator
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          }
        },
        child: Scaffold(
          body: Stack(
             children: [

               Padding(
                 padding: EdgeInsets.all(Dimension.getWidth20(context)),
                 child: Form(
                   key: _formKey,
                   child: SingleChildScrollView(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: Dimension.getHeight10(context)*9),
                         Text(
                           'Tamir Ekle',
                           style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: Colors.orange,
                           ),
                         ),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Tamir Adı',
                           controller: _repairNameController,
                           icon: Icons.build,
                         ),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Tamir Açıklaması',
                           controller: _repairDescriptionController,
                           icon: Icons.description,
                         ),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Tamir Süresi (gün)',
                           controller: _repairDurationController,
                           keyboardType: TextInputType.number,
                           icon: Icons.timer,
                         ),
                         SizedBox(height: 16),
                         _buildPriceField(label: 'Tamir Fiyatı',
                             controller: _repairPriceController),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Cihaz Adı',
                           controller: _deviceNameController,
                           icon: Icons.devices,
                         ),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Cihaz Modeli',
                           controller: _deviceModelController,
                           icon: Icons.devices_other,
                         ),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Seri Numarası',
                           controller: _serialNumberController,
                           icon: Icons.confirmation_number,
                         ),
                         SizedBox(height: 16),
                         _buildTextField(
                           label: 'Problem Açıklaması',
                           controller: _problemDescriptionController,
                           icon: Icons.report_problem,
                         ),
                         SizedBox(height: 16),
                         _buildDropdown(
                           label: 'Tamir Durumu',
                           value: _repairStatus,
                           items: [
                             'Beklemede',
                             'Tamir Ediliyor',
                             'Tamir Tamamlandı',
                           ],
                           onChanged: (value) {
                             setState(() {
                               _repairStatus = value;
                             });
                           },
                         ),
                         SizedBox(height: 16),
                         SwitchListTile(
                           title: Text('Garanti Durumu'),
                           value: _warrantyStatus,
                           onChanged: (value) {
                             setState(() {
                               _warrantyStatus = value;
                             });
                           },
                         ),
                         SizedBox(height: 32),

                         Container(
                           margin: EdgeInsets.all(Dimension.getHeight10(
                               context)), // İstenilen margin değerleri
                           decoration: BoxDecoration(
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.grey.withOpacity(0.5),
                                 spreadRadius: 1,
                                 blurRadius: 8,
                                 offset: Offset(0,
                                     2), // gölgenin yönü, x ve y olarak ayarlanabilir
                               ),
                             ],
                           ),
                           child: TextFormField(
                             readOnly: true, // Metnin tıklanabilir olmasını sağlar
                             onTap: () => _selectDate(context),
                             decoration: InputDecoration(
                               labelText: 'Tamir Tarihi',
                               prefixIcon: Padding(
                                 padding: EdgeInsets.only(
                                     left: Dimension.getWidth10(context),
                                     right: Dimension.getWidth10(context)),
                                 child: Icon(Icons.date_range_rounded,
                                     color: Colors.orange),
                               ),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(15.0),
                               ),
                               filled: true,
                               fillColor: Colors.white,
                               contentPadding: EdgeInsets.symmetric(
                                   vertical: 15.0, horizontal: 20.0),
                               enabledBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(15.0),
                                 borderSide: BorderSide(color: Colors.transparent),
                               ),
                               focusedBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(15.0),
                                 borderSide: BorderSide(color: Colors.orange),
                               ),
                             ),
                             controller: TextEditingController(
                               text: _selectedDate != null
                                   ? DateFormat('MM-dd-yyyy','tr_TR').format(_selectedDate!)
                                   : '',
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
               Positioned(
                  top: 0,
                 left: 0,
                 right: 0,
                 child: Container(
                   padding: EdgeInsets.all(Dimension.getWidth15(context)),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     boxShadow: [
                       BoxShadow(
                         spreadRadius: 2,
                         color: Colors.grey,
                         blurRadius: 3,
                       )
                     ],
                   ),
                   child: SafeArea(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         CancelButton(
                           onPressed: () {
                             Navigator.pop(context);
                           },
                           text: 'İptal',
                           icon: Icons.close,
                           textColor: Colors.black,
                         ),
                         SaveButton(
                           onPressed: _submitForm,
                           text: 'Kaydet',
                           icon: Icons.check,
                           textColor: Colors.black,
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ],
           ),
        ),
      );

  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? icon,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.all(Dimension.getWidth10(context) / 5),
      margin: EdgeInsets.all(Dimension.getHeight10(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffixIcon,
          prefixIconColor: Colors.orange.shade300,
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
        ),
        validator: (value) {
          if ((label == 'Tamir Adı' || label == 'Cihaz Adı' || label =='Tamir Fiyatı'
          || label =='Cihaz Modeli') && (value == null || value.isEmpty)) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }




  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(Dimension.getWidth10(context) / 5),
      margin: EdgeInsets.all(Dimension.getHeight10(context) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.arrow_drop_down),
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
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,

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

      DateTime repairDate;
      if (_repairDateController.text.isNotEmpty) {
        repairDate = DateTime.parse(_repairDateController.text);
      } else {
        repairDate = DateTime.now();
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {


        BlocProvider.of<RepairBloc>(context).add(
          AddRepairEvent(
            repairName: _repairNameController.text,
            repairDescription: _repairDescriptionController.text,
            repairDuration: _repairDurationController.text??"",
            repairPrice:  double.parse(_repairPriceController.text),
            repairDate: _selectedDate??DateTime.now(), // Use _repairDateController.text as the date
            deviceName: _deviceNameController.text,
            deviceModel: _deviceModelController.text??"",
            serialNumber: _serialNumberController.text??"",
            problemDescription: _problemDescriptionController.text="",
            repairStatus: _repairStatus??"",
            warrantyStatus: _warrantyStatus,
            repairCurrency: selectedUnit
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }
}

