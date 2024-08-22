import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';
import 'package:intl/intl.dart';
import 'package:teklif/bloc/business_bloc.dart';
import 'package:teklif/bloc/customer_bloc.dart';
import 'package:teklif/bloc/product_bloc.dart';
import 'package:teklif/bloc/repair_bloc.dart';
import 'package:teklif/bloc/service_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/offer_select_dropdown.dart';
import 'package:teklif/components/offer_select_list.dart';
import 'package:teklif/form/drawPdf.dart';
import 'package:teklif/form/openPdf.dart';
import 'package:teklif/form/sharePdf.dart';
import 'package:teklif/model/events/business_events/fetchUpdateB_event.dart';
import 'package:teklif/model/events/customer_events/fetch_customer_event.dart';
import 'package:teklif/model/events/product_events/fetch_product_event.dart';
import 'package:teklif/model/events/repair_events/fetch_repair_event.dart';
import 'package:teklif/model/events/services_events/fetch_service_event.dart';
import 'package:teklif/pages/forbusiness/addPages/add_customer_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_product_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_repair_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_service_page.dart';
import 'package:teklif/states/business_state.dart';
import 'package:teklif/states/customer_state.dart';
import 'package:teklif/states/product_state.dart';
import 'package:teklif/states/repair_state.dart';
import 'package:teklif/states/service_state.dart'; // Tarih formatlama için

import 'package:permission_handler/permission_handler.dart';

class OfferForm extends StatefulWidget {
  final String sector;
  const OfferForm({super.key, required this.sector});

  @override
  State<OfferForm> createState() => _OfferFormState();
}

class _OfferFormState extends State<OfferForm> {
  User? currentUser;
  String? currentUserId;

  List _customers = [];
  List _products = [];
  List _services = [];
  List _repairs = [];
  String? _selectedCustomer;
  String? _logobusiness;
  @override
  void initState() {
    super.initState();
    // Firebase Auth üzerinden mevcut kullanıcıyı al
    currentUser = FirebaseAuth.instance.currentUser;
    currentUserId = currentUser?.uid ?? '';
    if (currentUserId != null || currentUserId != "") {
      // İşletme bilgilerini çekme işlemini başlatmak için FetchBusinessUpdateEvent'i gönder
      BlocProvider.of<BusinessBloc>(context)
          .add(FetchBusinessUpdateEvent(userId: currentUserId!));
      // Müşteri verilerini çekme
      BlocProvider.of<CustomerBloc>(context).add(FetchCustomerEvent());
      BlocProvider.of<ProductBloc>(context).add(FetchProductEvent());
      BlocProvider.of<ServiceBloc>(context).add(FetchServicesEvent());
      BlocProvider.of<RepairBloc>(context).add(FetchRepairsEvent());
    }
  }

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _authorizedPersonController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _offerNumberController = TextEditingController();
  final TextEditingController _validityPeriodController =
      TextEditingController();
final TextEditingController _paymentMethodController =
      TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _deliveryLocationController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
 final TextEditingController _exchangeRateController = TextEditingController();

  DateTime? _selectedDate;

  final PdfOpener pdfOpener = PdfOpener();
  final PdfSharer pdfSharer = PdfSharer();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }



  Widget _buildExpansionTile(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(
          bottom: Dimension.getHeight20(context),
          left: Dimension.getWidth10(context),
          right: Dimension.getWidth10(context)),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15.0),
        // Üst border'ı kaldır
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15.0),

        elevation: 5.0, // Gölgelendirme ekleyelim
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: Colors.grey.shade100,
              title: Text(title),
              children: children,
              tilePadding:
                  EdgeInsets.only(left: Dimension.getHeight10(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText,
      {IconData? icon}) {
    return Container(
      margin: EdgeInsets.all(Dimension.getHeight15(context)),
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
        decoration: _buildInputDecoration(labelText, icon ?? Icons.description),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      icon: Icon(icon),
      iconColor: Colors.orange,
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

  List<Map<String, dynamic>> _selectedProducts = [];

  String? _selectedProduct;

  void _addProductToList() {
    print('Selected Product: $_selectedProduct');
    print(
        'Products: ${_products.map((product) => product['productName']).toList()}');

    final selectedProduct = _products.firstWhere(
      (product) {
        print(
            'Checking product: ${product['productName'].trim().toLowerCase()}');
        return '${product['productName'].trim().toLowerCase()}' ==
            _selectedProduct!.trim().toLowerCase();
      },
      orElse: () => <String, dynamic>{},
    );

    print('Matched Product: $selectedProduct');

    if (selectedProduct.isNotEmpty) {
      final alreadyAdded = _selectedProducts.any(
        (product) => product['productCode'] == selectedProduct['productCode'],
      );
      print("çalıştı");
      if (alreadyAdded) {
        // Ürün zaten listede, hata mesajı göster
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hata'),
            content: Text('Bu ürün zaten listede.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tamam'),
              ),
            ],
          ),
        );
      } else {
        // Ürünü listeye ekle
        setState(() {
          _selectedProducts.add({
            ...selectedProduct,
            'quantityController': TextEditingController(
                text: '1'), // Yeni TextEditingController ekle
          });
        });
        print("ekliyo");
      }
    }
  }

  List<Map<String, dynamic>> _selectedServices = [];

  String? _selectedService;

  void _addServiceToList() {
    print('Selected Service: $_selectedService');
    print(
        'Services: ${_services.map((service) => service['serviceName']).toList()}');

    final selectedService = _services.firstWhere(
          (service) {
        print(
            'Checking service: ${service['serviceName'].trim().toLowerCase()}');
        return '${service['serviceName'].trim().toLowerCase()}' ==
            _selectedService!.trim().toLowerCase();
      },
      orElse: () => <String, dynamic>{},
    );

    print('Matched Service: $selectedService');

    if (selectedService.isNotEmpty) {
      final alreadyAdded = _selectedServices.any(
            (service) => service['id'] == selectedService['id'],
      );

      if (alreadyAdded) {
        // Hizmet zaten listede, hata mesajı göster
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hata'),
            content: Text('Bu hizmet zaten listede.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tamam'),
              ),
            ],
          ),
        );
      } else {
        // Hizmeti listeye ekle
        setState(() {
          _selectedServices.add({
            ...selectedService,
            // Burada, diğer ek özellikleri veya alanları ekleyebilirsiniz
          });
        });
        print("Hizmet listeye eklendi");
      }
    }
  }

  List<Map<String, dynamic>> _selectedRepairs = [];

  String? _selectedRepair;

  void _addRepairToList() {
    print('Selected Repair: $_selectedRepair');
    print('Repairs: ${_repairs.map((repair) => repair['repairName']).toList()}');

    final selectedRepair = _repairs.firstWhere(
          (repair) {
        print('Checking repair: ${repair['repairName'].trim().toLowerCase()}');
        return '${repair['repairName'].trim().toLowerCase()}' ==
            _selectedRepair!.trim().toLowerCase();
      },
      orElse: () => <String, dynamic>{},
    );

    print('Matched Repair: $selectedRepair');

    if (selectedRepair.isNotEmpty) {
      final alreadyAdded = _selectedRepairs.any(
            (repair) => repair['repairCode'] == selectedRepair['repairCode'],
      );
      print("Çalıştı");
      if (alreadyAdded) {
        // Tamir zaten listede, hata mesajı göster
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hata'),
            content: Text('Bu tamir zaten listede.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tamam'),
              ),
            ],
          ),
        );
      } else {
        // Tamiri listeye ekle
        setState(() {
          _selectedRepairs.add({
            ...selectedRepair,
            'quantityController': TextEditingController(text: '1'), // Yeni TextEditingController ekle
          });
        });
        print("Ekleme işlemi tamamlandı");
      }
    }
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    if (statuses[Permission.storage]!.isGranted && statuses[Permission.manageExternalStorage]!.isGranted) {
      print('İzinler verildi');
    } else {
      print('İzinler verilmedi');
    }
  }
  Future<File> _getOutputFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/output.pdf';
    return File(path);
  }
  Future<void> openPdf() async {
    final outputFile = await _getOutputFile();
    final file = File(outputFile.path);

    final result = await OpenFile.open(file.path);

    if (result.type != ResultType.done) {
      print('Dosya açılırken hata oluştu: ${result.message}');
    }
  }


  @override
  void dispose() {
    // TextEditingController'ları temizle
    for (var product in _selectedProducts) {
      product['quantityController']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teklif Formu - ${widget.sector}')),
      body: Padding(
        padding: EdgeInsets.all(Dimension.getHeight10(context)),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BlocListener<BusinessBloc, BusinessState>(
                listener: (context, state) {
                  if (state is FetchBusinessesLoading) {
                    Center(child: CircularProgressIndicator());
                  } else if (state is FetchOneBusinessSuccess) {
                    // Firma bilgilerini güncelleyin
                    _logobusiness= state.businessData[0]["image"] ?? '';
                    _companyNameController.text =
                        state.businessData[0]["businessName"] ?? '';
                    _authorizedPersonController.text =
                        state.businessData[0]["name"] ?? '';
                    _addressController.text =
                        state.businessData[0]["businessAddress"] ?? '';
                    _phoneController.text =
                        state.businessData[0]["phone"] ?? '';
                    _emailController.text =
                        state.businessData[0]["email"] ?? '';
                  } else if (state is FetchBusinessFailure) {
                    Text(
                      'Hata: ${state.error}',
                      style: TextStyle(color: Colors.red),
                    );
                  } else {
                    // Varsayılan durum, eğer bir şey beklenmeyen bir hata olursa
                    Center(
                      child: Text(
                        'Beklenmeyen bir hata oluştu.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                },
                child: _buildExpansionTile(
                  'Hazırlayan Firma Bilgileri',
                  [
                    _buildTextFormField(_companyNameController, 'Firma Adı',
                        icon: Icons.business),
                    Container(
                      margin: EdgeInsets.all(Dimension.getHeight10(context)),
                      child: Row(
                        children: [
                          Text('Firma Logosu:'),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              Icons.upload_file,
                              color: Colors.orange,
                              size: Dimension.getIconSize31(context),
                            ),
                            onPressed: () {
                              // Logo yükleme işlemi burada yapılacak
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildTextFormField(_authorizedPersonController,
                        'Yetkili Kişinin Adı Soyadı',
                        icon: Icons.person),
                    _buildTextFormField(_addressController, 'Adres',
                        icon: Icons.place),
                    _buildTextFormField(_phoneController, 'Telefon',
                        icon: Icons.phone),
                    _buildTextFormField(_emailController, 'E-posta',
                        icon: Icons.mail),
                  ],
                ),
              ),
            BlocListener<CustomerBloc, CustomerState>(
              listener: (context, state) {
                if (state is FetchCustomersLoading) {
                  showDialog(
                    context: context,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );
                } else if (state is FetchCustomersSuccess) {
                  setState(() {
                    _customers = state.customerData ?? [];
                  });

                } else if (state is FetchCustomerFailure) {
                  Navigator.pop(context); // Dialog'u kapat
                  // Hata durumunu işleyin (kullanıcıya bildirin vs.)
                  print('Beklenmeyen durum: $state'); // Hata mesajını yazdır
                }
              },
              child: _buildExpansionTile(
                'Müşteri Bilgileri',
                [
                  OfferSelectDropdown(
                    items: _customers
                        .map((customer) => '${customer['customerBusiness']} - ${customer['customerName']}' as String)
                        .toList(),
                    selectedItem: _selectedCustomer ?? '',
                    onChanged: (selected) {
                      setState(() {
                        _selectedCustomer = selected;
                      });
                    },
                    hintText: "Müşteri seçin",
                    onAddNewItem: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddCustomerPage()),
                      );
                    },
                  ),
                  SizedBox(
                    height: Dimension.getHeight100(context) * 3,
                    child: OfferSelectList(
                      items: _customers
                          .where((customer) => '${customer['customerBusiness']} - ${customer['customerName']}' == _selectedCustomer)
                          .toList(),
                      onDelete: (index) {
                        setState(() {
                          _customers.removeAt(index); // Doğru elemanı kaldır
                          _selectedCustomer = null; // Seçilen müşteri sıfırla
                        });
                      },
                      onQuantityChanged: (index, quantity) {
                        // Müşteri verilerinde miktar yönetimi yoksa bu kısmı atlayabilirsiniz
                      },
                      nameKey: 'customerName', // Dinamik anahtarları doğru kullanın
                      priceKey: 'customerBusiness', // Dinamik anahtarları doğru kullanın
                      unitPrice: "0", // Eğer fiyat bilgisi yoksa bu kısmı atlayın
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: MySuccessButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddCustomerPage()),
                        );
                      },
                      text: "Yeni Müşteri",
                      icon: Icons.add_box,
                    ),
                  ),
                ],
              ),
            ),
            BlocListener<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state is FetchProductLoading) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is FetchProductSuccess) {
                    Navigator.pop(context); // Önceki dialog'u kapat
                    setState(() {
                      _products = state.productData ?? [];
                    });
                  } else if (state is FetchProductFailure) {
                    Navigator.pop(context); // Dialog'u kapat
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hata'),
                        content: Text(
                            'Ürünler yüklenirken bir hata oluştu: ${state.error}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pop(context); // Önceki dialog'u kapat
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hata'),
                        content: Text('Beklenmeyen bir hata oluştu.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: _buildExpansionTile(
                  'Ürün Bilgileri',
                  [
                    OfferSelectDropdown(
                      items: _products
                          .map((product) => product['productName'] as String)
                          .toList(),
                      selectedItem: _selectedProduct ?? '',
                      onChanged: (selected) {
                        setState(() {
                          _selectedProduct = selected;
                          _addProductToList();
                        });
                      },
                      hintText: "Ürün seçin",
                      onAddNewItem: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddProductPage()),
                        );
                      },
                    ),
                    SizedBox(
                      height: Dimension.getHeight100(context) * 3,
                      child: ListView.builder(
                        itemCount: _selectedProducts.length,
                        itemBuilder: (context, index) {
                          final product = _selectedProducts[index];
                          final controller = product['quantityController']
                              as TextEditingController;

                          return Container(

                            margin: EdgeInsets.all(Dimension.getHeight10(context)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  Dimension.getRadius15(context)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.all(Dimension.getWidth10(context)),
                              leading: product['images'] != null &&
                                      product['images'].isNotEmpty
                                  ? Image.network(
                                      product['images'][0],
                                      width:
                                          Dimension.getWidth30(context) * 1.2,
                                      height:
                                          Dimension.getHeight30(context) * 1.3,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width:
                                          Dimension.getWidth30(context) * 1.2,
                                      height:
                                          Dimension.getHeight30(context) * 1.3,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.image),
                                    ),
                              title: CustomText(
                                text: product['productName'] ?? '',
                                fontSize: Dimension.getFont18(context),
                              ),
                              subtitle: CustomText(
                                text: (product['price']?.toInt().toString() ??
                                        '0') +
                                    " " +
                                    (product['priceUnit'] ?? ''),
                                fontSize: Dimension.getFont12(context),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: Dimension.getIconSize16(context),
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      final quantity =
                                          int.tryParse(controller.text) ?? 1;
                                      if (quantity > 1) {
                                        setState(() {
                                          controller.text =
                                              (quantity - 1).toString();
                                        });
                                      }
                                    },
                                  ),
                                  Container(
                                    width: Dimension.getWidth30(context) * 1.5,
                                    height:
                                        Dimension.getHeight30(context) * 1.3,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimension.getRadius15(context)),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimension.getRadius15(context)),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimension.getRadius15(context)),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      onSubmitted: (value) {
                                        int? newQuantity = int.tryParse(value);
                                        if (newQuantity != null &&
                                            newQuantity > 0) {
                                          if (newQuantity >
                                              product['quantity']) {

                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Uyarı'),
                                                content: Text(
                                                    'En fazla ${product['quantity']} adet ürününüz var.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('Tamam'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              controller.text =
                                                  newQuantity.toString();
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: Dimension.getIconSize16(context),
                                    ),
                                    onPressed: () {
                                      final quantity =
                                          int.tryParse(controller.text) ?? 1;
                                      if (quantity < product['quantity']) {


                                        setState(() {
                                          controller.text =
                                              (quantity + 1).toString();
                                        });
                                      } else {

                                        print(product['quantity']);
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Uyarı'),
                                            content: Text(
                                                'En fazla ${product['quantity']} adet ürününüz var.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Tamam'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _selectedProducts.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: MySuccessButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddProductPage()),
                          );
                        },
                        text: "Yeni Ürün",
                        icon: Icons.add_box,
                      ),
                    ),
                  ],
                ),
              ),
              BlocListener<ServiceBloc, ServiceState>(
                listener: (context, state) {
                  if (state is FetchServicesLoading) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is FetchServicesSuccess) {
                    Navigator.pop(context); // Önceki dialog'u kapat
                    setState(() {
                      _services = state.serviceData ?? [];
                    });
                  } else if (state is FetchServiceFailure) {
                    Navigator.pop(context); // Dialog'u kapat
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hata'),
                        content: Text(
                            'Hizmetler yüklenirken bir hata oluştu: ${state.error}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pop(context); // Önceki dialog'u kapat
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hata'),
                        content: Text('Beklenmeyen bir hata oluştu.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: _buildExpansionTile(
                  'Hizmet Bilgileri',
                  [
                    OfferSelectDropdown(
                      items: _services
                          .map((service) => service['serviceName'] as String)
                          .toList(),
                      selectedItem: _selectedService ?? '',
                      onChanged: (selected) {
                        setState(() {
                          _selectedService = selected;
                          _addServiceToList();
                        });
                      },
                      hintText: "Hizmet seçin",
                      onAddNewItem: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddServicePage()),
                        );
                      },
                    ),
                    SizedBox(
                      height: Dimension.getHeight100(context) * 3,
                      child: ListView.builder(
                        itemCount: _selectedServices.length,
                        itemBuilder: (context, index) {
                          final service = _selectedServices[index];

                          return Container(
                            margin: EdgeInsets.all(Dimension.getHeight10(context)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  Dimension.getRadius15(context)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                              EdgeInsets.all(Dimension.getWidth10(context)),
                              leading: service['images'] != null &&
                                  service['images'].isNotEmpty
                                  ? Image.network(
                                service['images'][0],
                                width: Dimension.getWidth30(context) * 1.2,
                                height: Dimension.getHeight30(context) * 1.3,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: Dimension.getWidth30(context) * 1.2,
                                height: Dimension.getHeight30(context) * 1.3,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.image),
                              ),
                              title: CustomText(
                                text: service['serviceName'] ?? '',
                                fontSize: Dimension.getFont18(context),
                              ),
                              subtitle: CustomText(
                                text: (service['servicePrice']?.toInt().toString() ??
                                    '0') +
                                    " " +
                                    (service['unitPrice'] ?? ''),
                                fontSize: Dimension.getFont12(context),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedServices.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: MySuccessButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddServicePage()),
                          );
                        },
                        text: "Yeni Hizmet",
                        icon: Icons.add_box,
                      ),
                    ),
                  ],
                ),
              ),

              BlocListener<RepairBloc, RepairState>(
                listener: (context, state) {
                  if (state is FetchRepairsLoading) {
                    showDialog(
                      context: context,
                      builder: (context) => Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is FetchRepairsSuccess) {
                    Navigator.pop(context); // Önceki dialog'u kapat
                    setState(() {
                      _repairs = state.repairData ?? [];
                    });
                  } else if (state is FetchRepairFailure) {
                    Navigator.pop(context); // Dialog'u kapat
                    // Hata durumunu işleyin (kullanıcıya bildirin vs.)
                    print('Beklenmeyen durum: $state'); // Hata mesajını yazdır
                  }
                },
                child: _buildExpansionTile(
                  'Tamir Bilgileri',
                  [
                    OfferSelectDropdown(
                      items: _repairs.map((repair) => repair['repairName'] as String).toList(),
                      selectedItem: _selectedRepair ?? '',
                      onChanged: (selected) {
                        setState(() {
                          _selectedRepair = selected;
                        });
                      },
                      hintText: "Tamir seçin",
                      onAddNewItem: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddRepairPage()),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: _addRepairToList, // Tamir ekleme fonksiyonunu çağırır
                      child: Text("Listeye Ekle"),
                    ),
                    SizedBox(
                      height: Dimension.getHeight100(context) * 3,
                      child: OfferSelectList(
                        items: _selectedRepairs, // Seçilen tamirler listesi
                        onDelete: (index) {
                          setState(() {
                            _selectedRepairs.removeAt(index); // Doğru elemanı kaldır
                          });
                        },
                        onQuantityChanged: (index, quantity) {
                          setState(() {
                            _selectedRepairs[index]['quantityController'].text = quantity;
                          });
                        },
                        nameKey: 'repairName',
                        priceKey: 'repairPrice',
                        unitPrice: 'repairCurrency',
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: MySuccessButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddRepairPage()),
                          );
                        },
                        text: "Yeni Tamir",
                        icon: Icons.add_box,
                      ),
                    ),
                  ],
                ),
              ),

              _buildExpansionTile(
                'Teklif Bilgileri',
                [
                  _buildTextFormField(_offerNumberController, 'Teklif No',
                      icon: Icons.numbers),
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
                        labelText: 'Teklif Tarihi',
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
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : '',
                      ),
                    ),
                  ),
                  _buildTextFormField(
                      _validityPeriodController, 'Geçerlilik Süresi',
                      icon: Icons.timelapse),
                ],
              ),
              _buildExpansionTile(
                'Para Birimi ve Döviz Kuru',
                [
                  _buildTextFormField(_exchangeRateController, 'Döviz Kuru'),
                ],
              ),
              _buildExpansionTile(
                'Ödeme Bilgileri',
                [
                  _buildTextFormField(_paymentMethodController, 'Ödeme Şekli'),
                  _buildTextFormField(
                      _paymentTermsController, 'Ödeme Koşulları'),
                ],
              ),
              _buildExpansionTile(
                'Teslimat Bilgileri',
                [
                  _buildTextFormField(
                      _deliveryDateController, 'Teslimat Tarihi'),
                  _buildTextFormField(
                      _deliveryLocationController, 'Teslimat Yeri'),
                ],
              ),
              _buildExpansionTile(
                'Diğer Bilgiler',
                [
                  _buildTextFormField(_notesController, 'Notlar'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                 child: ElevatedButton(
                  onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
          // Form is valid, proceed with submission
          // PdfCreator sınıfını named constructor ile oluşturuyoruz
            print(_logobusiness);
          final pdfCreator = PdfCreator(
            logo: _logobusiness,
            services: _selectedServices,
          repairs: _selectedRepairs,
          companyName: _companyNameController.text,
          authorizedPerson: _authorizedPersonController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          products: _selectedProducts,
          );

          await pdfCreator.createPdf();

          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form başarıyla gönderildi')),
          );
          }
          },
            child: Text('Gönder'),
          ),


        ),
              ElevatedButton(
                onPressed: () async {
                  await requestPermissions();
                //  openPdf();
                 // await pdfOpener.openPdf();
                },
                child: Text('PDF Aç'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await pdfSharer.sharePdf();
                },
                child: Text('PDF Paylaş'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
