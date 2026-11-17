class Dispositivo {
  const Dispositivo({
    required this.id,
    required this.name,
    this.location = '',
  });

  final String id;
  final String name;
  final String location;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'location': location,
      };

  factory Dispositivo.fromMap(Map<String, dynamic> map) => Dispositivo(
        id: map['id'] as String,
        name: map['name'] as String,
        location: map['location'] as String? ?? '',
      );
}

class Procedimiento {
  const Procedimiento({
    required this.id,
    required this.deviceId,
    required this.title,
    required this.firstStepId,
  });

  final String id;
  final String deviceId;
  final String title;
  final String firstStepId;

  Map<String, dynamic> toMap() => {
        'id': id,
        'device_id': deviceId,
        'title': title,
        'first_step_id': firstStepId,
      };

  factory Procedimiento.fromMap(Map<String, dynamic> map) => Procedimiento(
        id: map['id'] as String,
        deviceId: map['device_id'] as String,
        title: map['title'] as String,
        firstStepId: map['first_step_id'] as String,
      );
}

class PasoRunbook {
  const PasoRunbook({
    required this.id,
    required this.procedureId,
    required this.instruction,
    this.yesNextStepId,
    this.noNextStepId,
    this.isTerminal = false,
  });

  final String id;
  final String procedureId;
  final String instruction;
  final String? yesNextStepId;
  final String? noNextStepId;
  final bool isTerminal;

  Map<String, dynamic> toMap() => {
        'id': id,
        'procedure_id': procedureId,
        'instruction': instruction,
        'yes_next_step_id': yesNextStepId,
        'no_next_step_id': noNextStepId,
        'is_terminal': isTerminal ? 1 : 0,
      };

  factory PasoRunbook.fromMap(Map<String, dynamic> map) => PasoRunbook(
        id: map['id'] as String,
        procedureId: map['procedure_id'] as String,
        instruction: map['instruction'] as String,
        yesNextStepId: map['yes_next_step_id'] as String?,
        noNextStepId: map['no_next_step_id'] as String?,
        isTerminal: (map['is_terminal'] as int? ?? 0) == 1,
      );
}

class Contacto {
  const Contacto({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
  });

  final String id;
  final String name;
  final String role;
  final String phone;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
      };

  factory Contacto.fromMap(Map<String, dynamic> map) => Contacto(
        id: map['id'] as String,
        name: map['name'] as String,
        role: map['role'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
      );
}

