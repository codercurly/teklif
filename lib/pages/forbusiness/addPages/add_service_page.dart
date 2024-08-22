import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/service_bloc.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/model/events/services_events/add_service_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/repair_state.dart';
import 'package:teklif/states/service_state.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescriptionController = TextEditingController();
  final TextEditingController _serviceDurationController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();

  String selectedUnit = 'TL';
  String selectedType = 'Gün';


  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _serviceDurationController.dispose();
    _servicePriceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<ServiceBloc, ServiceState>(
      listener: (context, state) {
        if (state is RepairLoading) {
          // Eğer bir dialog zaten açıksa, tekrar açmaya çalışmıyoruz
          if (Navigator.canPop(context)) {
            return;
          }
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
        } else if (state is ServiceSuccess) {
          if (mounted) {
            Navigator.pop(context); // Close the loading dialog
            MySuccessSnackbar.show(context, 'Hizmet başarıyla eklendi');

            _formKey.currentState!.reset();

            _serviceNameController.clear();
            _serviceDescriptionController.clear();
            _serviceDurationController.clear();
            _servicePriceController.clear();

            Future.delayed(Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pop(context); // Close the service addition page
              }
            });
          }
        } else if (state is ServiceFailure) {
          if (mounted) {
            Navigator.pop(context); // Close the loading dialog
          }
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is ServiceAuthFailure && state.authError) {
          if (mounted) {
            Navigator.pop(context); // Close the loading dialog
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
                        'Hizmet Ekle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Hizmet Adı',
                        controller: _serviceNameController,
                        icon: Icons.build,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Hizmet Açıklaması',
                        controller: _serviceDescriptionController,
                        icon: Icons.description,
                      ),
                      SizedBox(height: 16),

                      _buildDurationField(
                        label: 'Hizmet Süresi',
                        controller: _serviceDurationController,
                      ),
                      SizedBox(height: 16),
                      _buildPriceField(label: 'Hizmet Fiyatı',
                          controller: _servicePriceController),
                      SizedBox(height: 16),


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
          if ((label == 'Hizmet Adı' || label =='Hizmet Fiyatı'
              || label =='Hizmet Süresi') && (value == null || value.isEmpty)) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }



  Widget _buildDurationField({
    required String label,
    required TextEditingController controller,
  }) {
    // Varsayılan birim ve birimler listesi

    List<String> _units = ['Gün', 'Ay', 'Yıl', 'Saat'];

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
          SizedBox(width: Dimension.getWidth10(context)),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                icon: const Icon(
                Icons.access_time,
                color: Colors.orange,
              ),

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
              value: selectedType,
              items: _units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
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
          SizedBox(width: Dimension.getWidth10(context)),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,

              decoration: InputDecoration(

                  icon: const Icon(
                    Icons.attach_money,
                    color: Colors.orange,
                  ),

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


      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {


        BlocProvider.of<ServiceBloc>(context).add(
          AddServiceEvent(
            serviceName: _serviceNameController.text,
            serviceDescription: _serviceDescriptionController.text??"",
            serviceDuration: _serviceDurationController.text,
            servicePrice: double.parse(_servicePriceController.text),
            unitPrice: selectedUnit,
            durationType: selectedType
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

