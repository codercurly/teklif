import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/repair_bloc.dart';
import 'package:teklif/components/app_table.dart';
import 'package:teklif/components/navbar_items.dart';
import 'package:teklif/model/events/repair_events/delete_repair_event.dart';
import 'package:teklif/model/events/repair_events/fetch_repair_event.dart';
import 'package:teklif/pages/forbusiness/addPages/add_repair_page.dart';
import 'package:teklif/pages/forbusiness/updatePages/update_repair_page.dart';
import 'package:teklif/states/repair_state.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({Key? key}) : super(key: key);

  @override
  _RepairsPageState createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  User? currentUser;
  late RepairBloc _repairBloc;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _repairBloc = BlocProvider.of<RepairBloc>(context);
    _fetchRepairData();
  }

  void _fetchRepairData() {
    _repairBloc.add(FetchRepairsEvent());
  }
  void _deleteRepair(String repairId) {
    // Bloc'dan müşteri silme işlemi
    BlocProvider.of<RepairBloc>(context).add(DeleteRepairEvent(repairId: repairId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<RepairBloc, RepairState>(listener: (context, state) {
        if (state is RepairFailure) {
          MyFailureSnackbar.show(context, state.error);
        } else if (state is FetchRepairsSuccess) {
          MySuccessSnackbar.show(context, 'Tamir verileri başarıyla yüklendi.');
        }
      }, child: BlocBuilder<RepairBloc, RepairState>(
        builder: (context, state) {
          if (state is RepairLoading || state is RepairInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FetchRepairsSuccess) {
            List<Map<String, dynamic>> repairs = state.repairData;

            return Column(
              children: [
                NavBarItems(
                  label: "Onarımlar",
                  buttonText: "Onarım ekle",
                  onButtonTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRepairPage(),
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
                            'Tamir Adı',
                            'Açıklama',
                            'Süre',
                            'Fiyat',
                            'Tarih',
                            'Cihaz Adı',
                            'Cihaz Modeli',
                            'Seri No',
                            'Problem Açıklaması',
                            'Garanti Durumu',
                            'Para Birimi',
                            'Tamir Durumu',
                            'İşlemler'
                          ],
                          rows: repairs.map((repair) {
                            final timestamp = repair['repairDate'] as Timestamp;
                            final date = timestamp.toDate();
                            final formattedDate =
                                DateFormat('dd MMMM yyyy', 'tr_TR')
                                    .format(date);

                            return {
                              'Tamir Adı': repair['repairName'],
                              'Açıklama': repair['repairDescription'],
                              'Süre': repair['repairDuration'],
                              'Fiyat': repair['repairPrice'],
                              'Tarih': formattedDate, // Formatted date
                              'Cihaz Adı': repair['deviceName'],
                              'Cihaz Modeli': repair['deviceModel'],
                              'Seri No': repair['serialNumber'],
                              'Problem Açıklaması':
                                  repair['problemDescription'],
                              'Garanti Durumu': repair['warrantyStatus'],
                              'Para Birimi': repair['repairCurrency'],
                              'Tamir Durumu': repair['repairStatus'],
                            };
                          }).toList(),
                          onEditPressed: (index) {
                            // Müşteri güncelleme sayfasına git
                            if (repairs[index]['id'] != null) {
                              String repairID = repairs[index]['id'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateRepairPage(repairUid: repairID),
                                ),
                              );
                            }
                          },
                          onDeletePressed: (index) {
                            if(repairs[index]['id'] != null){

                              String repairId = repairs[index]['id'];
                              print(repairId);

                              _deleteRepair(repairId);
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
            return NavBarItems(
              label: "Onarım-Tamir",
              buttonText: "Onarım ekle",
              onButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRepairPage(),
                  ),
                );
              },
            );
          }
        },
      )),
    );
  }
}
