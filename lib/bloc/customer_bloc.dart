import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/model/events/customer_events/add_customer_event.dart';
import 'package:teklif/model/events/customer_events/delete_customer_event.dart';
import 'package:teklif/model/events/customer_events/fetch_customer_event.dart';
import 'package:teklif/model/events/customer_events/update_customer_event.dart';
import 'package:teklif/states/customer_state.dart';

class CustomerBloc extends Bloc<CustomersEvent, CustomerState> {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final FirebaseAuth firebaseAuth;
  final AuthBloc authBloc;

  CustomerBloc({
    required this.firebaseFirestore,
    required this.firebaseStorage,
    required this.firebaseAuth,
    required this.authBloc,
  }) : super(CustomersInitial()) {
    on<SubmitCustomerEvent>(_submitCustomerEvent);
    on<FetchCustomerEvent>(_fetchCustomerInfo);
    on<DeleteCustomerEvent>(_deleteCustomInfo);
    on<UpdateCustomerEvent>(_updateCustomer);
    on<FetchCustomerUpdateEvent>(_fetchOneCustomer);
  }

  Future<void> _submitCustomerEvent(
      SubmitCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      emit(CustomersInitial());

      // Kullanıcı oturumunu kontrol et
      if (!authBloc.userState()) {
        emit(CustomersFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın."));
        emit(CustomerAuthFailure(authError: true));
        return;
      }

      // Müşteri kodunun varlığını kontrol et
      bool isCustomerNoExists =
          await _checkCustomerCodeExists(event.customerNo);
      if (isCustomerNoExists) {
        throw Exception("Bu müşteri kodu zaten mevcut, başka bir kod girin.");
      }
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserId = currentUser?.uid;
      // Resim yükleme işlemi
      String imageUrl = '';
      if (event.companyLogo.isNotEmpty) {
        imageUrl = await _uploadCustomerLogo(event.companyLogo);
      }

      // Firestore'a müşteri bilgilerini ekle
      await firebaseFirestore.collection("customers").add({
        "userId":currentUserId,
        "customerNo": event.customerNo,
        "customerName": event.customerName,
        "customerPhone": event.customerPhone,
        "customerMail": event.customerMail,
        "customerBusiness": event.customerBusiness,
        "customerAdres": event.customerAdres,
        "customerNote": event.customerNote,
        "companyLogo": imageUrl, // Yüklenen resmin URL'si
      });

      emit(CustomersSuccess());
      await _fetchCustomerInfo(FetchCustomerEvent(), emit);
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(CustomersFailure(error: errorMessage));
    }
  }

  Future<String> _uploadCustomerLogo(String imagePath) async {
    try {
      if (!authBloc.userState()) {
        emit(CustomersFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın."));
        emit(CustomerAuthFailure(authError: true));
        return '';
      }
      User? user = firebaseAuth.currentUser;

      File imageFile = File(imagePath);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Storage'da klasöre göre resmi yükle
      TaskSnapshot snapshot = await firebaseStorage
          .ref()
          .child('customerLogo/${user?.uid}/$fileName')
          .putFile(imageFile);

      // Yükleme işleminden sonra URL al
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      throw Exception('Resim yükleme hatası: $e');
    }
  }

  Future<bool> _checkCustomerCodeExists(String customNo) async {
    try {
      QuerySnapshot query = await firebaseFirestore
          .collection("customers")
          .where("customerNo", isEqualTo: customNo)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchCustomerInfo(
      FetchCustomerEvent event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomersLoading());

    try {
      if (!authBloc.userState()) {
        emit(CustomerAuthFailure(authError: true));
        emit(CustomersFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın"));
        return;
      }

      User? user = firebaseAuth.currentUser;
      QuerySnapshot query = await firebaseFirestore
          .collection("customers")
          .where("userId", isEqualTo: user?.uid)
          .get();

      if (query.docs.isNotEmpty) {
        List<Map<String, dynamic>> customerData = query.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;  // Döküman UID'sini ekliyoruz
          return data;
        }).toList();

        emit(FetchCustomersSuccess(customerData: customerData));
      } else {
        emit(CustomersFailure(error: "Müşteri bulunamadı"));
      }
    } catch (e) {
      emit(CustomersFailure(error: "Müşteri bilgileri yüklenemedi"));
    }
  }


  Future<void> _deleteCustomInfo(
      DeleteCustomerEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      emit(CustomersLoading());
      emit(CustomersInitial());

      if (!authBloc.userState()) {
        // Kullanıcı oturumu yoksa, işlemi durdurup başka bir şey yapabiliriz.
        emit(CustomersFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
        emit(CustomerAuthFailure(authError: true));
        return;
      }

      // Belge ID'sini event'ten alın
      final customerId = event.customerId;

      // Firestore'dan ürün mevcutluğunu kontrol edin
      DocumentSnapshot docSnapshot =
      await firebaseFirestore.collection('customers').doc(customerId).get();

      if (!docSnapshot.exists) {
        throw Exception('Belge bulunamadı');
      }

      // Firestore'dan ürün silme işlemi
      await firebaseFirestore.collection('customers').doc(customerId).delete();

      // Silme işlemi sonrası belgeyi tekrar kontrol edin
      docSnapshot =
      await firebaseFirestore.collection('customers').doc(customerId).get();

      if (docSnapshot.exists) {
        throw Exception('hata müşteri silinemedi ');
      }

      emit(DeleteCustomerSuccess(message: 'Müşteri başarıyla silindi.'));
      await _fetchCustomerInfo(FetchCustomerEvent(), emit);
    } catch (e) {
      emit(CustomersFailure(error: e.toString()));
    }
  }


  Future<void> _updateCustomer(UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      emit(CustomersInitial());
      emit(CustomersLoading());

      if (!authBloc.userState()) {
        emit(CustomersFailure(error: 'Oturumunuzun süresi doldu. Lütfen giriş yapın.'));
        emit(CustomerAuthFailure(authError: true));
        return;
      }

      String? logoUrl;

      // Eğer yeni bir logo seçildiyse dosya yolunu al
      if (event.companyLogo != null && event.companyLogo!.isNotEmpty && event.companyLogo!.startsWith('/')) {
        File logoFile = File(event.companyLogo!); // String dosya yolunu File nesnesine dönüştürün
        if (logoFile.existsSync()) {
          logoUrl = await _updateCustomerLogo(logoFile, event.customerId);
        } else {
          print('Dosya mevcut değil: ${logoFile.path}');
          throw Exception('Logo dosyası mevcut değil: ${logoFile.path}');
        }
      } else {
        // Yeni logo seçilmediyse mevcut logonun URL'sini kullan
        logoUrl = event.companyLogo;
      }

      Map<String, dynamic> updatedata = {
        "customerNo": event.customerNo,
        "customerName": event.customerName,
        "customerMail": event.customerMail,
        "customerBusiness": event.customerBusiness,
        "customerPhone": event.customerPhone,
        "customerAdres": event.customerAdres,
        "customerNote": event.customerNote,
      };

      // Eğer logo yüklendiyse, URL'yi güncelleme verilerine ekleyin
      if (logoUrl != null && logoUrl.isNotEmpty) {
        updatedata["companyLogo"] = logoUrl;
      }

      await firebaseFirestore.collection("customers").doc(event.customerId).update(updatedata);
      emit(CustomersSuccess());
      emit(SuccessCustomerLogo(msg: 'Müşteri başarıyla güncellendi.'));
      await _fetchCustomerInfo(FetchCustomerEvent(), emit);
    } catch (e) {
      emit(CustomersFailure(error: 'Müşteri güncellenemedi: ${e.toString()}'));
    }
  }


  Future<String> _updateCustomerLogo(File logoFile, String customerId) async {
    try {
      if (!authBloc.userState()) {
        emit(CustomersFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın."));
        emit(CustomerAuthFailure(authError: true));
        return '';
      }
      User? user = firebaseAuth.currentUser;
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('customerLogo/${user?.uid}/${logoFile.path.split('/').last}');
      UploadTask uploadTask = storageReference.putFile(logoFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Logo yüklenemedi: ${e.toString()}');
    }
  }

  Future<void> _fetchOneCustomer(
      FetchCustomerUpdateEvent event, Emitter<CustomerState> emit) async {
    emit(FetchCustomersLoading());

    try {
      DocumentSnapshot doc =
      await firebaseFirestore.collection('customers').doc(event.customerId).get();

      if (doc.exists) {
        // Veriyi Map<String, dynamic>? türünde alın
        Map<String, dynamic>? customerData = doc.data() as Map<String, dynamic>?;

        if (customerData != null) {
          // Bu veriyi bir liste içine alın
          List<Map<String, dynamic>> customerDataList = [customerData];

          emit(FetchOneCustomersSuccess(customerData: customerDataList));
          await _fetchCustomerInfo(FetchCustomerEvent(), emit);
        } else {
          emit(FetchCustomerFailure(error: 'Müşteri verisi boş'));
        }
      } else {
        emit(FetchCustomerFailure(error: 'Müşteri bulunamadı'));
      }
    } catch (e) {
      emit(FetchCustomerFailure(error: 'Müşteri bilgileri yüklenemedi: $e'));
    }
  }


}
