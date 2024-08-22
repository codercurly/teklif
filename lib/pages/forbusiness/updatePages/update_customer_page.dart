import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/customer_bloc.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/model/events/customer_events/fetch_customer_event.dart';
import 'package:teklif/model/events/customer_events/update_customer_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/customer_state.dart';

class UpdateCustomerPage extends StatefulWidget {
  final String customerId; // Müşteri ID'si

  const UpdateCustomerPage({required this.customerId});

  @override
  _UpdateCustomerPageState createState() => _UpdateCustomerPageState();
}

class _UpdateCustomerPageState extends State<UpdateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNoController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerBusinessController = TextEditingController();
  final TextEditingController _customerMailController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAdresController = TextEditingController();
  final TextEditingController _customerNoteController = TextEditingController();
  String? _companyLogo="";
  File? currentLogoSend;
  File? _companyLogoSend;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  void _loadCustomerData() {
    // Müşteri bilgilerini yüklemek için gerekli event'i dispatch et
    BlocProvider.of<CustomerBloc>(context).add(FetchCustomerUpdateEvent(customerId: widget.customerId));
  }

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
        if (state is FetchCustomersLoading) {
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
        } else if (state is FetchOneCustomersSuccess) {
          Navigator.pop(context);
          setState(() {
            // Load the customer data into the form
            _customerNoController.text = (state.customerData[0]["customerNo"] ?? '').toString();
            _customerNameController.text = (state.customerData[0]["customerName"] ?? '').toString();
            _customerBusinessController.text = (state.customerData[0]["customerBusiness"] ?? '').toString();
            _customerMailController.text = (state.customerData[0]["customerMail"] ?? '').toString();
            _customerPhoneController.text = (state.customerData[0]["customerPhone"] ?? '').toString();
            _customerAdresController.text = (state.customerData[0]["customerAdres"] ?? '').toString();
            _customerNoteController.text = (state.customerData[0]["customerNote"] ?? '').toString();
            // If there is a logo, you need to handle it (e.g., display it)
            _companyLogo =
            state.customerData[0]["companyLogo"] != null ? state.customerData[0]["companyLogo"].toString() :
            _companyLogo= "";
            currentLogoSend = state.customerData[0]["companyLogo"] != null ? File(state.customerData[0]["companyLogo"].toString()) : null;
print("compo logo $_companyLogo" );
          });
        } else if (state is CustomersSuccess) {
          MySuccessSnackbar.show(context, 'Müşteri başarıyla güncellendi');
          Navigator.pop(context);
        } else if (state is CustomersFailure) {
          print(state.error);
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is CustomerAuthFailure && state.authError) {
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
                      Text(
                        'Müşteri Bilgilerini Güncelle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Kodu',
                        controller: _customerNoController,
                        icon: Icons.numbers,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Adı',
                        controller: _customerNameController,
                        icon: Icons.person,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Firması',
                        controller: _customerBusinessController,
                        icon: Icons.business,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Mail',
                        controller: _customerMailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Telefon',
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Adres',
                        controller: _customerAdresController,
                        icon: Icons.location_on,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Müşteri Not',
                        controller: _customerNoteController,
                        maxLines: 3,
                        icon: Icons.note,
                      ),
                      SizedBox(height: 32),
                      _buildLogoPicker(),
                      SizedBox(height: 32),
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
                padding: EdgeInsets.all(Dimension.getHeight10(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(spreadRadius: 2, color: Colors.grey, blurRadius: 3)],
                ),
                child: Column(
                  children: [
                    SizedBox(height: Dimension.getHeight10(context)),
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
                          SaveButton(
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
        Text(
          'Şirket Logosu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: _pickCompanyLogo,
            child: CircleAvatar(
              radius: Dimension.getWidth10(context) * 4,
              backgroundColor: Colors.grey,
              child: _companyLogoSend != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.file(
                  _companyLogoSend!,
                  width: Dimension.getWidth10(context) * 8,
                  height: Dimension.getWidth10(context) * 8,
                  fit: BoxFit.cover,
                ),
              )
                  : _companyLogo != ""
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  _companyLogo!,
                  width: Dimension.getWidth10(context) * 8,
                  height: Dimension.getWidth10(context) * 8,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.add_a_photo,
                size: Dimension.getWidth30(context),
                color: Colors.orange.shade100,
              ),
            ),
          ),
        ),
      ],
    );
  }



  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? companyLogoPath;

      // Eğer yeni bir logo seçildiyse dosya yolunu al
      if (_companyLogoSend != null) {
        companyLogoPath = _companyLogoSend!.path;
        print('Gönderilecek dosya yolu: $companyLogoPath');
      } else if (_companyLogo != null) {
        // Yeni logo seçilmediyse mevcut logonun URL'sini al
        companyLogoPath = _companyLogo;
        print('Gönderilecek logo URL: $companyLogoPath');
      }

      // Hazır müşteri verilerini güncelleme event'i dispatch et
      BlocProvider.of<CustomerBloc>(context).add(
        UpdateCustomerEvent(
          customerId: widget.customerId,
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
          companyLogo: companyLogoPath ?? "", // Dosya yolu veya URL gönder
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
        _companyLogoSend = File(pickedFile.path);
        print('Seçilen dosya yolu: ${_companyLogoSend!.path}');
      });
    } else {
      print('Dosya seçimi iptal edildi.');
    }
  }


}
