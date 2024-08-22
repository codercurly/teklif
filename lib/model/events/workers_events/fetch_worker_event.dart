import 'package:teklif/model/events/workers_events/add_worker_event.dart';


class FetchWorkerEvent extends WorkerEvent {

}

class FetchworkerUpdateEvent extends WorkerEvent {
  final String workerId;

  FetchworkerUpdateEvent({required this.workerId});
}

