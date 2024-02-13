import { Request, Response } from "express";
const Amadeus = require('amadeus');

import amadeus from "./amadeusClient";

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