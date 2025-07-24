import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alert_world/features/alerts/domain/repositories/alert_repository.dart';
import 'alert_state.dart';
import 'alert_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:alert_world/features/alerts/domain/usecases/get_alertas.dart';
import 'package:alert_world/features/alerts/domain/usecases/toggle_like.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
import 'package:alert_world/core/error/failures.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final GetAlertas getAlertasUseCase;
  final ToggleLike toggleLikeUseCase;

  AlertBloc({
    required this.getAlertasUseCase,
    required this.toggleLikeUseCase,
  }) : super(AlertInitial()) {
    on<LoadAlerts>(_onLoadAlertas);
    on<ToggleLikeEvent>(_onToggleLike);
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
      print('ToggleLikeEvent recibido para alerta ID: ${event.alertId}');
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

}