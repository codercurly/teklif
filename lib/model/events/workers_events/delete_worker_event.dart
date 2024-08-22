import 'package:teklif/model/events/workers_events/add_worker_event.dart';

class DeleteWorkerEvent extends WorkerEvent {
  final String workerId;

  DeleteWorkerEvent({required this.workerId});

  @override
  List<Object?> get props => [workerId];
}