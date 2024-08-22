import 'package:equatable/equatable.dart';

abstract class WorkerState extends Equatable {
  @override
  List<Object> get props => [];
}

class WorkersInitial extends WorkerState {}

class WorkersLoading extends WorkerState {}

class WorkersSuccess extends WorkerState {
  final String? msg;

  WorkersSuccess({ this.msg});

  @override
  List<Object> get props => [msg??""];
}

class WorkersFailure extends WorkerState {
  final String error;

  WorkersFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class FetchWorkersLoading extends WorkerState {}

class FetchWorkersSuccess extends WorkerState {
  final List<Map<String, dynamic>> workerData;

  FetchWorkersSuccess({required this.workerData});

  @override
  List<Object> get props => [workerData];
}

class FetchOneWorkerSuccess extends WorkerState {
  final List<Map<String, dynamic>> workerData;

  FetchOneWorkerSuccess({required this.workerData});

  @override
  List<Object> get props => [workerData];
}

class FetchWorkerFailure extends WorkerState {
  final String error;

  FetchWorkerFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class WorkerAuthFailure extends WorkerState {
  final bool authError;

  WorkerAuthFailure({this.authError = false});

  @override
  List<Object> get props => [authError];
}

class WorkerImgSuccess extends WorkerState {
  final String downloadUrl;

  WorkerImgSuccess({required this.downloadUrl});

  @override
  List<Object> get props => [downloadUrl];
}

class WorkerImgFailure extends WorkerState {
  final String error;

  WorkerImgFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeleteWorkerSuccess extends WorkerState {
  final String message;

  DeleteWorkerSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SuccessWorkerLogo extends WorkerState {
  final String msg;

  SuccessWorkerLogo({required this.msg});

  @override
  List<Object> get props => [msg];
}
