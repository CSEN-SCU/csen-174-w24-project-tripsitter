import { Request, Response } from "express";

import amadeus from "./amadeusClient";

export async function getHotels(req: Request, res: Response){
    const cityCode = req.query.cityCode;
    if (!cityCode) {
      res.status(400).send('Missing required query parameters');
      return;
    }
    // Docs: https://developers.amadeus.com/self-service/category/hotel/api-doc/hotel-search
    let hotels = await amadeus.referenceData.locations.hotels.byCity.get({
      cityCode: cityCode,
    });
    const hotelIds = hotels.data.map((hotel: any) => hotel.hotelId);

    let results: any[] = [];
    let promises = [];

    for (let i = 0; i < hotelIds.length; i += 10) {
        let h = hotelIds.slice(i, i + 10);
        console.log(h);
        let request = await amadeus.shopping.hotelOffersSearch.get({
            hotelIds: h.join(','),
            checkInDate: "2024-03-01",
            checkOutDate: "2024-03-02",
            adults: 1,
        }).then((response: any) => {
            console.log('HotelOffersSearch Response:', response.data);
            results.push(response.data);
        }).catch((error: any) => {
            console.error('Error in hotelOffersSearch:', error);
            console.error('Request parameters:', {
                hotelIds: h.join(','),
                checkInDate: "2024-03-01",
                checkOutDate: "2024-03-02",
                adults: 1,
            });
            res.status(500).send('Internal Server Error');
        });
        promises.push(request);
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
