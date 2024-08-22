import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/bloc/business_bloc.dart';
import 'package:teklif/model/events/auth_event.dart';
import 'package:teklif/model/events/business_events/fetchUpdateB_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/pages/forbusiness/updatePages/business_update_page.dart';
import 'package:teklif/states/business_state.dart';

class CompanyProfilePage extends StatefulWidget {
  @override
  _CompanyProfilePageState createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  late User? currentUser; // Mevcut kullanıcıyı tutacak değişken
  late String currentUserId; // Mevcut kullanıcı ID'sini tutacak değişken

  @override
  void initState() {
    super.initState();
    // Firebase Auth üzerinden mevcut kullanıcıyı al
    currentUser = FirebaseAuth.instance.currentUser;
    currentUserId = currentUser?.uid ?? '';

    // Veri çekme işlemini başlatmak için fetch işlemini burada yapabilirsiniz
    BlocProvider.of<BusinessBloc>(context).add(FetchBusinessUpdateEvent(userId: currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(Dimension.getWidth20(context)),
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, state) {
            if (state is FetchBusinessesLoading) {
              return Center(child: CircularProgressIndicator());
            } else if
            (state is FetchOneBusinessSuccess) {
              // Veri başarıyla alındıysa işlemleri burada yapın
              List<Map<String, dynamic>> businessData = state.businessData;

              // Örnek olarak işletme adı ve diğer verileri kullanabilirsiniz
              String businessName = businessData.isNotEmpty ? businessData[0]['businessName'] ?? '' : '';
              String phone = businessData.isNotEmpty ? businessData[0]['phone'] ?? '' : '';
              String email = businessData.isNotEmpty ? businessData[0]['email'] ?? '' : '';
              String businessAddress = businessData.isNotEmpty ? businessData[0]['businessAddress'] ?? '' : '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          // İşletme logosunu buraya ekleyin, örneğin networkten veya assets'den
                          backgroundImage: businessData[0]['image'] !=""
                              ? NetworkImage(businessData[0]['image'])
                              : AssetImage('assets/logo.png'),
                        ),
                        SizedBox(height: 16),
                        Text(
                          businessName,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildProfileRow(Icons.phone, 'Telefon', phone),
                  SizedBox(height: 16),
                  _buildProfileRow(Icons.email, 'E-posta', email),
                  SizedBox(height: 16),
                  _buildProfileRow(Icons.location_on, 'Adres', businessAddress),
                  SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if(currentUserId != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  UpdateBusinessPage(
                                      userId: currentUserId)));
                        }  },
                      child: Container(
                        margin: EdgeInsets.all(Dimension.getWidth15(context)),
                        height: Dimension.getHeight10(context) * 4,
                        width: Dimension.getWidth10(context) * 13,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.greentree,
                              AppColors.greentwo,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                          BorderRadius.circular(Dimension.getRadius15(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Düzenle",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Dimension.getFont18(context),
                                  fontFamily: "Merriweather"),
                            ),
                            Icon(
                              Icons.edit,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                        Navigator.push(context, MaterialPageRoute(builder: (context)
                        => LoginPage()));
                      },
                      child: Container(
                        margin: EdgeInsets.all(Dimension.getWidth15(context)),
                        height: Dimension.getHeight10(context) * 4,
                        width: Dimension.getWidth10(context) * 13,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.redAccent,
                              Colors.red,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                          BorderRadius.circular(Dimension.getRadius15(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Çıkış Yap",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Dimension.getFont18(context),
                                  fontFamily: "Merriweather"),
                            ),
                            Icon(
                              Icons.logout,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            else if (state is FetchBusinessFailure) {
              return Center(
                child: Text(
                  'Hata: ${state.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else {
              // Varsayılan durum, eğer bir şey beklenmeyen bir hata olursa
              return Center(
                child: Text(
                  'Beklenmeyen bir hata oluştu.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String info) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              info,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
