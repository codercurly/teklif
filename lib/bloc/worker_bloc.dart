import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/model/events/workers_events/add_worker_event.dart';
import 'package:teklif/model/events/workers_events/delete_worker_event.dart';
import 'package:teklif/model/events/workers_events/fetch_worker_event.dart';
import 'package:teklif/model/events/workers_events/update_worker_event.dart';
import 'package:teklif/states/worker_state.dart';

class WorkerBloc extends Bloc<WorkerEvent, WorkerState>{
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final FirebaseAuth firebaseAuth;
  final AuthBloc authBloc;

  WorkerBloc({
    required this.firebaseFirestore,
    required this.firebaseStorage,
    required this.firebaseAuth,
    required this.authBloc,
  }) : super(WorkersInitial()) {
    on<SubmitWorkerEvent>(_submitWorkerEvent);
    on<FetchWorkerEvent>(_fetchWorkerInfo);
    on<DeleteWorkerEvent>(_deleteWorkerInfo);
    on<UpdateWorkerEvent>(_updateWorker);
    on<FetchWorkerUpdateEvent>(_fetchOneWorker);


  }
  Future<void> _submitWorkerEvent(
      SubmitWorkerEvent event, Emitter<WorkerState> emit) async {
    try {
      emit(WorkersInitial());

      // Kullanıcı oturumunu kontrol et
      if (!authBloc.userState()) {
        emit(WorkersFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın."));
        emit(WorkerAuthFailure(authError: true));
        return;
      }

      // Müşteri kodunun varlığını kontrol et
      bool isWorkerNoExists =
      await _checkWorkerCodeExists(event.workerNo);
      if (isWorkerNoExists) {
        throw Exception("Bu görevli kodu zaten mevcut, başka bir kod girin.");
      }
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserId = currentUser?.uid;
      // Resim yükleme işlemi


      // Firestore'a müşteri bilgilerini ekle
      await firebaseFirestore.collection("workers").add({
        "userId": currentUserId,
        "workerNo": event.workerNo,
        "workerName": event.workerName,
        "workName" :event.workName,
        "workerPhone": event.workerPhone,
        "workerMail": event.workerMail,
        "workerBusiness": event.workerBusiness,
        "workerRole": event.workerRole

      });

      emit(WorkersSuccess());
   await _fetchWorkerInfo(FetchWorkerEvent(), emit);
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(WorkersFailure(error: errorMessage));
    }
  }

  Future<bool> _checkWorkerCodeExists(String workerNo) async {
    try {
      QuerySnapshot query = await firebaseFirestore
          .collection("workers")
          .where("workerNo", isEqualTo: workerNo)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchWorkerInfo(
      FetchWorkerEvent event,
      Emitter<WorkerState> emit,
      ) async {
    emit(WorkersLoading());

    try {
      if (!authBloc.userState()) {
        emit(WorkerAuthFailure(authError: true));
        emit(WorkersFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın"));
        return;
      }

      User? user = firebaseAuth.currentUser;
      QuerySnapshot query = await firebaseFirestore
          .collection("workers")
          .where("userId", isEqualTo: user?.uid)
          .get();

      if (query.docs.isNotEmpty) {
        List<Map<String, dynamic>> workerData = query.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;  // Döküman UID'sini ekliyoruz
          return data;
        }).toList();

        emit(FetchWorkersSuccess(workerData: workerData));
      } else {
        emit(WorkersFailure(error: "Çalışan bulunamadı"));
      }
    } catch (e) {
      emit(WorkersFailure(error: "Çalışan bilgileri yüklenemedi"));
    }
  }

  Future<void> _deleteWorkerInfo(
      DeleteWorkerEvent event,
      Emitter<WorkerState> emit,
      ) async {
    try {
      emit(WorkersLoading());
      emit(WorkersInitial());

      if (!authBloc.userState()) {
        // Kullanıcı oturumu yoksa, işlemi durdurup başka bir şey yapabiliriz.
        emit(WorkersFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
        emit(WorkerAuthFailure(authError: true));
        return;
      }

      // Belge ID'sini event'ten alın
      final workerId = event.workerId;

      // Firestore'dan ürün mevcutluğunu kontrol edin
      DocumentSnapshot docSnapshot =
      await firebaseFirestore.collection('workers').doc(workerId).get();

      if (!docSnapshot.exists) {
        throw Exception('Belge bulunamadı');
      }

      await firebaseFirestore.collection('workers').doc(workerId).delete();

      // Silme işlemi sonrası belgeyi tekrar kontrol edin
      docSnapshot =
      await firebaseFirestore.collection('workers').doc(workerId).get();

      if (docSnapshot.exists) {
        throw Exception('hata çalışan silinemedi ');
      }

      emit(DeleteWorkerSuccess(message: 'çalışan başarıyla silindi.'));
      await _fetchWorkerInfo(FetchWorkerEvent(), emit);
    } catch (e) {
      emit(WorkersFailure(error: e.toString()));
    }
  }

  Future<void> _updateWorker(UpdateWorkerEvent event, Emitter<WorkerState> emit) async {
    try {
      emit(WorkersInitial());
      emit(WorkersLoading());

      if (!authBloc.userState()) {
        emit(WorkersFailure(error: 'Oturumunuzun süresi doldu. Lütfen giriş yapın.'));
        emit(WorkerAuthFailure(authError: true));
        return;
      }



      Map<String, dynamic> updatedata = {
        "workName": event.workName,
        "workerRole": event.workerRole,
        "workerNo": event.workerNo,
        "workerBusiness": event.workerBusiness,
        "workerMail": event.workerMail,
        "workerPhone": event.workerPhone,
        "workerName": event.workerName
      };


      await firebaseFirestore.collection("workers").doc(event.workerId).update(updatedata);
      emit(WorkersSuccess(msg: "Güncelleme başarılı."));
         await _fetchWorkerInfo(FetchWorkerEvent(), emit);
    } catch (e) {
      emit(WorkersFailure(error: 'Çalışan güncellenemedi: ${e.toString()}'));
    }
  }
  Future<void> _fetchOneWorker(
      FetchWorkerUpdateEvent event, Emitter<WorkerState> emit) async {
    emit(FetchWorkersLoading());

    try {
      DocumentSnapshot doc =
      await firebaseFirestore.collection('workers').doc(event.workerId).get();

      if (doc.exists) {
        // Veriyi Map<String, dynamic>? türünde alın
        Map<String, dynamic>? workerData = doc.data() as Map<String, dynamic>?;

        if (workerData != null) {
          // Bu veriyi bir liste içine alın
          List<Map<String, dynamic>> workerDataList = [workerData];

          emit(FetchOneWorkerSuccess(workerData: workerDataList));
          await _fetchWorkerInfo(FetchWorkerEvent(), emit);
        } else {
          emit(FetchWorkerFailure(error: 'Görevli verisi boş'));
        }
      } else {
        emit(FetchWorkerFailure(error: 'Görevli bulunamadı'));
      }
    } catch (e) {
      emit(FetchWorkerFailure(error: 'Görevli bilgileri yüklenemedi: $e'));
    }
  }


}