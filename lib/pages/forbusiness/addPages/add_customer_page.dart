import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/customer_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/model/events/customer_events/add_customer_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/customer_state.dart';

class AddCustomerPage extends StatefulWidget {
  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNoController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerBusinessController = TextEditingController();
  final TextEditingController _customerMailController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAdresController = TextEditingController();
  final TextEditingController _customerNoteController = TextEditingController();
  File? _companyLogo;

  @override
  void dispose() {
    _customerNoController.dispose();
    _customerNameController.dispose();
    _customerBusinessController.dispose();
    _customerMailController.dispose();
    _customerPhoneController.dispose();
    _customerAdresController.dispose();
    _customerNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomersLoading) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
        else if (state is CustomersSuccess) {
          if (mounted) {
            Navigator.pop(context);
            MySuccessSnackbar.show(context, 'Müşteri başarıyla eklendi');

            _formKey.currentState!.reset();
            _customerNoController.clear();
            _customerNameController.clear();
            _customerBusinessController.clear();
            _customerMailController.clear();
            _customerPhoneController.clear();
            _customerAdresController.clear();
            _customerNoteController.clear();
            setState(() {
              _companyLogo = null;
            });

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context); // Close the page
              }
            });
          }
        }
        else if (state is CustomersFailure) {
          if (mounted) {
            Navigator.pop(context); // Close loading indicator
          }
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is CustomerAuthFailure && state.authError) {
          if (mounted) {
            Navigator.pop(context); // Close loading indicator
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(Dimension.getWidth20(context)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimension.getHeight10(context)*8.5),
                      const Text(
                        'Müşteri Ekle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Kodu',
                        controller: _customerNoController,
                        icon: Icons.numbers,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Adı-Soyadı',
                        controller: _customerNameController,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Firması',
                        controller: _customerBusinessController,
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Mail',
                        controller: _customerMailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Telefon',
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Adres',
                        controller: _customerAdresController,
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Not',
                        controller: _customerNoteController,
                        maxLines: 3,
                        icon: Icons.note,
                      ),
                      const SizedBox(height: 32),
                      _buildLogoPicker(),
                      const SizedBox(height: 32),
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
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(spreadRadius: 2,
                        color: Colors.grey,
                        blurRadius: 3)]
                ),
                child: Column(
                  children: [
                    SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CancelButton(
                            onPressed: (){Navigator.pop(context);},
                            text: 'iptal',
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
                  ],
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
          const BoxShadow(
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
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.orange),
          ),
        ),
        validator: (value) {
          if ((label == 'Müşteri Kodu' || label == 'Müşteri Adı') && (value == null || value.isEmpty)) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLogoPicker() {
    return Column(
      children: [
        const Text(
          'Şirket Logosu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: _pickCompanyLogo,
            child: CircleAvatar(
              radius: Dimension.getWidth10(context) * 4,
              backgroundColor: Colors.grey,
              backgroundImage: _companyLogo != null ?
              FileImage(_companyLogo!) : null,
              child: _companyLogo == null
                  ? Icon(
                Icons.add_a_photo,
                size: Dimension.getWidth30(context),
                color: Colors.orange.shade100,
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Prepare customer data and dispatch event
      BlocProvider.of<CustomerBloc>(context).add(
          SubmitCustomerEvent(
          customerNo: _customerNoController.text,
          customerName: _customerNameController.text,
            customerBusiness: _customerBusinessController.text.isNotEmpty
                ? _customerBusinessController.text
                : "",
            customerMail: _customerMailController.text.isNotEmpty
                ? _customerMailController.text
                : "",
            customerPhone: _customerPhoneController.text.isNotEmpty
                ? _customerPhoneController.text
                : "",
            companyLogo: _companyLogo != null ? _companyLogo!.path : '',
            customerAdres: _customerAdresController.text.isNotEmpty
                ? _customerAdresController.text
                : "",
            customerNote: _customerNoteController.text.isNotEmpty
                ? _customerNoteController.text
                : "",
          ),
      );
    }
  }

  Future<void> _pickCompanyLogo() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _companyLogo = File(pickedFile.path);
      });
    }
  }
}
