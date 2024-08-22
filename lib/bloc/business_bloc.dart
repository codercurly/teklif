import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/model/events/business_events/business_event.dart';
import 'package:teklif/model/events/business_events/fetchUpdateB_event.dart';
import 'package:teklif/model/events/business_events/update_business_event.dart';
import 'package:teklif/states/business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final FirebaseAuth firebaseAuth;
  final AuthBloc authBloc;

  BusinessBloc({
    required this.firebaseFirestore,
    required this.firebaseStorage,
    required this.firebaseAuth,
    required this.authBloc,
  }) : super(BusinessInitial()) {
    on<FetchBusinessUpdateEvent>(_fetchOneBusiness);
    on<UpdateBusinessEvent>(_updateBusiness);
  }


  Future<void> _updateBusiness(
      UpdateBusinessEvent event, Emitter<BusinessState> emit) async {
    try {
      emit(BusinessInitial());
      emit(BusinessLoading());

      if (!authBloc.userState()) {
        emit(BusinessFailure(error: 'Oturumunuzun süresi doldu. Lütfen giriş yapın.'));
        emit(BusinessAuthFailure(authError: true));
        return;
      }

      Map<String, dynamic> updatedata = {
        "businessName": event.businessName,
        "businessAddress": event.businessAddress,
        "phone": event.phone,
        "email": event.email,
        "name": event.name
      };

      await firebaseFirestore.collection("users").doc(event.userId).update(updatedata);
      emit(BusinessSuccess(msg: "Güncelleme başarılı."));
     // await _fetchBusinessInfo(FetchBusinessEvent(), emit);
    } catch (e) {
      emit(BusinessFailure(error: 'İşletme güncellenemedi: ${e.toString()}'));
    }
  }

  Future<void> _fetchOneBusiness(
      FetchBusinessUpdateEvent event, Emitter<BusinessState> emit) async {
    emit(FetchBusinessesLoading());

    try {
      // Kullanıcı oturumunu kontrol et
      if (!authBloc.userState()) {
        emit(BusinessFailure(error: "Oturumunuzun süresi doldu. Lütfen giriş yapın."));
        emit(BusinessAuthFailure(authError: true));
        return;
      }

      // Şu anda oturumu açık olan kullanıcının kimliğini al
      User? currentUser = firebaseAuth.currentUser;
      String? currentUserId = currentUser?.uid;

      // Veritabanından şu anda oturumu açık olan kullanıcının işletme verisini çek
      DocumentSnapshot<Map<String, dynamic>> query = await firebaseFirestore
          .collection('users')
          .doc(currentUserId) // Döküman ID'si olarak currentUser.uid kullanılıyor
          .get();

      if (query.exists) {
        // Döküman varsa veriyi al
        Map<String, dynamic>? businessData = query.data();

        if (businessData != null) {
          // Bu veriyi bir liste içine alın
          List<Map<String, dynamic>> businessDataList = [businessData];
          emit(FetchOneBusinessSuccess(businessData: businessDataList));
        } else {
          emit(FetchBusinessFailure(error: 'İşletme verisi boş'));
        }
      } else {
        emit(FetchBusinessFailure(error: 'İşletme bulunamadı'));
      }
    } catch (e) {
      emit(FetchBusinessFailure(error: 'İşletme bilgileri yüklenemedi: $e'));
    }
  }

}
