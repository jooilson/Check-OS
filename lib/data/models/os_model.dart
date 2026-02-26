class OsModel {
  final String id;
  final String numeroOs;
  final String nomeCliente;
  final String servico;
  final String relatoCliente;
  final String responsavel;
  final bool temPedido;
  final String? numeroPedido;
  final List<String> funcionarios;
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
  final double? totalKm;
  final String? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OsModel({
    required this.id,
    required this.numeroOs,
    required this.nomeCliente,
    required this.servico,
    required this.relatoCliente,
    required this.responsavel,
    this.temPedido = false,
    this.numeroPedido,
    this.funcionarios = const [],
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
    this.totalKm,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'numeroOs': numeroOs,
      'nomeCliente': nomeCliente,
      'servico': servico,
      'relatoCliente': relatoCliente,
      'responsavel': responsavel,
      'temPedido': temPedido,
      'numeroPedido': numeroPedido,
      'funcionarios': funcionarios,
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
      'totalKm': totalKm,
      'companyId': companyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OsModel.fromMap(String id, Map<String, dynamic> map) {
    return OsModel(
      id: id,
      numeroOs: map['numeroOs'],
      nomeCliente: map['nomeCliente'],
      servico: map['servico'],
      relatoCliente: map['relatoCliente'],
      responsavel: map['responsavel'],
      temPedido: map['temPedido'] ?? false,
      numeroPedido: map['numeroPedido'],
      funcionarios: List<String>.from(map['funcionarios'] ?? []),
      kmInicial: map['kmInicial'] != null
          ? (map['kmInicial'] as num).toDouble()
          : null,
      kmFinal: map['kmFinal'] != null
          ? (map['kmFinal'] as num).toDouble()
          : null,
      totalKm: map['totalKm'] != null ? (map['totalKm'] as num).toDouble() : null,
      companyId: map['companyId'],
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
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = toMap();
    map['id'] = id;
    return map;
  }

  factory OsModel.fromJson(Map<String, dynamic> json) {
    return OsModel(
      id: json['id'],
      numeroOs: json['numeroOs'],
      nomeCliente: json['nomeCliente'],
      servico: json['servico'],
      relatoCliente: json['relatoCliente'],
      responsavel: json['responsavel'],
      temPedido: json['temPedido'] ?? false,
      numeroPedido: json['numeroPedido'],
      funcionarios: List<String>.from(json['funcionarios'] ?? []),
      kmInicial: json['kmInicial'] != null
          ? (json['kmInicial'] as num).toDouble()
          : null,
      kmFinal: json['kmFinal'] != null
          ? (json['kmFinal'] as num).toDouble()
          : null,
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
      totalKm: json['totalKm'] != null ? (json['totalKm'] as num).toDouble() : null,
      companyId: json['companyId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  OsModel copyWith({
    String? id,
    String? numeroOs,
    String? nomeCliente,
    String? servico,
    String? relatoCliente,
    String? responsavel,
    bool? temPedido,
    String? numeroPedido,
    List<String>? funcionarios,
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
    double? totalKm,
    String? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OsModel(
      id: id ?? this.id,
      numeroOs: numeroOs ?? this.numeroOs,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      servico: servico ?? this.servico,
      relatoCliente: relatoCliente ?? this.relatoCliente,
      responsavel: responsavel ?? this.responsavel,
      temPedido: temPedido ?? this.temPedido,
      numeroPedido: numeroPedido ?? this.numeroPedido,
      funcionarios: funcionarios ?? this.funcionarios,
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
      totalKm: totalKm ?? this.totalKm,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
