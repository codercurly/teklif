import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teklif/model/events/services_events/add_service_event.dart';
import 'package:teklif/model/events/services_events/delete_service_event.dart';
import 'package:teklif/model/events/services_events/fetch_service_event.dart';
import 'package:teklif/model/events/services_events/update_service_event.dart';
import 'package:teklif/states/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ServiceBloc()
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        super(ServiceInitial()) {
    on<AddServiceEvent>(_onAddServiceEvent);
    on<FetchServicesEvent>(_onFetchServices);
    on<FetchOneServiceEvent>(_fetchOneService);
    on<UpdateServiceEvent>(_onUpdateService);
    on<DeleteServiceEvent>(_deleteServiceInfo);
  }

  void _onAddServiceEvent(AddServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchServiceFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(ServiceAuthFailure(authError: true));
        return;
      }

      // Hizmet verilerini hazırlama
      final serviceData = {
        'serviceName': event.serviceName,
        'serviceDescription': event.serviceDescription,
        'servicePrice': event.servicePrice,
        'serviceDuration': event.serviceDuration,
        'unitPrice': event.unitPrice,
        'userId': user.uid,
      };

      // Firestore'a veri ekleme
      await _firestore.collection('services').add(serviceData);

      // Başarılı olursa
      emit(ServiceSuccess());
      await _onFetchServices(FetchServicesEvent(), emit);
    } catch (e) {
      // Hata olursa
      emit(ServiceFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchServices(FetchServicesEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    emit(FetchServicesLoading());
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchServiceFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(ServiceAuthFailure(authError: true));
        return;
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> serviceData = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Döküman UID'sini ekliyoruz
          return data;
        }).toList();

        emit(FetchServicesSuccess(serviceData: serviceData));
      } else {
        emit(ServiceFailure(error: "Hizmet kaydı bulunamadı"));
      }
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }
  Future<void> _fetchOneService(
      FetchOneServiceEvent event, Emitter<ServiceState> emit) async {
    emit(FetchServicesLoading());

    try {
      DocumentSnapshot doc =
      await _firestore.collection('services').doc(event.serviceId).get();

      if (doc.exists) {
        // Veriyi Map<String, dynamic>? türünde alın
        Map<String, dynamic>? serviceData = doc.data() as Map<String, dynamic>?;

        if (serviceData != null) {
          // Bu veriyi bir liste içine alın
          List<Map<String, dynamic>> serviceDataList = [serviceData];

          emit(FetchOneServiceSuccess(serviceData: serviceDataList));
          await _onFetchServices(FetchServicesEvent(), emit);
        } else {
          emit(FetchServiceFailure(error: 'Müşteri verisi boş'));
        }
      } else {
        emit(FetchServiceFailure(error: 'Müşteri bulunamadı'));
      }
    } catch (e) {
      emit(FetchServiceFailure(error: 'Müşteri bilgileri yüklenemedi: $e'));
    }
  }




  Future<void> _onUpdateService(UpdateServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());

    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchServiceFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(ServiceAuthFailure(authError: true));
        return;
      }
      final serviceData = {
        'serviceName': event.serviceName,
        'serviceDescription': event.serviceDescription,
        'servicePrice': event.servicePrice,
        'serviceDuration': event.serviceDuration,
        'unitPrice': event.unitPrice,

      };

      await _firestore.collection('services').doc(event.serviceId).update(serviceData);

      emit(ServiceSuccess());
    } catch (error) {
      emit(ServiceFailure(error: error.toString()));
    }
  }

  Future<void> _deleteServiceInfo(DeleteServiceEvent event, Emitter<ServiceState> emit) async {
    try {
      emit(ServiceLoading());
      emit(ServiceInitial());

      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchServiceFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(ServiceAuthFailure(authError: true));
        return;
      }

      // Belge ID'sini event'ten alın
      final serviceId = event.serviceId;

      // Firestore'dan hizmet mevcutluğunu kontrol edin
      DocumentSnapshot docSnapshot = await _firestore.collection('services').doc(serviceId).get();

      if (!docSnapshot.exists) {
        throw Exception('Belge bulunamadı');
      }

      // Firestore'dan hizmet silme işlemi
      await _firestore.collection('services').doc(serviceId).delete();

      // Silme işlemi sonrası belgeyi tekrar kontrol edin
      docSnapshot = await _firestore.collection('services').doc(serviceId).get();

      if (docSnapshot.exists) {
        throw Exception('hata: hizmet bilgisi silinemedi');
      }

      emit(DeleteServiceSuccess(message: 'hizmet verisi başarıyla silindi.'));
      await _onFetchServices(FetchServicesEvent(), emit);
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }
}
