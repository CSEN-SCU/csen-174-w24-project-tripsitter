import { Request, Response } from "express";
const Amadeus = require('amadeus');

import amadeus from "./amadeusClient";

import { parse } from 'tinyduration';

var flightData = require('./flightData.json');

function checkExistingFlight(i: any, existing: any) {
  if(i.id == existing.id) {
    return true;
  }
  if(i.segments.length != existing.segments.length) {
    return false;
  }
  for(let j = 0; j < i.segments.length; j++) {
     if(i.segments[j].departureAirport != existing.segments[j].departureAirport) {
      return false;
    }
    // if(i.segments[j].departureTerminal != existing.segments[j].departureTerminal) {
    //   return false;
    // }
    if(i.segments[j].departureTime != existing.segments[j].departureTime) {
      return false;
    }
    if(i.segments[j].arrivalAirport != existing.segments[j].arrivalAirport) {
      return false;
    }
    // if(i.segments[j].arrivalTerminal != existing.segments[j].arrivalTerminal) {
    //   return false;
    // }
    if(i.segments[j].arrivalTime != existing.segments[j].arrivalTime) {
      return false;
    }
    if(i.segments[j].airlineOperating != existing.segments[j].airlineOperating) {
      return false;
    }
    // if(i.segments[j].aircraft != existing.segments[j].aircraft) {
    //   return false;
    // }
    if(i.segments[j].numberOfStops != existing.segments[j].numberOfStops) {
      return false;
    }
  }
  return true;
}

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
    // const origin = req.query.origin;
    // const destination = req.query.destination;
    // const departureDate = req.query.departureDate;
    // const returnDate = req.query.returnDate;
    // const adults = req.query.adults;
    // const children = req.query.children;
    // const currency = req.query.currency ?? "USD";
    // const travelClass = req.query.travelClass ?? "ECONOMY";
    // if(!origin || !destination || !departureDate || !adults) {
    //   res.status(400).send('Missing required query parameters');
    //   return;
    // }
    // Docs: https://developers.amadeus.com/self-service/category/flights/api-doc/flight-offers-search
    // let flightSearch = await amadeus.shopping.flightOffersSearch.get({
    //   originLocationCode: origin,
    //   destinationLocationCode: destination,
    //   departureDate: departureDate,
    //   returnDate: returnDate,
    //   adults: adults,
    //   children: children,
    //   currencyCode: currency,
    //   travelClass: travelClass,
    // });
    // const offers = flightSearch.data.map((offer: any) => {
  const offers = flightData.map((offer: any) => {
      return {
        type: "flight",
        id: offer.id,
        oneWay: offer.oneWay,
        seats: offer.numberOfBookableSeats,
        price: Number(offer.price.total),
        priceCurrency: offer.price.currency,
        priceInfo: offer.price,
        itineraries: offer.itineraries.map((itinerary: any) => {
          return {
            duration: parse(itinerary.duration),
            segments: itinerary.segments.map((segment: any) => {
              return {
                departureAirport: segment.departure.iataCode,
                departureTerminal: segment.departure.terminal,
                departureTime: segment.departure.at,
                arrivalAirport: segment.arrival.iataCode,
                arrivalTerminal: segment.arrival.terminal,
                arrivalTime: segment.arrival.at,
                // airlineOffering: segment.carrierCode,
                airlineOperating: segment.operating?.carrierCode ?? segment.carrierCode,
                flightNumbers: [segment.carrierCode+""+segment.number.toString()],
                aircraft: segment.aircraft.code,
                duration: parse(segment.duration),
                id: segment.id,
                numberOfStops: segment.numberOfStops,
              }
            })
          }
        }),
        airlines: offer.validatingAirlineCodes,
      }
    });
    for(let o of offers){
      for(let i of o.itineraries){
        i.id = i.segments.map((s: any) => s.id).join('-');
      }
    }

    const offersMap: any[] = [];

    for(let o of offers) {
      let currentObj: any = offersMap;
      for(let i of o.itineraries) {
        if(!currentObj.find((s: any) => checkExistingFlight(i, s))) {
          currentObj.push({
            ...i,
            next: [],
            minPrice: -1,
            offerIds: [],
            isOneWay: o.oneWay,
            seats: o.seats,
            offeredBy: [],
          });
        }
        currentObj = currentObj.find((s: any) => checkExistingFlight(i, s));
        currentObj.offerIds = [...new Set([...currentObj.offerIds, o.id])];
        currentObj.offeredBy = [...new Set([...currentObj.offeredBy, ...o.airlines])];
        for(let j = 0; j<currentObj.segments.length; j++) {
          currentObj.segments[j].flightNumbers = [...new Set([...currentObj.segments[j].flightNumbers, ...i.segments[j].flightNumbers])];
        }
        if(o.price < currentObj.minPrice || currentObj.minPrice < 0 ) {
          currentObj.minPrice = o.price;
          currentObj.priceInfo = o.priceInfo;
          currentObj.priceCurrency = o.priceCurrency;
        }
        currentObj = currentObj.next;
      }
    }
    res.send(offersMap);

    // res.send(offers);
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

/* 
  Input: query parameter with the city or airport name
  Format: /search/airports?query=New York
  Output: JSON array with the airport information
  Format: [
    {
      type: 'airport',
      iataCode: 'JFK',
      airportName: 'JOHN F KENNEDY INTL',
      cityName: 'NEW YORK',
      country: 'US',
      lat: 40.639751,
      lon: -73.778925
    },
    ...
  ]
*/

export async function searchAirports(req: Request, res: Response) {
  const parameter = req.query.query;
  // Which cities or airports start with the parameter variable
  // Docs: https://developers.amadeus.com/self-service/category/flights/api-doc/airport-and-city-search
  const locations = await amadeus.referenceData.locations.get({
      keyword: parameter,
      subType: Amadeus.location.any,
  });
  const data = locations.result.data;
  const airports = data.filter((location: any) => location.subType === 'AIRPORT').map((airport: any) => {
    return {
      type: "airport",
      iataCode: airport.iataCode,
      airportName: airport.name,
      cityName: airport.address.cityName,
      country: airport.address.countryCode,
      lat: airport.geoCode.latitude,
      lon: airport.geoCode.longitude,
      timeZoneOffset: airport.timeZoneOffset,
    }
  });
  // console.log(airports);
  res.send(airports);
}