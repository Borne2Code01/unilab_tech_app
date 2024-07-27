class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String mobileNumber;
  final String city;
  final String dateCreated;
  final String createdBy;
  final String timestamp;
  final String userId;
  final bool isActive;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.mobileNumber,
    required this.city,
    required this.dateCreated,
    required this.createdBy,
    required this.timestamp,
    required this.userId,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'city': city,
      'dateCreated': dateCreated,
      'createdBy': createdBy,
      'timestamp': timestamp,
      'userId': userId,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      city: json['city'],
      dateCreated: json['dateCreated'],
      createdBy: json['createdBy'],
      timestamp: json['timestamp'],
      userId: json['userId'],
      isActive: json['isActive'] == 1,
    );
  }
}
