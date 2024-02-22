import * as functions from "firebase-functions";

import * as express from 'express';
import 'dotenv/config';
import { searchEvents } from "./ticketmaster";
import { searchFlights, searchAirlines, getAirlineLogo } from "./flights";
import { getHotels } from "./hotels";
import { searchAirports } from "./autofill";
import { addUserToTrip, removeUserFromTrip } from "./firebase";
import { getRentalCars } from "./cars";
import { createPaymentIntent } from "./stripe";
const app = express();
const cors = require('cors')({origin: true});
app.use(cors);

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get('/search/airports', searchAirports);
app.get('/search/airlines', searchAirlines);
app.get('/search/flights', searchFlights);
app.get('/search/hotels', getHotels);
app.get('/search/events', searchEvents);
app.get('/search/cars', getRentalCars);

app.get('/airline-logo', getAirlineLogo);

app.post('/trip/user', addUserToTrip);
app.delete('/trip/user', removeUserFromTrip);

app.post('/checkout/intent', createPaymentIntent);

exports.api = functions.https.onRequest(app);