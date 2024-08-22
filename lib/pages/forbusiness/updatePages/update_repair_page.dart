import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/repair_bloc.dart';
import 'package:teklif/components/mycancel_buton.dart';
import 'package:teklif/components/save_buton.dart';
import 'package:teklif/model/events/repair_events/fetch_repair_event.dart';
import 'package:teklif/model/events/repair_events/update_repair_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/repair_state.dart';

class UpdateRepairPage extends StatefulWidget {
  final String repairUid; // Tamir ID'si

  const UpdateRepairPage({required this.repairUid});

  @override
  _UpdateRepairPageState createState() => _UpdateRepairPageState();
}

class _UpdateRepairPageState extends State<UpdateRepairPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _repairNameController = TextEditingController();
  final TextEditingController _repairDescriptionController = TextEditingController();
  final TextEditingController _repairDurationController = TextEditingController();
  final TextEditingController _repairPriceController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceModelController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _problemDescriptionController = TextEditingController();
  final TextEditingController _repairDateController = TextEditingController();
  bool _warrantyStatus = false; // Initial warranty status
  String _repairCurrency = '';
  String _repairStatus = '';
  String selectedUnit = 'TL';

  @override
  void initState() {
    super.initState();
    _loadRepairData();
  }

  void _loadRepairData() {
    // Tamir bilgilerini yüklemek için gerekli event'i dispatch et
    BlocProvider.of<RepairBloc>(context).add(FetchOneRepairEvent(repairId: widget.repairUid));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RepairBloc, RepairState>(
      listener: (context, state) {
        if (state is FetchRepairsLoading) {
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
        } else if (state is FetchOneRepairSuccess) {
          Navigator.pop(context); // Close loading indicator
          setState(() {
            // Load the repair data into the form
            _repairNameController.text = state.repairData[0]['repairName'] ?? '';
            _repairDescriptionController.text = state.repairData[0]['repairDescription'] ?? '';
            _repairDurationController.text = state.repairData[0]['repairDuration']?.toString() ?? '';
            _repairPriceController.text = state.repairData[0]['repairPrice']?.toString() ?? '';
            _deviceNameController.text = state.repairData[0]['deviceName'] ?? '';
            _deviceModelController.text = state.repairData[0]['deviceModel'] ?? '';
            _serialNumberController.text = state.repairData[0]['serialNumber'] ?? '';
            _problemDescriptionController.text = state.repairData[0]['problemDescription'] ?? '';
            _warrantyStatus = state.repairData[0]['warrantyStatus'] ?? '';
            _repairCurrency = state.repairData[0]['repairCurrency'] ?? '';
            _repairStatus = state.repairData[0]['repairStatus'] ?? '';
            selectedUnit = state.repairData[0]['repairCurrency'] ?? '';
          });
        } else if (state is RepairSuccess) {
          MySuccessSnackbar.show(context, 'Tamir başarıyla güncellendi');
          Navigator.pop(context);
        } else if (state is RepairFailure) {
          print(state.error);
          MyFailureSnackbar.show(context, 'Hata: ${state.error}');
        } else if (state is RepairAuthFailure && state.authError) {
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
                      SizedBox(height:Dimension.getHeight30(context)*3),
                      Text(
                        'Tamir Bilgilerini Güncelle',
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
                        maxLines: 3,
                        icon: Icons.description,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Tamir Süresi',
                        controller: _repairDurationController,
                        keyboardType: TextInputType.number,
                        icon: Icons.timer,
                      ),
                      SizedBox(height: 16),
                      _buildPriceField(label: "Tamir Ücreti",
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
                        icon: Icons.phone_android,
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
                        maxLines: 3,
                        icon: Icons.report_problem,
                      ),
                      SizedBox(height: 16),
                      _buildSwitch(initialValue: _warrantyStatus, onChanged: (value) {
                        setState(() {
                          _warrantyStatus = value;
                        });
                      }),
                      SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Tamir Durumu',
                        value: _repairStatus,
                        items: ['Başladı', 'Devam Ediyor', 'Tamamlandı'],
                        onChanged: (value) {
                          setState(() {
                            _repairStatus = value!;
                          });
                        },
                      ),
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


  Widget _buildSwitch({
    required bool initialValue,
    required void Function(bool) onChanged,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Garanti Durumu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: initialValue,
            onChanged: onChanged,
            activeColor: Colors.orange,
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


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? icon,
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
    prefixIconColor: Colors.orange,
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
    if ((label == 'Tamir Adı') && (value == null || value.isEmpty)) {
    return
      '$label boş bırakılamaz';
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
    // Ensure value is a valid item in items list or null
    if (value != null && !items.contains(value)) {
      value = null; // Reset value if it's not in items list
    }

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
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen bir tamir durumu seçin';
          }
          return null;
        },
      ),
    );
  }



  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Hazır tamir verilerini güncelleme event'i dispatch et
      BlocProvider.of<RepairBloc>(context).add(
        UpdateRepairEvent(
          repairId: widget.repairUid,
          repairName: _repairNameController.text,
          repairDescription: _repairDescriptionController.text,
          repairDuration: _repairDurationController.text??"",
          repairPrice: double.parse(_repairPriceController.text),
          deviceName: _deviceNameController.text,
          deviceModel: _deviceModelController.text,
          serialNumber: _serialNumberController.text,
          problemDescription: _problemDescriptionController.text,
          warrantyStatus: _warrantyStatus,
          repairCurrency: selectedUnit,
          repairStatus: _repairStatus??"",
          repairDate: "",
        ),
      );
    }
  }
}
