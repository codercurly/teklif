import 'package:equatable/equatable.dart';

abstract class ServiceState extends Equatable {
  @override
  List<Object> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceSuccess extends ServiceState {}

class ServiceFailure extends ServiceState {
  final String error;

  ServiceFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class FetchServicesLoading extends ServiceState {}

class FetchServicesSuccess extends ServiceState {
  final List<Map<String, dynamic>> serviceData;

  FetchServicesSuccess({required this.serviceData});

  @override
  List<Object> get props => [serviceData];
}

class FetchOneServiceSuccess extends ServiceState {
  final List<Map<String, dynamic>> serviceData;

  FetchOneServiceSuccess({required this.serviceData});

  @override
  List<Object> get props => [serviceData];
}

class FetchServiceFailure extends ServiceState {
  final String error;

  FetchServiceFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class ServiceAuthFailure extends ServiceState {
  final bool authError;

  ServiceAuthFailure({this.authError = false});

  @override
  List<Object> get props => [authError];
}

class DeleteServiceSuccess extends ServiceState {
  final String message;

  DeleteServiceSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
