import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:alert_world/features/alerts/domain/usecases/get_alertas.dart';
import 'package:alert_world/features/alerts/domain/usecases/toggle_like.dart';
import 'package:alert_world/features/alerts/domain/usecases/create_alert.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final GetAlertas getAlertasUseCase;
  final ToggleLike toggleLikeUseCase;
  final CreateAlert createAlertUseCase;

  AlertBloc({
    required this.getAlertasUseCase,
    required this.toggleLikeUseCase,
    required this.createAlertUseCase,
  }) : super(AlertInitial()) {
    on<LoadAlerts>(_onLoadAlertas);
    on<ToggleLikeEvent>(_onToggleLike);
    on<SubmitAlertEvent>(_onSubmitAlert);
  }

  Future<void> _onLoadAlertas(
      LoadAlerts event,
      Emitter<AlertState> emit,
      ) async {
    emit(AlertLoading());
    final result = await getAlertasUseCase();
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) => emit(AlertLoaded(alerts)),
    );
  }

  Future<void> _onToggleLike(
      ToggleLikeEvent event,
      Emitter<AlertState> emit,
      ) async {
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      final alerts = List<AlertEntity>.from(currentState.alerts);

      final index = alerts.indexWhere((a) => a.id == event.alertId);
      if (index != -1) {
        final previousAlert = alerts[index];
        final optimisticAlert = previousAlert.copyWith(
          likedByUser: !previousAlert.likedByUser,
          likes: previousAlert.likedByUser
              ? previousAlert.likes - 1
              : previousAlert.likes + 1,
        );
        alerts[index] = optimisticAlert;
        emit(AlertLoaded(alerts));

        final result = await toggleLikeUseCase(
          alertId: event.alertId,
          userId: event.userId,
          token: event.token,
        );

        result.fold(
          (failure) {
            // Revertir al estado anterior si falla
            alerts[index] = previousAlert;
            emit(AlertLoaded(alerts));
          },
          (updatedAlert) {
            alerts[index] = updatedAlert;
            emit(AlertLoaded(alerts));
          },
        );
      }
    }
  }
Future<void> _onSubmitAlert(
  SubmitAlertEvent event,
  Emitter<AlertState> emit,
) async {
  emit(AlertSubmitting());

  final result = await createAlertUseCase(event.alert);

  await result.fold(
    (failure) {
      emit(AlertError(failure.message));
    },
    (_) async {
      emit(AlertSuccess());

      // Aquí cargas la lista actualizada de alertas
      final alertsResult = await getAlertasUseCase();

      alertsResult.fold(
        (failure) => emit(AlertError(failure.message)),
        (alerts) => emit(AlertLoaded(alerts)), // emite la lista actualizada
      );
    },
  );
}

}
