import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore
import 'package:image_picker/image_picker.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/form/offer_form.dart';
import 'package:teklif/model/events/auth_event.dart';
import 'package:teklif/pages/forbusiness/manager_page.dart';
import 'package:teklif/states/auth_state.dart';
import 'package:teklif/animation/wave.dart';
import 'package:teklif/base/dimension.dart';

class RegisterPage extends StatefulWidget {
  final String role;

  const RegisterPage({Key? key, required this.role}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();

  File? selectedImageFile; // Path to the selected image

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        firebaseStorage: FirebaseStorage.instance,
        firebaseAuth: FirebaseAuth.instance, // Provide firebaseAuth instance
        firebaseFirestore: FirebaseFirestore.instance, // Provide firebaseFirestore instance
      ),
    child: BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
    if (state is AuthSuccess) {
    if (widget.role == 'Pazarlamacı-Satıcı') {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OfferForm(sector: 'Ürün',)),
    );
    } else{
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ManagerPage()),
    );
    }
    } else if (state is AuthFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.error)),
    );
    }
    },
      child: Scaffold(
        body: Stack(
          children: [
            // Sağ üst köşede dalgalı şekil
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade900,
                      Colors.orange.shade500,
                      Colors.orange.shade300
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(Dimension.getWidth15(context)),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(height: Dimension.getHeight10(context) * 10),
                    Text(
                      'Kayıt Ol',
                      style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Dimension.getHeight20(context)),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Adınız Soyadınız',
                      icon: Icons.person,
                    ),
                    SizedBox(height: Dimension.getHeight20(context)),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                    ),
                    SizedBox(height: Dimension.getHeight20(context)),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'Telefon',
                      icon: Icons.phone,
                    ),
                    SizedBox(height: Dimension.getHeight20(context)),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Şifre',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: Dimension.getHeight20(context)),
                    if (widget.role != 'Pazarlamacı-Satıcı' &&
                        widget.role != 'Pazarlamacı')
                      Column(
                        children: [
                          _buildTextField(
                            controller: _companyNameController,
                            hintText: 'Firma Adı',
                            icon: Icons.business,
                          ),
                          SizedBox(height: Dimension.getHeight20(context)),
                          _buildTextField(
                            controller: _companyAddressController,
                            hintText: 'Firma Adresi',
                            icon: Icons.location_on,
                          ),
                          SizedBox(height: Dimension.getHeight20(context)),

                          _buildCompanyLogoField(),
                        ],
                      ),
                    SizedBox(height: Dimension.getHeight20(context)),
                    GestureDetector(
                      onTap: _register,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade300,
                              Colors.orange.shade500,
                              Colors.orange.shade900
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
    )
    )));
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String hintText,
        required IconData icon,
        bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimension.getRadius30(context)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(Dimension.getWidth20(context) / 1.4),
          hintStyle: TextStyle(fontSize: Dimension.getFont18(context)),
        ),
        validator: (value) {
          if (hintText != 'Telefon' && (value == null || value.isEmpty)) {
            return 'Lütfen $hintText girin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCompanyLogoField() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: Dimension.getHeight10(context) * 8,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child:  CircleAvatar(
            radius: Dimension.getWidth10(context) * 3,
            backgroundColor: Colors.grey,
            backgroundImage: selectedImageFile != null ? FileImage(selectedImageFile!) : null,
            child: selectedImageFile == null
                ? Icon(
              Icons.add_a_photo,
              size: Dimension.getIconSize24(context),
              color: Colors.white,
            )
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImageFile = File(pickedFile.path);
      });
    }
  }
  void _register() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        RegisterEvent(
          image:  selectedImageFile != null ? selectedImageFile!.path: "",
          role: widget.role,
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone:_phoneController.text.isNotEmpty ? _phoneController.text:"",
          businessName: _companyNameController.text.isNotEmpty? _companyNameController.text:"",
          businessAddress: _companyAddressController.text.isNotEmpty ? _companyAddressController.text:"",
          // Ekstra özellikler buraya eklenebilir
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Lütfen tüm alanları doldurun ve geçerli bir email girin.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Kontrollerin temizlenmesi
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }
}
