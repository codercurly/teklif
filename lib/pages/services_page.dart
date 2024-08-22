import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/service_bloc.dart';
import 'package:teklif/components/app_table.dart';
import 'package:teklif/components/navbar_items.dart';
import 'package:teklif/model/events/services_events/delete_service_event.dart';
import 'package:teklif/model/events/services_events/fetch_service_event.dart';
import 'package:teklif/pages/forbusiness/addPages/add_service_page.dart';
import 'package:teklif/pages/forbusiness/updatePages/service_update_page.dart';
import 'package:teklif/states/service_state.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  User? currentUser;
  late ServiceBloc _serviceBloc;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _serviceBloc = BlocProvider.of<ServiceBloc>(context);
    _fetchServiceData();
  }

  void _fetchServiceData() {
    _serviceBloc.add(FetchServicesEvent());
  }

  void _deleteService(String serviceId) {
    // Bloc'dan müşteri silme işlemi
    BlocProvider.of<ServiceBloc>(context).add(DeleteServiceEvent(serviceId: serviceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<ServiceBloc, ServiceState>(listener: (context, state) {
        if (state is ServiceFailure) {
          MyFailureSnackbar.show(context, state.error);
        } else if (state is FetchServicesSuccess) {
       }
      }, child: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading || state is ServiceInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FetchServicesSuccess) {
            List<Map<String, dynamic>> services = state.serviceData;

            return Column(
              children: [
                NavBarItems(
                  label: "Hizmetler",
                  buttonText: "Hizmet ekle",
                  onButtonTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddServicePage(),
                      ),
                    );
                  },
                ),
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
                            'Hizmet Adı',
                            'Açıklama',
                            'Fiyat',
                            'Süre',

                            'İşlemler'
                          ],
                          rows: services.map((service) {
                            final double servicePrice = service['servicePrice'];
                            final String unitPrice = service['unitPrice'];

                            return {
                              'Hizmet Adı': service['serviceName'],
                              'Açıklama': service['serviceDescription'],
                              'Fiyat': '${servicePrice.toStringAsFixed(0)} ${unitPrice}', // Fiyatı iki ondalıklı biçimde göster
                              'Süre': service['serviceDuration'],
                            };
                          }).toList(),


                          onEditPressed: (index) {
                            // Müşteri güncelleme sayfasına git
                            if (services[index]['id'] != null) {
                              String serviceID = services[index]['id'];
                                Navigator.push(
                                context,
                               MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateServicePage(serviceUid: serviceID),
                                ),
                              );

                            }
                          },
                          onDeletePressed: (index) {
                            if(services[index]['id'] != null){
                              String serviceId = services[index]['id'];
                              print(serviceId);

                              _deleteService(serviceId);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: NavBarItems(
                label: "Hizmetler",
                buttonText: "Hizmet ekle",
                onButtonTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddServicePage(),
                    ),
                  );
                },
              ),
            );
          }
        },
      )),
    );
  }
}
