enum DriverTripState {
  offline,

  online,

  incomingRide,

  accepted,

  arriving,

  inProgress,

  finished,

  cancelled,

  blocked,

  loading,

  error,
}

extension DriverTripStateExtension on DriverTripState {
  bool get isOffline => this == DriverTripState.offline;

  bool get isOnline => this == DriverTripState.online;

  bool get hasIncomingRide => this == DriverTripState.incomingRide;

  bool get isAccepted => this == DriverTripState.accepted;

  bool get isArriving => this == DriverTripState.arriving;

  bool get isInProgress => this == DriverTripState.inProgress;

  bool get isFinished => this == DriverTripState.finished;

  bool get isCancelled => this == DriverTripState.cancelled;

  bool get isBlocked => this == DriverTripState.blocked;

  bool get isLoading => this == DriverTripState.loading;

  bool get isError => this == DriverTripState.error;

  bool get hasActiveRide {
    return this == DriverTripState.incomingRide ||
        this == DriverTripState.accepted ||
        this == DriverTripState.arriving ||
        this == DriverTripState.inProgress;
  }

  String get label {
    switch (this) {
      case DriverTripState.offline:
        return 'Offline';

      case DriverTripState.online:
        return 'Online';

      case DriverTripState.incomingRide:
        return 'Nova corrida';

      case DriverTripState.accepted:
        return 'Corrida aceita';

      case DriverTripState.arriving:
        return 'Chegando ao passageiro';

      case DriverTripState.inProgress:
        return 'Corrida em andamento';

      case DriverTripState.finished:
        return 'Corrida finalizada';

      case DriverTripState.cancelled:
        return 'Corrida cancelada';

      case DriverTripState.blocked:
        return 'Motorista bloqueado';

      case DriverTripState.loading:
        return 'Carregando';

      case DriverTripState.error:
        return 'Erro';
    }
  }
}