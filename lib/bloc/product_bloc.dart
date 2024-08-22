import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:teklif/bloc/auth_bloc.dart';

import 'package:teklif/model/events/product_events/add_product_event.dart';
import 'package:teklif/model/events/product_events/delete_product_event.dart';
import 'package:teklif/model/events/product_events/fetch_product_event.dart';
import 'package:teklif/model/events/product_events/imageupload_event.dart';
import 'package:teklif/model/events/product_events/update_product_event.dart';
import 'package:teklif/states/product_state.dart';

class ProductBloc extends Bloc<AddProductEvent, ProductState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  final AuthBloc authBloc;

  ProductBloc({
    required this.authBloc,
    required this.firestore,
    required this.storage,
    required this.auth,
  }) : super(AddProductInitial()) {
    on<SubmitProductEvent>(_onSubmitProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<FetchOneProductEvent>(_onFetchProduct); // Yeni event handler
    on<FetchProductEvent>(_fetchProducts); // Yeni event handler
    on<UploadImageEvent>(_onUploadImage);
    on<DeleteProductEvent>(_mapDeleteProductEventToState); // DeleteProductEvent'i dinliyoruz

  }

  Future<void> _onSubmitProduct(
      SubmitProductEvent event, Emitter<ProductState> emit) async {
    emit(AddProductLoading());

    try {
      User? user = auth.currentUser;
      if (user == null) {
        emit(AddProductFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
        emit(ProductAuthFailure(authError: true));
        return;
      }

      // Ürün kodu kontrolü
      bool isProductCodeExists =
      await _checkProductCodeExists(event.productCode);
      if (isProductCodeExists) {
        throw Exception(
            'Bu ürün kodu zaten mevcut, başka bir kod girin.');
      }

      List<String> imageUrls = [];
      for (String imagePath in event.images) {
        File imageFile = File(imagePath);
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}.jpg';
        TaskSnapshot snapshot = await storage
            .ref()
            .child('user_uploads/${user.uid}/$fileName')
            .putFile(imageFile);
        String downloadUrl =
        await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      await firestore.collection('products').add({
        'productCode': event.productCode,
        'productName': event.productName,
        'quantity': event.quantity,
        'price': event.price,
        'priceUnit': event.priceUnit,
        'images': imageUrls,
        'userId': user.uid,
      });

      emit(AddProductSuccess());
    } catch (e) {
      String errorMessage =
      e.toString().replaceFirst('Exception: ', '');
      emit(AddProductFailure(error: errorMessage));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(AddProductLoading());

    try {
      User? user = auth.currentUser;
      if (!authBloc.userState()) {
        // Kullanıcı oturumu yoksa, işlemi durdurup başka bir şey yapabiliriz.
        emit(AddProductFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
        emit(ProductAuthFailure(authError: true));
      }

      print('Güncellenen ürün bilgileri hazırlanıyor...');
      Map<String, dynamic> updatedData = {
        'productCode': event.productCode,
        'productName': event.productName,
        'quantity': event.quantity,
        'price': event.price,
        'priceUnit': event.priceUnit,
      };

      // Yeni resimlerin URL'lerini yükle
      if (event.newImages.isNotEmpty) {
        print('Yeni resimler yükleniyor...');
        List<String> newImageUrls = [];

        for (String imagePath in event.newImages) {
          // Dosyayı yükle
          String downloadUrl = await uploadImageToFirebase(imagePath);
          newImageUrls.add(downloadUrl);
        }

        updatedData['images'] = newImageUrls;
      } else {
        // Eğer yeni resim yoksa, mevcut resimleri güncelleme verisine ekleyin
        // Örneğin:
        updatedData['images'] = event.currentImages; // event içinden mevcut resimleri alın
      }

      // Firestore güncelleme işlemi
      print('Firestore güncelleme işlemi yapılıyor...');
      await firestore
          .collection('products')
          .doc(event.productId)
          .update(updatedData);

      print('Güncelleme başarılı');
      emit(AddProductSuccess());
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Güncelleme hatası: $errorMessage');
      emit(AddProductFailure(error: errorMessage));
    }
  }


  Future<String> uploadImageToFirebase(String filePath) async {
    User? user = auth.currentUser;
    if (user == null) {
      emit(AddProductFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
      emit(ProductAuthFailure(authError: true));

    }

    // Dosyayı yükle
    File imageFile = File(filePath);
    TaskSnapshot snapshot = await storage
        .ref()
        .child('user_uploads/${user!.uid}/${imageFile.path.split('/').last}')
        .putFile(imageFile);

    // Yükleme işleminden sonra URL al
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }



  Future<void> _onUploadImage(
      UploadImageEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(AddProductLoading());

    try {
      User? user = auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu açmamış');
      }

      // Dosyayı Firebase Storage'a yükle
      String downloadUrl = await uploadImageToFirebase(event.imagePath);

      emit(UploadImageSuccess(downloadUrl: downloadUrl));
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Resim yükleme hatası: $errorMessage');
      emit(AddProductFailure(error: errorMessage));
    }
  }



  // Rastgele dosya adı oluşturma işlevi
  String generateFileName() {
    String randomChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String fileName = '';
    for (int i = 0; i < 10; i++) {
      fileName +=
          randomChars.characters.elementAt(Random().nextInt(randomChars.length));
    }
    fileName += '.jpg'; // Uzantıyı ekleyin veya dosya türüne göre ayarlayın
    return fileName;
  }

  Future<bool> _checkProductCodeExists(String productCode) async {
    try {
      QuerySnapshot query = await firestore
          .collection('products')
          .where('productCode', isEqualTo: productCode)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }


  Future<void> _fetchProducts(
      FetchProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(FetchProductLoading());

    try {
      if (!authBloc.userState()) {
        emit(ProductAuthFailure(authError: true));
        emit(FetchProductFailure(
            error: "Oturumunuzun süresi doldu. Lütfen giriş yapın"));
        return;
      }

      User? user = auth.currentUser;
      QuerySnapshot query = await firestore
          .collection("products")
          .where("userId", isEqualTo: user?.uid)
          .get();

      if (query.docs.isNotEmpty) {
        List<Map<String, dynamic>> productData = query.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;  // Döküman UID'sini ekliyoruz
          return data;
        }).toList();

        emit(FetchProductSuccess(productData: productData));
      } else {
        emit(FetchProductFailure(error: "Müşteri bulunamadı"));
      }
    } catch (e) {
      emit(FetchProductFailure(error: "Müşteri bilgileri yüklenemedi"));
    }
  }



  Future<void> _onFetchProduct(
      FetchOneProductEvent event, Emitter<ProductState> emit) async {
    emit(FetchProductLoading());
    if (!authBloc.userState()) {
      // Kullanıcı oturumu yoksa, işlemi durdurup başka bir şey yapabiliriz.
      emit(AddProductFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
      emit(ProductAuthFailure(authError: true));
      return;
    }
    try {
      DocumentSnapshot doc =
      await firestore.collection('products').doc(event.productId).get();

      if (doc.exists) {
        // Veriyi Map<String, dynamic>? türünde alın
        Map<String, dynamic>? customerData = doc.data() as Map<String, dynamic>?;

        if (customerData != null) {
          // Bu veriyi bir liste içine alın
          List<Map<String, dynamic>> productDataList = [customerData];

          emit(FetchOneProductSuccess(productData: productDataList));
          await _fetchProducts(FetchProductEvent(), emit);
        } else {
          emit(FetchProductFailure(error: 'Müşteri verisi boş'));
        }
      } else {
        emit(FetchProductFailure(error: 'Müşteri bulunamadı'));
      }
    } catch (e) {
      emit(FetchProductFailure(error: 'Müşteri bilgileri yüklenemedi: $e'));
    }
  }

  Future<void> _mapDeleteProductEventToState(
      DeleteProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    try {
      // Kullanıcı oturumu kontrolü
      if (!authBloc.userState()) {
        // Kullanıcı oturumu yoksa, işlemi durdurup başka bir şey yapabiliriz.
        emit(AddProductFailure(error: 'oturumunuzun süresi doldu.Lütfen giriş yapın.'));
        emit(ProductAuthFailure(authError: true));
        return;
      }

      emit(AddProductInitial());
      print("Silinecek ürün ID: ${event.productId}");

      // Firestore'dan ürün mevcutluğunu kontrol edin
      DocumentSnapshot docSnapshot =
      await firestore.collection('products').doc(event.productId).get();

      if (!docSnapshot.exists) {
        throw Exception('Belge bulunamadı');
      }

      // Firestore'dan ürün silme işlemi
      await firestore.collection('products').doc(event.productId).delete();

      // Silme işlemi sonrası belgeyi tekrar kontrol edin
      docSnapshot =
      await firestore.collection('products').doc(event.productId).get();
      if (docSnapshot.exists) {
        throw Exception('Belge silinemedi');
      }

      emit(DeleteProductSuccess(message: 'Ürün başarıyla silindi.'));
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Silme hatası: $errorMessage'); // Hata mesajını konsola yazdırın
      emit(AddProductFailure(error: errorMessage));
    }
  }

}
