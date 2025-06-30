import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alert_world/features/alerts/domain/repositories/alert_repository.dart';
import 'alert_state.dart';
import 'alert_event.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository repository;

  AlertBloc(this.repository) : super(AlertInitial()) {
    on<LoadAlerts>((event, emit) async {
      emit(AlertLoading());

      final result = await repository.getAlertas();

      result.fold(
        (failure) => emit(AlertError(failure.message)),
        (alertas) => emit(AlertLoaded(alertas)),
      );
    });

    on<CreateAlert>((event, emit) async {
      // En caso de que luego implementes createAlert
    });
  }
}
