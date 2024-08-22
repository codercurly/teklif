import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String uid; // Add uid field here
  final String role;

  const AuthSuccess({required this.uid, required this.role}); // Include uid in the constructor

  @override
  List<Object?> get props => [uid, role]; // Update props to include uid
}

class AuthLoggedOut extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
class AuthenticatedState extends AuthState {
  final User user; // User sınıfı FirebaseAuth paketinden gelebilir veya kendi tanımlamanız olabilir.

  AuthenticatedState({required this.user});
}