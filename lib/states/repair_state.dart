import 'package:equatable/equatable.dart';

abstract class RepairState extends Equatable {
  @override
  List<Object> get props => [];
}

class RepairInitial extends RepairState {}

class RepairLoading extends RepairState {}

class RepairSuccess extends RepairState {}

class RepairFailure extends RepairState {
  final String error;

  RepairFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class FetchRepairsLoading extends RepairState {}

class FetchRepairsSuccess extends RepairState {
  final List<Map<String, dynamic>> repairData;

  FetchRepairsSuccess({required this.repairData});

  @override
  List<Object> get props => [repairData];
}

class FetchOneRepairSuccess extends RepairState {
  final List<Map<String, dynamic>> repairData;

  FetchOneRepairSuccess({required this.repairData});

  @override
  List<Object> get props => [repairData];
}

class FetchRepairFailure extends RepairState {
  final String error;

  FetchRepairFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class RepairAuthFailure extends RepairState {
  final bool authError;

  RepairAuthFailure({this.authError = false});

  @override
  List<Object> get props => [authError];
}




class DeleteRepairSuccess extends RepairState {
  final String message;

  DeleteRepairSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
