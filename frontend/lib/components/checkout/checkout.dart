// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/payment.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/confirmation.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/checkout/trip_summary.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/styles.dart';

class CheckoutPage extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  const CheckoutPage({required this.trip, required this.profiles, super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  Trip get trip => widget.trip;
  List<UserProfile> get profiles => widget.profiles;
  CardFieldInputDetails? cardDetails;

  bool loading = false;
  String status = "Processing payment";

  Future<void> purchaseEverything() async {
    for(int i=0; i<trip.flights.length; i++) {
      FlightGroup flight = trip.flights[i];
      if(flight.selected == null) {
        continue;
      }
      if(mounted) {
        setState(() {
          status = "Booking flight ${i+1}/${trip.flights.length}";
        });
      }
      await TripsitterApi.bookFlight(flight, profiles);
    }
    for(int i=0; i<trip.hotels.length; i++) {
      HotelGroup hotel = trip.hotels[i];
      if(hotel.selectedInfo == null || hotel.selectedOffer == null) {
        continue;
      }
      if(mounted) {
        setState(() {
          status = "Booking hotel ${i+1}/${trip.hotels.length}";
        });
      }
      await TripsitterApi.bookHotel(hotel, profiles);
    }
    await trip.complete();
    if(mounted) {
      setState(() {
        loading = false;
      });
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConfirmationPage(trip: trip, profiles: widget.profiles)));
  }

  Widget checkoutWidgets(bool split, String uid, User user) {
    return Column(
      children: [
        if((split ? trip.rentalCars.where((r) => r.members.contains(uid)) : trip.rentalCars).isNotEmpty || (split ? trip.activities.where((a) => a.participants.contains(uid)) : trip.activities).isNotEmpty)
          ...[
            const Text("Note: Only flights and hotels can be paid directly through Tripsitter. After purchasing, you will be directed to the rental car and activity websites to complete your purchase."),
            Text("Amount owed to Tripsitter: \$${(split ? trip.userStripePrice(uid) : trip.stripePrice).toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
        Container(height: 50),
        ElevatedButton(
          onPressed: (cardDetails?.complete ?? false) ? () async {
            setState(() {
              loading = true;
              status = "Processing payment...";
            });
            PaymentIntentData data = await TripsitterApi.createPaymentIntent(user.uid, trip);
            debugPrint("Payment intent data created ${data.clientSecret}");
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
              debugPrint("Intent processed");
              debugPrint(intent.amount.toString());
              debugPrint(intent.receiptEmail);
              debugPrint(intent.status.toString());

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
                    purchaseEverything();
                  }
                  else {
                    await trip.save();
                    if(mounted) {
                      setState(() {
                        loading = false;
                      });
                    }
                    Navigator.pop(context);

                  }
                }
                else {
                  purchaseEverything();
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
              debugPrint("Error creating payment intent");
              debugPrint(e.toString());
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
            
          } : null,
          child: const Text("Purchase Trip!"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 20)
      );
    }
    bool split = trip.usingSplitPayments;
    String uid = user.uid;
    bool isMobile = Provider.of<bool>(context);
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: AbsorbPointer(
        absorbing: loading,
        child: Stack(
          children: [
            Center(
              child: Builder(
                builder: (context) {
                  if(isMobile) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: [
                          TripSummary(
                            trip: trip,
                            uid: uid,
                            profiles: widget.profiles,
                          ),
                          checkoutWidgets(split, uid, user),
                        ],
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: const Color.fromARGB(255, 239, 239, 239),
                            width: constraints.maxWidth * 0.4,
                            height: constraints.maxHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                children: [
                                  Text("Payment:", style: sectionHeaderStyle),
                                  checkoutWidgets(split, uid, user),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.6,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                children: [
                                  TripSummary(
                                    trip: trip,
                                    uid: uid,
                                    profiles: widget.profiles,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  );
                }
              ),
            ),
            if(loading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600,),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(status, style: const TextStyle(color: Colors.white, fontSize: 20)),
                          const Center(
                            child: LinearProgressIndicator(minHeight: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}