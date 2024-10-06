import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart'; // Snackbar için Material import ediyoruz
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teklif/model/events/auth_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/auth_state.dart';// Giriş sayfasının importu

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseStorage _firebaseStorage;

  AuthBloc({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
    required FirebaseStorage firebaseStorage,
  })   : _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore,
        _firebaseStorage= firebaseStorage,

        super(AuthInitial()) {
    on<RegisterEvent>(_mapRegisterEventToState);
    on<LoginEvent>(_mapLoginEventToState);
    on<LogoutEvent>(_mapLogoutEventToState);

  }


  Future<void> _mapRegisterEventToState(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Kayıt olurken yükleme durumu

    try {
      // Kullanıcıyı oluştur
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        String imageUrl = '';
        if (event.image.isNotEmpty) {
          imageUrl = await _uploadProfil(event.image);
        }
        // Kullanıcı verisini Firestore'a kaydet
        await _firebaseFirestore.collection('users').doc(user.uid).set({
          'name': event.name,
          'phone': event.phone,
          'role': event.role,
          'businessName': event.businessName ?? '',
          'businessAddress': event.businessAddress ?? '',
          'email': event.email,
          'image': imageUrl ??'', // Resim URL'si
          'createdAt': DateTime.now(),
        });

        emit(AuthSuccess(uid: user.uid, role: event.role));
      } else {
        emit(AuthFailure(error: 'Failed to create user'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<String> _uploadProfil(String imagePath) async {
    try {

      User? user = _firebaseAuth.currentUser;

      File imageFile = File(imagePath);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Storage'da klasöre göre resmi yükle
      TaskSnapshot snapshot = await _firebaseStorage
          .ref()
          .child('profil/${user?.uid}/$fileName')
          .putFile(imageFile);

      // Yükleme işleminden sonra URL al
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      throw Exception('Resim yükleme hatası: $e');
    }
  }



}
