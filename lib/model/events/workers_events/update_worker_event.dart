import 'package:teklif/model/events/customer_events/add_customer_event.dart';
import 'package:teklif/model/events/workers_events/add_worker_event.dart';

class UpdateWorkerEvent extends WorkerEvent {
  final String workerId;
  final String workerNo;
  final String workerName;
  final String workName;
  final String workerMail;
  final String workerBusiness;
  final String workerPhone;
  final String workerRole;

  const UpdateWorkerEvent({
    required this.workerId,
    required this.workerNo,
    required this.workerName,
    required this.workName,
    required this.workerMail,
    required this.workerBusiness,
    required this.workerPhone,
    required this.workerRole,
  });

  @override
  List<Object> get props => [
        workerId,
        workerNo,
        workerName,
        workName,
        workerMail,
        workerBusiness,
        workerPhone,
        workerRole
      ];
}
class FetchWorkerUpdateEvent extends WorkerEvent {
  final String workerId;

  FetchWorkerUpdateEvent({required this.workerId});
}
