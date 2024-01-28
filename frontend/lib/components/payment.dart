import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 100,
          maxWidth: 500,
        ),
        child: CardField(
          onCardChanged: (CardFieldInputDetails? card) {
            if(card != null) {
            }
          },    
        ),
      ),
    );
  }
}