import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class Payment extends StatefulWidget {
  final Key paymentKey;
  const Payment(this.paymentKey,{super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  CardFieldInputDetails? details; 
  
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
          key: widget.paymentKey,
          onCardChanged: (CardFieldInputDetails? card) {
            if(card != null) {
              setState(() {
                details = card;
              });
            }
          },    
        ),
      ),
    );
  }
}