import axios from "axios";
import { Request, Response } from "express";

const SKYSCRAPER_KEY = process.env.SKYSCRAPER_KEY;

// const rentalLocationData = require("./rentalLocationData.json");
// const rentalData = require("./rentalData.json");

async function getEntityList(name: String) {
    // return rentalLocationData;
    
    const options = {
        method: 'GET',
        url: 'https://sky-scrapper.p.rapidapi.com/api/v1/cars/searchLocation',
        params: {query: name},
        headers: {
            'X-RapidAPI-Key': SKYSCRAPER_KEY,
            'X-RapidAPI-Host': 'sky-scrapper.p.rapidapi.com'
        }
    };
    
    const searchLocation = await axios.request(options);
    const locationData = searchLocation.data;
    return locationData;
}

function parseQuotes(data: any) {
    // return data;
    return data.quotes.map((q: any) => {
        let map = {...q};
        map["provider"] = data.providers[q.prv_id];
        // console.log(q.group);
        // console.log(data.groups[q.group]);
        map["group"] = data.groups[q.group];
        return map;
    })
}

export async function getRentalCars(req: Request, res: Response) {
    const name: String = req.query.name as String;
    const latStr: String = req.query.lat as String;
    const lonStr: String = req.query.lon as String;
    const pickUpDate: String = req.query.pickUpDate as String;
    const pickUpTime: String = req.query.pickUpTime as String;
    const dropOffDate: String = req.query.dropOffDate as String;
    const dropOffTime: String = req.query.dropOffTime as String;

    if(!name || !latStr || !lonStr || !pickUpDate || !pickUpTime || !dropOffDate || !dropOffTime) {
        res.status(400).send("Invalid parameters");
        return;
    }

    const lat = Number(latStr);
    const lon = Number(lonStr);

    const options = (await getEntityList(name)).data;

    // wait 2 seconds
    await new Promise(resolve => setTimeout(resolve, 2000));
    // find option with closest distance to provided lat lon
    options.sort((a: any, b: any) => {
        const aLat = Number(a.location.split(", ")[0]);
        const aLon = Number(a.location.split(", ")[1]);
        const bLat = Number(b.location.split(", ")[0]);
        const bLon = Number(b.location.split(", ")[1]);
        const aDist = distance(lat, lon, aLat, aLon);
        const bDist = distance(lat, lon, bLat, bLon);
        return aDist - bDist;
    });
    console.log("Closest entity", options[0]);
    const entityId = options[0].entity_id;
    console.log("Entity ID", entityId);
    
    // res.send(parseQuotes(rentalData.data));
    // return;

    const reqOptions = {
        method: 'GET',
        url: 'https://sky-scrapper.p.rapidapi.com/api/v1/cars/searchCars',
        params: {
            pickUpEntityId: entityId,
            pickUpDate,
            pickUpTime,
            dropOffDate,
            dropOffTime,
            currency: 'USD',
        },
        headers: {
            'X-RapidAPI-Key': SKYSCRAPER_KEY,
            'X-RapidAPI-Host': 'sky-scrapper.p.rapidapi.com'
        }
    };
    
    const response = await axios.request(reqOptions);
    res.send(parseQuotes(response.data.data));
}

function distance(lat1: number, lon1: number, lat2: number, lon2: number) 
{
    var R = 3958.8; // km
    var dLat = toRad(lat2-lat1);
    var dLon = toRad(lon2-lon1);
    var lat1 = toRad(lat1);
    var lat2 = toRad(lat2);

    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    var d = R * c;
    return d;
}

// Converts numeric degrees to radians
function toRad(Value: number) 
{
    return Value * Math.PI / 180;
}