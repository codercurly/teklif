import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/worker_bloc.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/model/events/workers_events/update_worker_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/worker_state.dart';

class UpdateWorkerPage extends StatefulWidget {
  final String workerId; // Çalışan ID'si

  UpdateWorkerPage({required this.workerId});

  @override
  _UpdateWorkerPageState createState() => _UpdateWorkerPageState();
}

class _UpdateWorkerPageState extends State<UpdateWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workerNoController = TextEditingController();
  final TextEditingController _workerNameController = TextEditingController();
  final TextEditingController _workerMailController = TextEditingController();
  final TextEditingController _workerBusinessController = TextEditingController();
  final TextEditingController _workerPhoneController = TextEditingController();
  final TextEditingController _workerRoleController = TextEditingController();
  final TextEditingController _workNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  void _loadWorkerData() {
    // Çalışan bilgilerini yüklemek için gerekli event'i dispatch et
    BlocProvider.of<WorkerBloc>(context).add(FetchWorkerUpdateEvent(workerId: widget.workerId));
  }

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
        if (state is FetchWorkersLoading) {
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
        } else if (state is FetchOneWorkerSuccess) {
          Navigator.pop(context);
          setState(() {
            // Load the worker data into the form
            _workerNoController.text = (state.workerData[0]["workerNo"] ?? '').toString();
            _workerNameController.text = (state.workerData[0]["workerName"] ?? '').toString();
            _workNameController.text = (state.workerData[0]["workName"] ?? '').toString();
            _workerMailController.text = (state.workerData[0]["workerMail"] ?? '').toString();
            _workerBusinessController.text = (state.workerData[0]["workerBusiness"] ?? '').toString();
            _workerPhoneController.text = (state.workerData[0]["workerPhone"] ?? '').toString();
            _workerRoleController.text = (state.workerData[0]["workerRole"] ?? '').toString();
          });
        } else if (state is WorkersSuccess) {
          MySuccessSnackbar.show(context, 'Çalışan başarıyla güncellendi');
          Navigator.pop(context);
        } else if (state is WorkersFailure) {
          print(state.error);
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is WorkerAuthFailure && state.authError) {
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
                        'Çalışan Bilgilerini Güncelle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Numarası',
                        controller: _workerNoController,
                        icon: Icons.numbers,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Adı',
                        controller: _workerNameController,
                        icon: Icons.person,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Görev adı',
                        controller: _workNameController,
                        icon: Icons.person,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Mail',
                        controller: _workerMailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Çalışan Firması',
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
                      _buildRoleDropdown(_workerRoleController.text),
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
                padding: EdgeInsets.all(Dimension.getWidth10(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(spreadRadius: 2, color: Colors.grey, blurRadius: 3)],
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
                        text: 'Güncelle',
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
          if ((label == 'Görev adı' || label == 'Çalışan Adı' || label == 'Çalışan Mail' || label == 'Çalışan Rolü') && (value == null || value.isEmpty)) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleDropdown(String defaultRole) {
    List<String> roles = ['Yetki yok', 'Teklif hazırlayıcı', 'Yönetici'];

    // Determine the initial value for the dropdown
    String selectedRole = roles.contains(defaultRole) ? defaultRole : roles.first;

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
        decoration: InputDecoration(
          labelText: 'Çalışan Rolü',
          prefixIcon: Icon(Icons.work),
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
        value: selectedRole,
        onChanged: (String? newValue) {
          setState(() {
            _workerRoleController.text = newValue!;
          });
        },
        items: roles
            .map((role) => DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        ))
            .toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Çalışan Rolü boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }




  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form geçerliyse, çalışan bilgilerini güncellemek için event dispatch et
      BlocProvider.of<WorkerBloc>(context).add(
        UpdateWorkerEvent(
          workerId: widget.workerId,
          workerNo: _workerNoController.text,
          workerName: _workerNameController.text,
          workerMail: _workerMailController.text,
          workerBusiness: _workerBusinessController.text??"",
          workerPhone: _workerPhoneController.text??"",
          workerRole: _workerRoleController.text,
          workName: _workNameController.text ??"",
        ),
      );
    }
  }
}
