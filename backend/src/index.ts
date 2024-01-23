import * as functions from "firebase-functions";

import * as express from 'express';
import 'dotenv/config';
const app = express();
const cors = require('cors')({origin: true});
app.use(cors);
const port = 3000;

var Amadeus = require('amadeus');

var amadeus = new Amadeus({
  clientId: process.env.AMADEUS_DEV_KEY,
  clientSecret: process.env.AMADEUS_DEV_SECRET
});

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get("/search/airports", async (req, res) => {
  const parameter = req.query.query;
  // Which cities or airports start with the parameter variable
  // Docs: https://developers.amadeus.com/self-service/category/flights/api-doc/airport-and-city-search
  const locations = await amadeus.referenceData.locations.get({
      keyword: parameter,
      subType: Amadeus.location.any,
  });
  res.send(locations.result);
});

app.get("/search/airlines", async (req, res) => {
  const parameter = req.query.query;
  // Which cities or airports start with the parameter variable
  // Docs: https://developers.amadeus.com/self-service/category/flights/api-doc/airline-code-lookup
  const airlines = await amadeus.referenceData.airlines.get({
    airlineCodes: parameter,
  });
  res.send(airlines.data);
});

app.get('/search/flights', async (req, res) => {
  const origin = req.query.origin;
  const destination = req.query.destination;
  const departureDate = req.query.departureDate;
  const returnDate = req.query.returnDate;
  const adults = req.query.adults;
  const children = req.query.children;
  const currency = req.query.currency ?? "USD";
  if(!origin || !destination || !departureDate || !adults) {
    res.status(400).send('Missing required query parameters');
    return;
  }
  // Docs: https://developers.amadeus.com/self-service/category/flights/api-doc/flight-offers-search
  let flightSearch = await amadeus.shopping.flightOffersSearch.get({
    originLocationCode: origin,
    destinationLocationCode: destination,
    departureDate: departureDate,
    returnDate: returnDate,
    adults: adults,
    children: children,
    currencyCode: currency,
  });
  res.send(flightSearch.data);
  // res.send('endpoint2!');
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

// // Start writing functions
// // https://firebase.google.com/docs/functions/typescript

exports.api = functions.https.onRequest(app);