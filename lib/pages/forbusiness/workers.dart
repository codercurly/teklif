import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/worker_bloc.dart';
import 'package:teklif/components/app_table.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/label_container.dart';
import 'package:teklif/components/navbar_items.dart';
import 'package:teklif/model/events/workers_events/delete_worker_event.dart';
import 'package:teklif/model/events/workers_events/fetch_worker_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_worker_page.dart';
import 'package:teklif/pages/forbusiness/updatePages/worker_update_page.dart';
import 'package:teklif/states/worker_state.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({Key? key}) : super(key: key);

  @override
  _WorkersPageState createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  User? currentUser;
  late WorkerBloc _workerBloc;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _workerBloc = BlocProvider.of<WorkerBloc>(context);
    _fetchWorkerData();
  }

  void _fetchWorkerData() {
    _workerBloc.add(FetchWorkerEvent());
  }

  void _deleteWorker(String workerId) {
  BlocProvider.of<WorkerBloc>(context).add(DeleteWorkerEvent(workerId: workerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<WorkerBloc, WorkerState>(
        listener: (context, state) {
          if (state is WorkersFailure) {
            MyFailureSnackbar.show(context, state.error);
          } else if (state is DeleteWorkerSuccess) {
            MySuccessSnackbar.show(context, state.message);
          } else if (state is WorkerAuthFailure && state.authError) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          }
        },
        child: BlocBuilder<WorkerBloc, WorkerState>(
          builder: (context, state) {
            if (state is FetchWorkersSuccess) {
              List<Map<String, dynamic>> workers = state.workerData;

              return Column(
                children: [
                  NavBarItems(label: "Çalışanlar", buttonText: "Çalışan ekle",
                      onButtonTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddWorkerPage()));
                      },),
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
                              'Çalışan No',
                              'Çalışan Adı',
                              'İş',
                              "Yetki",
                              'E-posta',
                              'Telefon',
                              'Çalıştığı firma',
                              'İşlemler'
                            ],
                            rows: workers.map((worker) {
                              return {
                                'Çalışan No': worker['workerNo'],
                                'Çalışan Adı': worker['workerName'],
                                'İş': worker['workName'],
                                'Yetki':worker['workerRole'],
                                'E-posta': worker['workerMail'],
                                'Telefon': worker['workerPhone'],
                                'Çalıştığı firma':worker['workerBusiness']
                              };
                            }).toList(), onEditPressed: (index ) {          // Müşteri güncelleme sayfasına git
                            if(workers[index]['id'] != null) {
                              String workerId = workers[index]['id'];
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>
                                      UpdateWorkerPage(
                                          workerId: workerId)));
                            }

                          },
                            onDeletePressed: (index ) {
                              if(workers[index]['id'] != null){

                                String workerID = workers[index]['id'];

                                _deleteWorker(workerID);
                              }

                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is WorkersLoading || state is WorkersInitial) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text('Hiç çalışan bulunamadı'));
            }
          },
        ),
      ),
    );
  }
}
