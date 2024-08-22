import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teklif/model/events/repair_events/add_repair_event.dart';
import 'package:teklif/model/events/repair_events/delete_repair_event.dart';
import 'package:teklif/model/events/repair_events/fetch_repair_event.dart';
import 'package:teklif/model/events/repair_events/update_repair_event.dart';
import 'package:teklif/states/repair_state.dart';

class RepairBloc extends Bloc<RepairEvent, RepairState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  RepairBloc()
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        super(RepairInitial()) {
    on<AddRepairEvent>(_onAddRepairEvent);
    on<FetchRepairsEvent>(_onFetchRepairs);
    on<FetchOneRepairEvent>(_fetchOneRepair);
    on<UpdateRepairEvent>(_onUpdateRepair);
    on<DeleteRepairEvent>(_deleteRepairInfo);
  }

  void _onAddRepairEvent(AddRepairEvent event, Emitter<RepairState> emit) async {
    emit(RepairLoading());
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchRepairFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(RepairAuthFailure(authError: true));
        return;
      }

      // Tamir verilerini hazırlama
      final repairData = {
        'repairName': event.repairName,
        'repairDescription': event.repairDescription,
        'repairDuration': event.repairDuration,
        'repairPrice': event.repairPrice,
        'repairDate': event.repairDate,
        'deviceName': event.deviceName,
        'deviceModel': event.deviceModel,
        'serialNumber': event.serialNumber,
        'problemDescription': event.problemDescription,
        'warrantyStatus': event.warrantyStatus,
        'repairCurrency': event.repairCurrency,
        'repairStatus': event.repairStatus,
        'userId': user.uid,
      };

      // Firestore'a veri ekleme
      await _firestore.collection('repairs').add(repairData);

      // Başarılı olursa
      emit(RepairSuccess());
      await _onFetchRepairs(FetchRepairsEvent(), emit);
    } catch (e) {
      // Hata olursa
      emit(RepairFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchRepairs(FetchRepairsEvent event, Emitter<RepairState> emit) async {
    emit(RepairLoading());
    emit(FetchRepairsLoading());
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchRepairFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(RepairAuthFailure(authError: true));
        return;
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('repairs')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> repairData = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Döküman UID'sini ekliyoruz
          return data;
        }).toList();

        emit(FetchRepairsSuccess(repairData: repairData));
      } else {
        emit(RepairFailure(error: "Tamir kaydı bulunamadı"));
      }
    } catch (e) {
      emit(RepairFailure(error: e.toString()));
    }
  }

  Future<void> _fetchOneRepair(
      FetchOneRepairEvent event, Emitter<RepairState> emit) async {
    emit(FetchRepairsLoading());

    try {

      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchRepairFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(RepairAuthFailure(authError: true));
        return;
      }
      DocumentSnapshot doc =
      await _firestore.collection('repairs').doc(event.repairId).get();

      if (doc.exists) {
        // Veriyi Map<String, dynamic>? türünde alın
        Map<String, dynamic>? customerData = doc.data() as Map<String, dynamic>?;

        if (customerData != null) {
          // Bu veriyi bir liste içine alın
          List<Map<String, dynamic>> repairDataList = [customerData];

          emit(FetchOneRepairSuccess(  repairData:  repairDataList));
          await _onFetchRepairs(FetchRepairsEvent(), emit);
        } else {
          emit(FetchRepairFailure(error: 'Tamir  bilgileri boş'));
        }
      } else {
        emit(FetchRepairFailure(error: 'tamir bilgisi bulunamadı'));
      }
    } catch (e) {
      emit(FetchRepairFailure(error: 'tamir bilgileri yüklenemedi: $e'));
    }
  }

  Future<void> _onUpdateRepair(UpdateRepairEvent event, Emitter<RepairState> emit) async {
    emit(RepairLoading());

    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchRepairFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(RepairAuthFailure(authError: true));
        return;
      }
      final repairData = {
        'repairName': event.repairName,
        'repairDescription': event.repairDescription,
        'repairDuration': event.repairDuration,
        'repairPrice': event.repairPrice,
        'repairDate': event.repairDate,
        'deviceName': event.deviceName,
        'deviceModel': event.deviceModel,
        'serialNumber': event.serialNumber,
        'problemDescription': event.problemDescription,
        'warrantyStatus': event.warrantyStatus,
        'repairCurrency': event.repairCurrency,
        'repairStatus': event.repairStatus,
      };

      await _firestore.collection('repairs').doc(event.repairId).update(repairData);

      emit(RepairSuccess());
    } catch (error) {
      emit(RepairFailure(error: error.toString()));
    }
  }

  Future<void> _deleteRepairInfo(
      DeleteRepairEvent event,
      Emitter<RepairState> emit,
      ) async {
    try {
      emit(RepairLoading());
      emit(RepairInitial());

      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(FetchRepairFailure(error: 'Kullanıcı oturum açmamış.'));
        emit(RepairAuthFailure(authError: true));
        return;
      }

      // Belge ID'sini event'ten alın
      final repairId = event.repairId;

      // Firestore'dan ürün mevcutluğunu kontrol edin
      DocumentSnapshot docSnapshot =
      await _firestore.collection('repairs').doc(repairId).get();

      if (!docSnapshot.exists) {
        throw Exception('Belge bulunamadı');
      }

      // Firestore'dan ürün silme işlemi
      await _firestore.collection('repairs').doc(repairId).delete();

      // Silme işlemi sonrası belgeyi tekrar kontrol edin
      docSnapshot =
      await _firestore.collection('repairs').doc(repairId).get();

      if (docSnapshot.exists) {
        throw Exception('hata: tamir bilgisi silinemedi ');
      }

      emit(DeleteRepairSuccess(message: 'tamir verisi başarıyla silindi.'));
      await _onFetchRepairs(FetchRepairsEvent(), emit);
    } catch (e) {
      emit(RepairFailure(error: e.toString()));
    }
  }
}


