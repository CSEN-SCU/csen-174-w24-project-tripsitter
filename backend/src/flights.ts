import { Request, Response } from "express";

import amadeus from "./amadeusClient";
// var flightData = require('./flightData.json');

const axios = require('axios');
const fs = require('fs');
const path = require('path');

/* 
  Input: query parameters for the following fields
    origin (IATA code, ie SFO)
    destination (IATA code, ie LHR)
    departureDate (YYYY-MM-DD)
    returnDate [optional] (YYYY-MM-DD)
    adults (int)
    children [optinal] (int)
    currency [optional] (ISO 4217 currency code, ie EUR for Euro. Default is USD)
    travelClass [optional] (ECONOMY, PREMIUM_ECONOMY, BUSINESS, or FIRST. Default is ECONOMY)
  Format: /search/flights?origin=NYC&destination=MAD&departureDate=2021-01-01&returnDate=2021-01-31&adults=1&children=0&currency=USD&travelClass=ECONOMY
  Output: JSON array with the flight offers
  Format: [
    {
      type: 'flight-offer',
      id: '1',
      source: 'GDS',
      instantTicketingRequired: false,
      nonHomogeneous: false,
      oneWay: false,
      lastTicketingDate: '2020-09-30',
      numberOfBookableSeats: 9,
      itineraries: [
        {
          duration: 'PT6H5M',
          segments: [
            {
              departure: {
                iataCode: 'JFK',
                terminal: '8',
                at: '2021-01-01T19:30:00'
              },
              arrival: {
                iataCode: 'MAD',
                terminal: '1',
                at: '2021-01-02T08:35:00'
              },
              carrierCode: 'IB',
              number: '6252',
              aircraft: {
                code: '333'
              },
              operating: {
                carrierCode: 'AA'
              },
              duration: 'PT6H5M',
              id: '1',
              numberOfStops: 0,
              blacklistedInEU: false
            }
          ]
        },
        ...
      ],
      price: {
        currency: 'USD',
        total: '248.20',
        base: '197.00',
        fees: [
          {
            amount: '0.00',
            type: 'SUPPLIER'
          },
          {
            amount: '0.00',
            type: 'TICKETING'
          }
        ],
        grandTotal: '248.20'
      },
      pricingOptions: {
        fareType: [
          'PUBLISHED'
        ],
        includedCheckedBagsOnly: false
      },
      validatingAirlineCodes: [
        'IB'
      ],
*/ 

export async function searchFlights(req: Request, res: Response){
    const origin = req.query.origin;
    const destination = req.query.destination;
    const departureDate = req.query.departureDate;
    const returnDate = req.query.returnDate;
    const adults = req.query.adults;
    const children = req.query.children;
    const currency = req.query.currency ?? "USD";
    const travelClass = req.query.travelClass ?? "ECONOMY";
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
      travelClass: travelClass,
    });
  const offers = flightSearch.data;
  // const offers = flightData;
  res.send(offers);
  }



/*
  Input: query parameter with the a list airline IATA codes
  Format: /search/airlines?query=DL,WN,AA
  Output: JSON array with the airline information
  Format: [
    {
      type: 'airline',
      iataCode: 'AA',
      icaoCode: 'AAL',
      businessName: 'AMERICAN AIRLINES',
      commonName: 'AMERICAN AIRLINES',
    },
    ...
  ]
*/

export async function searchAirlines(req: Request, res: Response){
  const parameter = req.query.query;
  // Returns information about an airline given their two digit IATA code. (Example: AA, WN, DL)
  // Docs: https://developers.amadeus.com/self-service/category/flights/api-doc/airline-code-lookup
  const airlines = await amadeus.referenceData.airlines.get({
    airlineCodes: parameter,
  });
  res.send(airlines.data);
}

export async function getAirlineLogo(req: Request, res: Response) {
  const iata = req.query.iata;
  const imageUrl = `https://www.gstatic.com/flights/airline_logos/70px/${iata}.png`;
  
  // if image already exists in temp, return the file
  const imagePath = path.join(__dirname, 'temp', iata+'.png');
  if(fs.existsSync(imagePath)){
    res.sendFile(imagePath);
  }
  else {
    try {
      // Fetch the image from the provided URL
      const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
  
      // Save the image locally
      fs.writeFileSync(imagePath, Buffer.from(response.data, 'binary'));
  
      // Send the image back to the client
      res.sendFile(imagePath);
  
      // Optionally, you can delete the local image file after sending it
      // fs.unlinkSync(imagePath);
    } catch (error) {
      console.error(error);
      res.status(500).send('Internal Server Error');
    }
  }
}

export async function bookFlight(req: Request, res: Response){
  const body = req.body;
  // Docs: https://developers.amadeus.com/self-service/category/air/api-doc/flight-create-orders
  const confirmation = await amadeus.shopping.flightOffers.pricing.post(
    JSON.stringify({
        'data': {
            'type': 'flight-offers-pricing',
            'flightOffers': body.data.flightOffers,
        }
    })
  ).then((response: any) => response).catch(function (response: any) {
    console.log(response);
    res.send(response);
  });
  const updatedOffers = confirmation.result.data.flightOffers;
  console.log(JSON.stringify(confirmation.result));
  body.data.flightOffers = updatedOffers;
  body.remarks = {
    general: [
      {
        subType: "GENERAL_MISCELLANEOUS",
        text: "Flight booked through TripSitter",
      },
    ],
  };
  body.ticketingAgreement = {
    option: "DELAY_TO_CANCEL",
    delay: "6D",
  };
  body.contacts = [
    {
      addresseeName: {
        firstName: "TripSitter",
        lastName: "Travel",
      },
      companyName: "TripSitter",
      purpose: "STANDARD",
      phones: [
        {
          deviceType: "MOBILE",
          countryCallingCode: "1",
          number: "415-555-1234",
        },
      ],
      emailAddress: "test@example.com",
      address: {
        lines: ["500 El Camino Real"],
        postalCode: "95053",
        cityName: "Santa Clara",
        countryCode: "US",
      },
    },
  ]
  console.log(JSON.stringify(body));
  // res.send(priceResult);
  await amadeus.booking.flightOrders.post(JSON.stringify(body))
  .then(function (response: any) {
    res.send(response.result);
  }).catch(function (response: any) {
    res.send(response);
  });
  // res.send(order.result);
}