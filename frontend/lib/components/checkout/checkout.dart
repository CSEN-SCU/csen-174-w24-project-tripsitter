import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tripsitter/classes/payment.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/confirmation.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/components/checkout/trip_summary.dart';
import 'package:tripsitter/helpers/api.dart';

class CheckoutPage extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  const CheckoutPage({required this.trip, required this.profiles, super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  Trip get trip => widget.trip;
  CardFieldInputDetails? cardDetails;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }
    bool split = trip.usingSplitPayments;
    String uid = user.uid;
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: AbsorbPointer(
        absorbing: loading,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: ListView(
                children: [
                  Text("Checkout Page"),
                  TripSummary(
                    trip: trip,
                    split: split,
                    uid: uid,
                    profiles: widget.profiles,
                  ),
                  Text("${split ? "Your total" : "Total price"}: \$${split ? trip.userTotalPrice(uid) : trip.totalPrice}"),
                  if((split ? trip.rentalCars.where((r) => r.members.contains(uid)) : trip.rentalCars).isNotEmpty || (split ? trip.activities.where((a) => a.participants.contains(uid)) : trip.activities).isNotEmpty)
                    ...[
                      Container(height: 50),
                      Text("Note: Only flights and hotels can be paid directly through TripSitter. After purchasing, you will be directed to the rental car and activity websites to complete your purchase."),
                      Text("Amount owed to TripSitter: \$${split ? trip.userStripePrice(uid) : trip.stripePrice}")
                    ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 100,
                    ),
                    child: CardField(
                      key: Key("payment-${trip.id}"),
                      onCardChanged: (CardFieldInputDetails? card) {
                        if(card != null) {
                          setState(() {
                            cardDetails = card;
                          });
                        }
                      },    
                    ),
                  ),
                  if(cardDetails?.complete ?? false)
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        PaymentIntentData data = await TripsitterApi.createPaymentIntent(user.uid, trip);
                        print("Payment intent data created ${data.clientSecret}");
                        try {
                          PaymentIntent intent = await Stripe.instance.confirmPayment(
                            paymentIntentClientSecret: data.clientSecret,
                            data: PaymentMethodParams.card(paymentMethodData: PaymentMethodData(
                              billingDetails: BillingDetails(
                                name: user.displayName,
                                email: user.email,
                              ),
                            )),
                          );
                          print("Intent processed");
                          print(intent.amount);
                          print(intent.receiptEmail);
                          print(intent.status);
          
                          if(intent.status == PaymentIntentsStatus.Succeeded) {
                            trip.freeze();
                            if(trip.usingSplitPayments) {
                              trip.paymentsComplete[user.uid] = true;
                              // check if all users on the trip have paid
                              bool allPaid = true;
                              for(String uid in trip.uids) {
                                if(trip.paymentsComplete[uid] != true) {
                                  allPaid = false;
                                  break;
                                }
                              }
                              if(allPaid) {
                                await trip.complete();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConfirmationPage(trip: trip, profiles: widget.profiles)));
                              }
                              else {
                                await trip.save();
                                Navigator.pop(context);
                              }
                            }
                            else {
                              await trip.complete();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConfirmationPage(trip: trip, profiles: widget.profiles)));
                            }
                            if(mounted) {
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                          else if(mounted){
                            await showDialog(
                              context: context, 
                              builder: (context) => AlertDialog(
                                title: const Text("Payment failed"),
                                content: const Text("Payment failed, please try again"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }, 
                                    child: const Text("OK")
                                  ),
                                ],
                              )
                            );
                            if(mounted) {
                              setState(() {
                                loading = false;
                              });
                            
                            }
                          }
                        } catch (e) {
                          print("Error creating payment intent");
                          print(e);
                          await showDialog(
                            context: context, 
                            builder: (context) => AlertDialog(
                              title: const Text("Payment failed"),
                              content: const Text("Payment failed, please try again"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }, 
                                  child: const Text("OK")
                                ),
                              ],
                            )
                          );
                          if(mounted) {
                            setState(() {
                              loading = false;
                            });
                          }
                        }
                        
                      },
                      child: loading ? const CircularProgressIndicator() : const Text("Purchase Trip!"),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}