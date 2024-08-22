import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object> get props => [];
}

class AddProductInitial extends ProductState {}

class AddProductLoading extends ProductState {}

class AddProductSuccess extends ProductState {}

class AddProductFailure extends ProductState {
  final String error;


  AddProductFailure({required this.error, });

  @override
  List<Object> get props => [error];
}

class ProductAuthFailure extends ProductState {

  final bool authError;

  ProductAuthFailure({this.authError = false});

  @override
  List<Object> get props => [ authError];
}

class FetchProductLoading extends ProductState {}

class FetchProductSuccess extends ProductState {
  final List<Map<String, dynamic>> productData;

  FetchProductSuccess({required this.productData});

  @override
  List<Object> get props => [productData];
}
class FetchOneProductSuccess extends ProductState {
  final List<Map<String, dynamic>> productData;

  FetchOneProductSuccess({required this.productData});

  @override
  List<Object> get props => [productData];
}
class FetchProductFailure extends ProductState {
  final String error;

  FetchProductFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class UploadImageSuccess extends ProductState {
  final String downloadUrl;

  UploadImageSuccess({required this.downloadUrl});

  @override
  List<Object> get props => [downloadUrl];
}

class UploadImageFailure extends ProductState {
  final String error;

  UploadImageFailure({required this.error});

  @override
  List<Object> get props => [error];
}
class DeleteProductSuccess extends ProductState {
  final String message;

  DeleteProductSuccess({required this.message});

  @override
  List<Object> get props => [message];
}