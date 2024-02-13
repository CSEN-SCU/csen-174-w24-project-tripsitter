import axios from "axios";
import { Request, Response } from "express";
var geohash = require('ngeohash');

const TICKETMASTER_KEY = process.env.TICKETMASTER_KEY;

export async function searchEvents(req: Request, res: Response) {
    const { query, lat, long, startDateTime, endDateTime } = req.query;
    const geocode = geohash.encode(lat, long);
    console.log(geocode);
    console.log(startDateTime, endDateTime);
    let url = `https://app.ticketmaster.com/discovery/v2/events.json?apikey=${TICKETMASTER_KEY}&geoPoint=${geocode}&startDateTime=${startDateTime}&endDateTime=${endDateTime}`;
    if(query) {
        url += `&keyword=${query}`;
    }
    const response = await axios.get(url);
    // console.log(Object.keys(response.data._embedded.events[0]));
    console.log(response.data);
    const events = response.data._embedded?.events.map((e: any) => {
        return {
            ageRestrictions: e.ageRestrictions?.ageRuleDescription || null,
            ticketLimit: e.accessibility?.ticketLimit || null,
            classifications: e.classifications,
            distance: e.distance,
            startTime: e.dates.start,
            doorsTime: e.doorsTimes,
            id: e.id,
            images: e.images,
            info: {
                infoStr: e.info,
                pleaseNote: e.pleaseNote,
                ticketLimit: e.ticketLimit?.info
            },
            locale: e.locale,
            name: e.name,
            prices: e.priceRanges,
            promoters: e.promoters,
            seatmap: e.seatmap?.staticUrl || null,
            sales: e.sales,
            type: e.type,
            distanceUnits: e.units,
            url: e.url,
            venues: e._embedded?.venues?.map((v: any) => {    
                return {
                    id: v.id,
                    name: v.name,
                    addressLine1: v.address?.line1,
                    addressLine2: v.address?.line2,
                    addressLine3: v.address?.line3,
                    city: v.city.name,
                    state: v.state?.name,
                    stateCode: v.state?.stateCode,
                    country: v.country.name,
                    countryCode: v.country.countryCode,
                    distance: v.distance,
                    distanceUnits: v.units,
                    timezone: v.timezone,
                    postalCode: v.postalCode,
                    images: v.images,
                    latitude: v.location.latitude,
                    longitude: v.location.longitude,
                    url: v.url,
                }
            }),

            attractions: e._embedded?.attractions,

        }
    });
    const {page} = response.data;
    res.json({
        events,
        page
    });
}

export async function getEventDetails(req: Request, res: Response) {
    const {id} = req.query;

    const url = `https://app.ticketmaster.com/discovery/v2/events/${id}.json?apikey=${TICKETMASTER_KEY}`;
    const response = await axios.get(url);

    response.data
}