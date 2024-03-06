class PaymentIntentData {
  final String clientSecret;
  final String customerId;

  PaymentIntentData({
    required this.clientSecret,
    required this.customerId,
  });

  factory PaymentIntentData.fromJson(Map<String, dynamic> json) {
    return PaymentIntentData(
      clientSecret: json['clientSecret'],
      customerId: json['customerId'],
    );
  }
}