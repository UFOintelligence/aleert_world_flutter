import 'package:alert_world/features/alerts/data/repositories/alert_repository_impl.dart';
import 'package:alert_world/features/alerts/domain/repositories/alert_repository.dart';
import 'package:alert_world/ui/page/map_selector_page.dart';
import 'package:alert_world/ui/page/alert_list_page.dart';
import 'package:alert_world/ui/page/alert_map_page.dart';
import 'package:alert_world/ui/page/profile_page.dart';
import 'package:alert_world/ui/page/profile_update_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'bloc/auth/auth_bloc.dart';
import 'bloc/alerts/alert_bloc.dart';
import 'bloc/alerts/alert_event.dart';
import 'ui/page/login_page.dart';
import 'ui/page/register_page.dart';
import 'ui/page/home_page.dart';
import 'features/alerts/presentation/pages/report_incident_page.dart';
import 'package:alert_world/features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Captura errores globales no atrapados
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };


  // Inicializa el contenedor de inyección (registra dependencias)
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUser: di.sl(),
            registerUser: di.sl(),
          ),
        ),
        BlocProvider<AlertBloc>(
          // Obtiene la instancia del AlertBloc inyectado con el repositorio ya dentro
          create: (_) => di.sl<AlertBloc>()..add(LoadAlerts()),
        ),
      ],
      child: MaterialApp(

        title: 'Alert World',
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
          '/alert_list': (_) => const AlertList(),
          '/alert_map': (_) => const AlertMapPage(),

          '/map_selector': (_) => const MapSelectorPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            final args = settings.arguments as Map?;
            if (args == null || !args.containsKey('user')) {
              return _errorRoute('Faltan argumentos para la ruta /home');
            }
            final UserModel user = args['user'] as UserModel;
            return MaterialPageRoute(builder: (_) => HomePage(user: user));
          }

          if (settings.name == '/report') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('userName') || !args.containsKey('userId')) {
              return _errorRoute('Faltan argumentos para la ruta /crear-alerta');
            }
            return MaterialPageRoute(
              builder: (_) => ReportIncidentPage(
                userName: args['userName'] as String,
                userId: args['userId'] as int,
              ),
            );
          }

          if (settings.name == '/profile') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('user') || !args.containsKey('alerts')) {
              return _errorRoute('Faltan argumentos para la ruta /profile');
            }
            final user = args['user'] as UserModel;
            final alerts = args['alerts'] as List<Map<String, dynamic>>;
            return MaterialPageRoute(
              builder: (_) => UserProfilePage(
                user: user,
                alerts: alerts,
              ),
            );
          }

          if (settings.name == '/user_update') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('user')) {
              return _errorRoute('Faltan argumentos para la ruta /user_update');
            }
            final user = args['user'] as UserModel;
            return MaterialPageRoute(
              builder: (_) => UserProfileUpdatePage(user: user),
            );
          }

          return _errorRoute('Ruta no encontrada: ${settings.name}');
        },
      ),
    );
  }

  Route _errorRoute(String mensaje) {

    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(mensaje, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}