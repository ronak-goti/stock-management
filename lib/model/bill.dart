class Bill {
  final String billNumber;
  final String name;
  final double amount;
  final String date;

  Bill({
    required this.billNumber,
    required this.name,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'billNumber': billNumber,
    'name': name,
    'amount': amount,
    'date': date,
  };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    billNumber: json['billNumber'],
    name: json['name'],
    amount: json['amount'],
    date: json['date'],
  );
}