class LogModel {
  final String id;
  final String userId;
  final String userEmail;
  final String? userName;
  final String? employeeId;
  final String? employeeName;
  final DateTime timestamp;
  final String action;
  final String osId;
  final String osNumero;
  final String description;

  LogModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    this.userName,
    this.employeeId,
    this.employeeName,
    required this.timestamp,
    required this.action,
    required this.osId,
    required this.osNumero,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'osId': osId,
      'osNumero': osNumero,
      'description': description,
    };
  }

  factory LogModel.fromMap(String id, Map<String, dynamic> map) {
    return LogModel(
      id: id,
      userId: map['userId'],
      userEmail: map['userEmail'],
      userName: map['userName'],
      employeeId: map['employeeId'],
      employeeName: map['employeeName'],
      timestamp: DateTime.parse(map['timestamp']),
      action: map['action'],
      osId: map['osId'],
      osNumero: map['osNumero'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = toMap();
    map['id'] = id;
    return map;
  }

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      userName: json['userName'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      timestamp: DateTime.parse(json['timestamp']),
      action: json['action'],
      osId: json['osId'],
      osNumero: json['osNumero'],
      description: json['description'],
    );
  }
}