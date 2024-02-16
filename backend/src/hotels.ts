import { Request, Response } from "express";

import amadeus from "./amadeusClient";

var hotelData = require('./hotelData.json');

export async function getHotels(req: Request, res: Response){
    const cityCode = req.query.cityCode;
    const latitude = req.query.latitude;
    const longitude = req.query.longitude;
    const checkInDate = req.query.checkInDate;
    const checkOutDate = req.query.checkOutDate;
    const adults = req.query.adults;
    // needs one of citycode or lat and lon
    if ((!cityCode && (!latitude || !longitude)) || !checkInDate || !checkOutDate || !adults) {
      res.status(400).send('Missing required query parameters');
      return;
    }
    res.send(hotelData); return;
    // Docs: https://developers.amadeus.com/self-service/category/hotel/api-doc/hotel-search
    let hotels = cityCode ? (await amadeus.referenceData.locations.hotels.byCity.get({
      cityCode,
    })) : ( await amadeus.referenceData.locations.hotels.byGeocode.get({
        latitude,
        longitude,
        radius: 10
    }));
    const hotelIds = hotels.data.map((hotel: any) => hotel.hotelId);

    let results: any[] = [];
    let promises = [];
    let k = 10;

    for (let i = 0; i < hotelIds.length; i += k) {
        let h = hotelIds.slice(i, i + k);
        // console.log(h);
        let request = amadeus.shopping.hotelOffersSearch.get({
            hotelIds: h.join(','),
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            adults: adults,
        }).then((response: any) => {
            console.log('HotelOffersSearch Response:', response.data);
            results.push(...response.data);
        }).catch((error: any) => {
            console.error('Error in hotelOffersSearch:', error.description);
            console.error('Request parameters:', {
                hotelIds: h.join(','),
                checkInDate,
                checkOutDate,
                adults,
            });
        });
        promises.push(request);
        if(promises.length >= 5) {
            await Promise.all(promises);
            promises = [];
        }
    }
    await Promise.all(promises);
    res.send(results);
}
    // Potential parameters to add:
    // const adults = req.query.adults;
    // const price = req.query.price;
    // const currency = req.query.currency ?? "USD";
    // const checkInDate = req.query.checkInDate;
    // const checkOutDate = req.query.checkOutDate;
