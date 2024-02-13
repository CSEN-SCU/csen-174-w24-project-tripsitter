import * as functions from "firebase-functions";

import * as express from 'express';
import 'dotenv/config';
import { searchEvents } from "./ticketmaster";
import { searchFlights, searchAirlines, getAirlineLogo } from "./flights";
import { getHotels } from "./hotels";
import { searchAirports } from "./autofill";
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
app.get('/airline-logo', getAirlineLogo);


exports.api = functions.https.onRequest(app);