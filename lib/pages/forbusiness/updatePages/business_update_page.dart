import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/business_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/model/events/business_events/fetchUpdateB_event.dart';
import 'package:teklif/model/events/business_events/update_business_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/business_state.dart';

class UpdateBusinessPage extends StatefulWidget {
  final String userId;

  const UpdateBusinessPage({super.key, required this.userId});
  @override
  _UpdateBusinessPageState createState() => _UpdateBusinessPageState();
}

class _UpdateBusinessPageState extends State<UpdateBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  String? _logo;
  File? _currentLogo;
  File? _newLogo;
  User? currentUser;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    // Firebase Auth üzerinden mevcut kullanıcıyı al
    currentUser = FirebaseAuth.instance.currentUser;
    currentUserId = currentUser?.uid ?? '';

    // Veri çekme işlemini başlatmak için fetch işlemini burada yapabilirsiniz
    BlocProvider.of<BusinessBloc>(context).add(FetchBusinessUpdateEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _businessNameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusinessBloc, BusinessState>(
      listener: (context, state) {
        if (state is FetchBusinessesLoading) {
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
        } else if (state is FetchOneBusinessSuccess) {

            Navigator.pop(context); // Close loading indicator
          setState(() {
            // Load the business data into the form
            _emailController.text = state.businessData[0]["email"]?.toString() ?? '';
            _businessNameController.text = state.businessData[0]["businessName"]?.toString() ?? '';
            _nameController.text = state.businessData[0]["name"]?.toString() ?? '';
            _phoneController.text = state.businessData[0]["phone"]?.toString() ?? '';
            _businessAddressController.text = state.businessData[0]["businessAddress"]?.toString() ?? '';
            _logo =  state.businessData[0]["image"];
            _currentLogo = state.businessData[0]["image"] != null ? File(state.businessData[0]["image"].toString()) : null;

            print("logo ulann ${_logo}");
          });
        } else if (state is BusinessSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close loading indicator
          }
          MySuccessSnackbar.show(context, 'İş bilgileri başarıyla güncellendi');
          Navigator.pop(context);
        } else if (state is BusinessFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close loading indicator
          }
          print(state.error);
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is BusinessAuthFailure && state.authError) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close loading indicator
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(Dimension.getWidth15(context).toDouble()),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(spreadRadius: 2, color: Colors.grey, blurRadius: 3)],
                ),
                child: Column(
                  children: [
                    SizedBox(height: Dimension.getHeight10(context).toDouble()),
                    SafeArea(
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
                          MySuccessButton(
                            onPressed: _submitForm,
                            text: 'Güncelle',
                            icon: Icons.check,
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimension.getWidth20(context).toDouble()),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İş Bilgilerini Güncelle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: Dimension.getHeight20(context)),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'İşletme Adı',
                        controller: _businessNameController,
                        icon: Icons.business,
                      ),
                      SizedBox(height: Dimension.getHeight20(context)),
                      _buildTextField(
                        label: 'Adı',
                        controller: _nameController,
                        icon: Icons.person,
                      ),
                      SizedBox(height: Dimension.getHeight20(context)),
                      _buildTextField(
                        label: 'Telefon',
                        controller: _phoneController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: Dimension.getHeight20(context)),
                      _buildTextField(
                        label: 'İş Adresi',
                        controller: _businessAddressController,
                        icon: Icons.location_on,
                      ),
                      SizedBox(height: Dimension.getHeight30(context)),
                      _buildLogoPicker(),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      padding: EdgeInsets.all(Dimension.getWidth10(context).toDouble() / 5),
      margin: EdgeInsets.all(Dimension.getHeight10(context).toDouble() / 2),
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
          suffixIcon: suffixIcon,
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label zorunlu bir alan';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLogoPicker() {
    return Center(
      child: Column(
        
        children: [

          SizedBox(height: Dimension.getHeight10(context)),
          GestureDetector(
            onTap: _pickLogo,
            child: Column(

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.grey,
                    ),
                    CustomText(text: "İşletme Logosu Seç",
                        color: Colors.grey,fontSize: Dimension.getFont18(context),),
                  ],
                ),
                SizedBox(height: Dimension.getHeight20(context)),
                Container(
                  width: Dimension.getWidth15(context).toDouble() * 8,
                  height: Dimension.getHeight10(context).toDouble() * 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimension.getRadius15(context).toDouble()),
                    color: Colors.grey[300],
                  ),
                  child: Center(
                    child: _newLogo != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.file(
                        _newLogo!,
                        width: Dimension.getWidth10(context).toDouble() * 8,
                        height: Dimension.getHeight10(context).toDouble() * 8,
                        fit: BoxFit.cover,
                      ),
                    )
                        : _logo != "" && _logo != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        _logo!,
                        width: Dimension.getWidth10(context).toDouble() * 8,
                        height: Dimension.getHeight10(context).toDouble() * 8,
                        fit: BoxFit.cover,
                      ),

                    )
                        : Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newLogo = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Burada güncelleme işlemi yapılır

      // İş verisini güncelleme olayını tetikleyin
      BlocProvider.of<BusinessBloc>(context).add(UpdateBusinessEvent(
        userId: widget.userId,
        email: _emailController.text,
        businessAddress: _businessAddressController.text,
        businessName: _businessNameController.text,
        logo: _newLogo != null ? _newLogo!.path : _logo!,
        name: _nameController.text,
        phone: _phoneController.text,
      ));
    }
  }
}
