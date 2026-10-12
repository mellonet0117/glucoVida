import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    tz.initializeTimeZones();

    final zona = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(zona.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> programarDiario({
    required int id,
    required String titulo,
    required String cuerpo,
    required int hora,
    required int minuto,
  }) async {
    final ahora = tz.TZDateTime.now(tz.local);

    var fecha = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day,
      hora,
      minuto,
    );

    if (fecha.isBefore(ahora)) {
      fecha = fecha.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: titulo,
      body: cuerpo,
      scheduledDate: fecha,

      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios_glucovida',
          'Recordatorios GlucoVida',
          channelDescription: 'Recordatorios de salud de GlucoVida',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),

      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<bool> solicitarPermiso() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final resultado = await androidPlugin?.requestNotificationsPermission();

    return resultado ?? true;
  }

  static Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancelar(int id) async {
    await _plugin.cancel(id: id);
  }
}
