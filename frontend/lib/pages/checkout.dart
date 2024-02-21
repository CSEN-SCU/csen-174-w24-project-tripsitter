import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  Map<String, dynamic>? paymentIntent;

  createPaymentIntent() async {
    try{
      // Connect to Stripe API from backend
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
      if (_user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _user != null ? _checkoutButton() : _returnButton(),
      );
  }

  Widget _returnButton() {
    return Center(
        child: Column(
          children: [
            const Center(
              child: Text("You are not Signed In!"),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: const Text("Return to Home"),),
          ],
        )
    );
  }

  Widget _checkoutButton() {
    return Center(child: SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: makePayment, child: const Text("Checkout"),
      ),
    ),);
  }

  void displayPaymentSheet () async{
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print("Payment sheet display failed");
    }
  }

  void makePayment () async {
    try {
      paymentIntent = await createPaymentIntent();

      var googlePay = const PaymentSheetGooglePay(
          merchantCountryCode: "US",
        currencyCode: "US",
        testEnv: true,
      );
      Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!["client_secret"],
        style: ThemeMode.dark,
        merchantDisplayName: "TripSitter",
        googlePay: googlePay,
      ));
      displayPaymentSheet();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
