enum AppointmentType {
  inPerson,
  online,
  homeVisit,
}

extension AppointmentTypeExtension on AppointmentType {
  String get value {
    switch (this) {
      case AppointmentType.inPerson:
        return 'In Person';
      case AppointmentType.online:
        return 'Online';
      case AppointmentType.homeVisit:
        return 'Home Visit';
    }
  }
}
