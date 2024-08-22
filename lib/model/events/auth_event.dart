import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String role;
  final String email;
  final String password;
  final String name;
  final String phone;
  final String  image;
  final String? businessName;
  final String? businessAddress;

  RegisterEvent({
    required this.role,
    required this.email,
    required this.password,
    required this.name,
    required this.image,
    required this.phone,
    this.businessName,
    this.businessAddress,
  });

  @override
  List<Object> get props => [
    role,
    email,
    password,
    name,
    phone,
    image,
    businessName ?? '',
    businessAddress ?? '',
  ];
}


class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final User user;

  LoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

