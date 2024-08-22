import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/worker_bloc.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/model/events/workers_events/add_worker_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/worker_state.dart';


class AddWorkerPage extends StatefulWidget {
  @override
  _AddWorkerPageState createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workerNoController = TextEditingController();
  final TextEditingController _workerNameController = TextEditingController();
  final TextEditingController _workerMailController = TextEditingController();
  final TextEditingController _workerBusinessController = TextEditingController();
  final TextEditingController _workerPhoneController = TextEditingController();
  final TextEditingController _workerRoleController = TextEditingController();
  final TextEditingController _workNameController = TextEditingController();

  @override
  void dispose() {
    _workerNoController.dispose();
    _workerNameController.dispose();
    _workerMailController.dispose();
    _workerBusinessController.dispose();
    _workerPhoneController.dispose();
    _workerRoleController.dispose();
    _workNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkerBloc, WorkerState>(
      listener: (context, state) {
        if (state is WorkersLoading) {
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
        } else if (state is WorkersSuccess) {
          if (mounted) {
            _formKey.currentState!.reset();
            _workerNoController.clear();
            _workerNameController.clear();
            _workerMailController.clear();
            _workerBusinessController.clear();
            _workerPhoneController.clear();
            _workerRoleController.clear();
            _workNameController.clear();

            Navigator.pop(context);
            MySuccessSnackbar.show(context, 'Çalışan başarıyla eklendi');

            Future.delayed(Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context); // Close the page
              }
            });
          }
        } else if (state is WorkersFailure) {
          if (mounted) {
            Navigator.pop(context); // Close loading indicator
          }
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is WorkerAuthFailure && state.authError) {
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
                        'Çalışan Ekle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Kodu',
                        controller: _workerNoController,
                        icon: Icons.numbers,
                        isMandatory: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Adı-Soyadı',
                        controller: _workerNameController,
                        icon: Icons.person,
                        isMandatory: true,
                      ),
                      _buildTextField(
                        label: 'Görevi (sorumlu olduğu iş)',
                        controller: _workNameController,
                        icon: Icons.work,
                        isMandatory: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Mail',
                        controller: _workerMailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                        isMandatory: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan İşletmesi',
                        controller: _workerBusinessController,
                        icon: Icons.business,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Telefon',
                        controller: _workerPhoneController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                      ),
                      SizedBox(height: 16),
                      _buildRoleDropdown(
                        label: 'Çalışan Rolü',
                        controller: _workerRoleController,
                        icon: Icons.work_outline,
                        isMandatory: true,
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(Dimension.getWidth15(context)),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(spreadRadius: 2,
                        color: Colors.grey,
                        blurRadius: 3)
                    ]
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CancelButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
    bool isMandatory = false,
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
          if (isMandatory && (value == null || value.isEmpty)) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleDropdown({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool isMandatory = false,
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
      child:DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.orange.shade300) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: Dimension.getHeight15(context),
            horizontal: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
        items: [
          {'label': 'Yetki yok', 'icon': Icons.block, 'color': Colors.red},
          {'label': 'Teklif hazırlayıcı', 'icon': Icons.edit, 'color': Colors.blue},
          {'label': 'Yönetici', 'icon': Icons.admin_panel_settings, 'color': Colors.green}
        ].map((role) => DropdownMenuItem<String>(
          value: role['label'] as String,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    role['icon'] as IconData,
                    color: role['color'] as Color,
                  ),
                  SizedBox(width: 10), // İkon ile metin arasına boşluk eklemek için
                  Expanded(
                    child: Text(
                      role['label'] as String,
                      style: TextStyle(fontSize: Dimension.getFont18(context)),
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey,
                height: 1,
              ),
            ],
          ),
        )).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.text = value;
          }
        },
        validator: (value) {
          if (isMandatory && (value == null || value.isEmpty)) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
        isExpanded: true, // Sağa taşmayı önlemek için genişletiyoruz
        selectedItemBuilder: (BuildContext context) {
          return [
            'Yetki yok',
            'Teklif hazırlayıcı',
            'Yönetici'
          ].map<Widget>((String value) {
            return Text(
              value,
              style: TextStyle(fontSize: Dimension.getFont18(context)),
            );
          }).toList();
        },
      ),





    );

  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
// Prepare worker data and dispatch event
      BlocProvider.of<WorkerBloc>(context).add(
        SubmitWorkerEvent(
          workerNo: _workerNoController.text,
          workerName: _workerNameController.text,
          workerMail: _workerMailController.text,
          workName: _workNameController.text,
          workerBusiness: _workerBusinessController.text.isNotEmpty
              ? _workerBusinessController.text
              : "",
          workerPhone: _workerPhoneController.text.isNotEmpty
              ? _workerPhoneController.text
              : "",
          workerRole: _workerRoleController.text,
        ),
      );
    }
  }

}