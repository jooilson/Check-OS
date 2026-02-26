class DiarioModel {
  final String id;
  final String osId;
  final String numeroOs;
  final double numeroDiario;
  final String nomeCliente;
  final String? servico;
  final String? relatoCliente;
  final String? responsavel;
  final List<String> funcionarios;
  final DateTime data;
  final double? kmInicial;
  final double? kmFinal;
  final String? horaInicio;
  final String? intervaloInicio;
  final String? intervaloFim;
  final String? horaTermino;
  final bool osfinalizado;
  final bool garantia;
  final bool pendente;
  final String? pendenteDescricao;
  final String? relatoTecnico;
  final String? assinatura;
  final List<String> imagens;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiarioModel({
    required this.id,
    required this.osId,
    required this.numeroOs,
    required this.numeroDiario,
    required this.nomeCliente,
    this.servico,
    this.relatoCliente,
    this.responsavel,
    this.funcionarios = const [],
    required this.data,
    this.kmInicial,
    this.kmFinal,
    this.horaInicio,
    this.intervaloInicio,
    this.intervaloFim,
    this.horaTermino,
    this.osfinalizado = false,
    this.garantia = false,
    this.pendente = false,
    this.pendenteDescricao,
    this.relatoTecnico,
    this.assinatura,
    this.imagens = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'osId': osId,
      'numeroOs': numeroOs,
      'numeroDiario': numeroDiario,
      'nomeCliente': nomeCliente,
      'servico': servico,
      'relatoCliente': relatoCliente,
      'responsavel': responsavel,
      'funcionarios': funcionarios,
      'data': data.toIso8601String(),
      'kmInicial': kmInicial,
      'kmFinal': kmFinal,
      'horaInicio': horaInicio,
      'intervaloInicio': intervaloInicio,
      'intervaloFim': intervaloFim,
      'horaTermino': horaTermino,
      'osfinalizado': osfinalizado,
      'garantia': garantia,
      'pendente': pendente,
      'pendenteDescricao': pendenteDescricao,
      'relatoTecnico': relatoTecnico,
      'assinatura': assinatura,
      'imagens': imagens,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DiarioModel.fromMap(String id, Map<String, dynamic> map) {
    return DiarioModel(
      id: id,
      osId: map['osId'],
      numeroOs: map['numeroOs'],
      numeroDiario: map['numeroDiario'] != null
          ? (map['numeroDiario'] as num).toDouble()
          : 0.0,
      nomeCliente: map['nomeCliente'],
      servico: map['servico'],
      relatoCliente: map['relatoCliente'],
      responsavel: map['responsavel'],
      funcionarios: List<String>.from(map['funcionarios'] ?? []),
      data: DateTime.parse(map['data']),
      kmInicial: map['kmInicial'] != null
          ? (map['kmInicial'] as num).toDouble()
          : null,
      kmFinal:
          map['kmFinal'] != null ? (map['kmFinal'] as num).toDouble() : null,
      horaInicio: map['horaInicio'],
      intervaloInicio: map['intervaloInicio'],
      intervaloFim: map['intervaloFim'],
      horaTermino: map['horaTermino'],
      osfinalizado: map['osfinalizado'] ?? false,
      garantia: map['garantia'] ?? false,
      pendente: map['pendente'] ?? false,
      pendenteDescricao: map['pendenteDescricao'],
      relatoTecnico: map['relatoTecnico'],
      assinatura: map['assinatura'],
      imagens: List<String>.from(map['imagens'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  DiarioModel copyWith({
    String? id,
    String? osId,
    String? numeroOs,
    double? numeroDiario,
    String? nomeCliente,
    String? servico,
    String? relatoCliente,
    String? responsavel,
    List<String>? funcionarios,
    DateTime? data,
    double? kmInicial,
    double? kmFinal,
    String? horaInicio,
    String? intervaloInicio,
    String? intervaloFim,
    String? horaTermino,
    bool? osfinalizado,
    bool? garantia,
    bool? pendente,
    String? pendenteDescricao,
    String? relatoTecnico,
    String? assinatura,
    List<String>? imagens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiarioModel(
      id: id ?? this.id,
      osId: osId ?? this.osId,
      numeroOs: numeroOs ?? this.numeroOs,
      numeroDiario: numeroDiario ?? this.numeroDiario,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      servico: servico ?? this.servico,
      relatoCliente: relatoCliente ?? this.relatoCliente,
      responsavel: responsavel ?? this.responsavel,
      funcionarios: funcionarios ?? this.funcionarios,
      data: data ?? this.data,
      kmInicial: kmInicial ?? this.kmInicial,
      kmFinal: kmFinal ?? this.kmFinal,
      horaInicio: horaInicio ?? this.horaInicio,
      intervaloInicio: intervaloInicio ?? this.intervaloInicio,
      intervaloFim: intervaloFim ?? this.intervaloFim,
      horaTermino: horaTermino ?? this.horaTermino,
      osfinalizado: osfinalizado ?? this.osfinalizado,
      garantia: garantia ?? this.garantia,
      pendente: pendente ?? this.pendente,
      pendenteDescricao: pendenteDescricao ?? this.pendenteDescricao,
      relatoTecnico: relatoTecnico ?? this.relatoTecnico,
      assinatura: assinatura ?? this.assinatura,
      imagens: imagens ?? this.imagens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final map = toMap();
    map['id'] = id;
    return map;
  }

  factory DiarioModel.fromJson(Map<String, dynamic> json) {
    return DiarioModel(
      id: json['id'],
      osId: json['osId'],
      numeroOs: json['numeroOs'],
      numeroDiario: json['numeroDiario'] != null
          ? (json['numeroDiario'] as num).toDouble()
          : 0.0,
      nomeCliente: json['nomeCliente'],
      servico: json['servico'],
      relatoCliente: json['relatoCliente'],
      responsavel: json['responsavel'],
      funcionarios: List<String>.from(json['funcionarios'] ?? []),
      data: DateTime.parse(json['data']),
      kmInicial: json['kmInicial'] != null
          ? (json['kmInicial'] as num).toDouble()
          : null,
      kmFinal:
          json['kmFinal'] != null ? (json['kmFinal'] as num).toDouble() : null,
      horaInicio: json['horaInicio'],
      intervaloInicio: json['intervaloInicio'],
      intervaloFim: json['intervaloFim'],
      horaTermino: json['horaTermino'],
      osfinalizado: json['osfinalizado'] ?? false,
      garantia: json['garantia'] ?? false,
      pendente: json['pendente'] ?? false,
      pendenteDescricao: json['pendenteDescricao'],
      relatoTecnico: json['relatoTecnico'],
      assinatura: json['assinatura'],
      imagens: List<String>.from(json['imagens'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
