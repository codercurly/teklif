import 'package:equatable/equatable.dart';

abstract class BusinessState extends Equatable {
  @override
  List<Object> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessSuccess extends BusinessState {
  final String? msg;

  BusinessSuccess({this.msg});

  @override
  List<Object> get props => [msg ?? ""];
}

class BusinessFailure extends BusinessState {
  final String error;

  BusinessFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class FetchBusinessesLoading extends BusinessState {}

class FetchBusinessesSuccess extends BusinessState {
  final List<Map<String, dynamic>> businessData;

  FetchBusinessesSuccess({required this.businessData});

  @override
  List<Object> get props => [businessData];
}

class FetchOneBusinessSuccess extends BusinessState {
  final List<Map<String, dynamic>> businessData;

  FetchOneBusinessSuccess({required this.businessData});

  @override
  List<Object> get props => [businessData];
}

class FetchBusinessFailure extends BusinessState {
  final String error;

  FetchBusinessFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class BusinessAuthFailure extends BusinessState {
  final bool authError;

  BusinessAuthFailure({this.authError = false});

  @override
  List<Object> get props => [authError];
}

class BusinessImgSuccess extends BusinessState {
  final String downloadUrl;

  BusinessImgSuccess({required this.downloadUrl});

  @override
  List<Object> get props => [downloadUrl];
}

class BusinessImgFailure extends BusinessState {
  final String error;

  BusinessImgFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeleteBusinessSuccess extends BusinessState {
  final String message;

  DeleteBusinessSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SuccessBusinessLogo extends BusinessState {
  final String msg;

  SuccessBusinessLogo({required this.msg});

  @override
  List<Object> get props => [msg];
}
