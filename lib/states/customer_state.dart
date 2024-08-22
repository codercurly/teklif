import 'package:equatable/equatable.dart';

abstract class CustomerState extends Equatable {
  @override
  List<Object> get props => [];
}

class CustomersInitial extends CustomerState {}

class CustomersLoading extends CustomerState {}

class CustomersSuccess extends CustomerState {}

class CustomersFailure extends CustomerState {
  final String error;

  CustomersFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class FetchCustomersLoading extends CustomerState {}

class FetchCustomersSuccess extends CustomerState {
  final List<Map<String, dynamic>> customerData;

  FetchCustomersSuccess({required this.customerData});

  @override
  List<Object> get props => [customerData];
}
class FetchOneCustomersSuccess extends CustomerState {
  final List<Map<String, dynamic>> customerData;

  FetchOneCustomersSuccess({required this.customerData});

  @override
  List<Object> get props => [customerData];
}
class FetchCustomerFailure extends CustomerState {
  final String error;

  FetchCustomerFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class CustomerAuthFailure extends CustomerState {

  final bool authError;

  CustomerAuthFailure({this.authError = false});

  @override
  List<Object> get props => [ authError];
}

class CustomerImgSuccess extends CustomerState {
  final String downloadUrl;

  CustomerImgSuccess({required this.downloadUrl});

  @override
  List<Object> get props => [downloadUrl];
}

class CustomerImgFailure extends CustomerState {
  final String error;

  CustomerImgFailure({required this.error});

  @override
  List<Object> get props => [error];
}
class DeleteCustomerSuccess extends CustomerState {
  final String message;

  DeleteCustomerSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
class SuccessCustomerLogo extends CustomerState {
  final String msg;

  SuccessCustomerLogo({required this.msg});

  @override
  List<Object> get props => [msg];
}
