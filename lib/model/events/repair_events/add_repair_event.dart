import 'package:equatable/equatable.dart';

abstract class RepairEvent extends Equatable {
  const RepairEvent();

  @override
  List<Object> get props => [];
}

class AddRepairEvent extends RepairEvent {
  final String repairName;
  final String repairDescription;
  final String repairDuration;
  final double repairPrice;
  final DateTime repairDate;
  final String repairCurrency;
  final String deviceName;
  final String deviceModel;
  final String serialNumber;
  final String problemDescription;
  final bool warrantyStatus;
  final String repairStatus;

  const AddRepairEvent({
    required this.repairName,
    required this.repairDescription,
    required this.repairDuration,
    required this.repairPrice,
    required this.repairDate,
    required this.deviceName,
    required this.deviceModel,
    required this.serialNumber,
    required this.problemDescription,
    required this.warrantyStatus,
    required this.repairStatus,
    required this.repairCurrency

  });

  @override
  List<Object> get props => [
    repairName,
    repairDescription,
    repairDuration,
    repairPrice,
    repairDate,
    deviceName,
    deviceModel,
    serialNumber,
    problemDescription,
    warrantyStatus,
    repairStatus,
    repairCurrency
  ];
}
