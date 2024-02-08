import 'package:fit_match/models/ejercicios.dart';

class SesionEntrenamiento {
  final int sessionId;
  final int templateId;
  final String sessionName;
  final DateTime sessionDate;
  final String? notes;
  int order;
  final List<EjerciciosDetalladosAgrupados>? ejerciciosDetalladosAgrupados;

  SesionEntrenamiento({
    required this.sessionId,
    required this.templateId,
    required this.sessionDate,
    required this.sessionName,
    this.notes,
    required this.order,
    this.ejerciciosDetalladosAgrupados,
  });

  factory SesionEntrenamiento.fromJson(Map<String, dynamic> json) {
    return SesionEntrenamiento(
      sessionId: json['session_id'],
      templateId: json['template_id'],
      sessionDate: DateTime.parse(json['session_date']),
      sessionName: json['session_name'],
      notes: json['notes'],
      order: json['order'],
      ejerciciosDetalladosAgrupados:
          (json['ejercicios_detallados_agrupados'] as List<dynamic>?)
              ?.map((e) => EjerciciosDetalladosAgrupados.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'template_id': templateId,
      'session_date': sessionDate.toIso8601String(),
      'session_name': sessionName,
      'notes': notes,
      'order': order,
      'ejercicios_detallados_agrupados': ejerciciosDetalladosAgrupados
          ?.map((ejerciciosDetalladosAgrupados) =>
              ejerciciosDetalladosAgrupados.toJson())
          .toList(),
    };
  }
}
