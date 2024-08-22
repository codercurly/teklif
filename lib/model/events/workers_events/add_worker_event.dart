import 'package:equatable/equatable.dart';

abstract class WorkerEvent extends Equatable {
  const WorkerEvent();

  @override
  List<Object?> get props => [];
}


class SubmitWorkerEvent extends WorkerEvent {
  final String workerNo;
  final String workerName;
  final String workName;
  final String workerMail;
  final String workerBusiness;
  final String workerPhone;
  final String workerRole;

  SubmitWorkerEvent({
    required this.workerNo,
    required this.workerName,
    required this.workName,
    required this.workerMail,
    required this.workerBusiness,
    required this.workerPhone,
    required this.workerRole,
  });

  @override
  List<Object?> get props => [
    workerNo, workerName, workName, workerMail,
    workerBusiness, workerPhone, workerRole];
}
