import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/customer_bloc.dart';
import 'package:teklif/components/app_table.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/label_container.dart';
import 'package:teklif/components/navbar_items.dart';
import 'package:teklif/model/events/customer_events/delete_customer_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_customer_page.dart';
import 'package:teklif/pages/forbusiness/updatePages/update_customer_page.dart';
import 'package:teklif/states/customer_state.dart';
import 'package:teklif/model/events/customer_events/fetch_customer_event.dart';
import 'package:teklif/states/product_state.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  User? currentUser;
  late CustomerBloc _customerBloc;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _customerBloc = BlocProvider.of<CustomerBloc>(context);
    _fetchCustomerData();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//_customerBloc.close();
  }

  void _fetchCustomerData() {
    _customerBloc.add(FetchCustomerEvent());
  }




    void _deleteCustomer(String customerId) {
    // Bloc'dan müşteri silme işlemi
    BlocProvider.of<CustomerBloc>(context).add(DeleteCustomerEvent(customerId: customerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomersFailure) {
            MyFailureSnackbar.show(context, state.error);
          } else if (state is DeleteCustomerSuccess) {
            MySuccessSnackbar.show(context, state.message);
          }
          else if (state is CustomerAuthFailure && state.authError) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          }
        },
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            if (state is FetchCustomersSuccess) {
              List<Map<String, dynamic>> customers = state.customerData;

              return Column(
                children: [
                  NavBarItems(label: "Müşteriler", buttonText: "Müşteri ekle", onButtonTap:
                      () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        AddCustomerPage()));
                  }),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CustomDataTable(
                            labels: [
                              'Müşteri No',
                              'Müşteri Adı',
                              'İş',
                              'E-posta',
                              'Telefon',
                              'Şirket Logosu',
                              'Adres',
                              'Not',
                              "İşlemler"
                            ],
                            rows: customers.map((customer) {
                              return {
                                'Müşteri Kodu': customer['customerNo'],
                                'Ad': customer['customerName'],
                                'İş': customer['customerBusiness'],
                                'Mail': customer['customerMail'],
                                'Tel': customer['customerPhone'],
                                'Logo': customer['companyLogo'],
                                'Adres': customer['customerAdres'],
                                'Not': customer['customerNote'],
                              };
                            }).toList(),
                            onEditPressed: (index) {
                              // Müşteri güncelleme sayfasına git
                              if(customers[index]['id'] != null) {
                                String customerId = customers[index]['id'];
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        UpdateCustomerPage(
                                            customerId: customerId)));
                              }
                         },
                            onDeletePressed: (index) {
                              if(customers[index]['id'] != null){

                                String customerId = customers[index]['id'];
                                print(customerId);

                                _deleteCustomer(customerId);
                              }


                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is CustomersLoading || state is CustomersInitial) {
              return Center(child: CircularProgressIndicator());
            } else {
              return      NavBarItems(label: "Müşteriler", buttonText: "Müşteri ekle", onButtonTap:
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    AddCustomerPage()));
              });
            }
          },
        ),
      ),
    );
  }
}
