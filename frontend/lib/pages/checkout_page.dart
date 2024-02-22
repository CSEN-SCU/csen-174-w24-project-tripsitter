import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tripsitter/classes/payment.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/payment.dart';
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

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: ListView(
              children: [
                Text("Checkout Page"),
                Text("Trip: ${widget.trip.name}"),
                if(trip.flights.isNotEmpty)
                  ...[
                    Text("Flights: \$${trip.flightsPrice} total"),
                    for(var flight in trip.flights)
                      ...[
                        Text("${flight.departureAirport} -> ${flight.arrivalAirport} (${flight.price == null ? "Unknown price" : "\$${flight.price} total"})"),
                        Text(flight.members.map((e) => widget.profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                      ],
                      Container(height: 10)
                  ],
                if(trip.hotels.isNotEmpty)
                  ...[
                    Text("Hotels: \$${trip.hotelsPrice} total"),
                    for(var hotel in trip.hotels)
                      ...[
                        Text("${hotel.name} (${hotel.price == null ? "Unknown price" : "\$${hotel.price} total"})"),
                        Text(hotel.members.map((e) => widget.profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                      ],
                      Container(height: 10)
                  ],
                if(trip.rentalCars.isNotEmpty)
                  ...[
                    Text("Rental Cars: \$${trip.rentalCarsPrice} total"),
                    for(var car in trip.rentalCars)
                      ...[
                        Text("${car.name} (\$${car.price} total)"),
                        Text(car.members.map((e) => widget.profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                      ],
                      Container(height: 10)
                  ],
                if(trip.activities.isNotEmpty)
                  ...[
                    Text("Activities: \$${trip.activitiesPrice} total"),
                    for(var activity in trip.activities)
                      ...[
                        Text("${activity.event.name} (${activity.price == null ? "Unknown price" : "\$${activity.price} total"})"),
                        Text(activity.participants.map((e) => widget.profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                      ],
                      Container(height: 10)
                  ],
                Text("Total price: \$${trip.totalPrice}"),
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
                      PaymentIntentData data = await TripsitterApi.createPaymentIntent(user.uid, trip);
                      print("Payment intent data created ${data.clientSecret}");
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
                        print("PAYMENT COMPLETE!");
                      }
                    },
                    child: const Text("Purchase Trip!"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}