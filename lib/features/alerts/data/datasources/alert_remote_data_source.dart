import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertEntity>> obtenerAlertas();
  Future<Map<String, dynamic>> toggleLike(int alertId, String token, String userId);
  Future<void> createAlertRemote(Map<String, dynamic> data);
}
