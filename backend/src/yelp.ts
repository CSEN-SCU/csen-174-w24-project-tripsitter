const YELP_API_KEY = process.env.YELP_API_KEY;
import axios from "axios";
import { Request, Response } from "express";

export async function getRestaurants(req: Request, res: Response) {
    const {lat, lon} = req.query;
    const url = `https://api.yelp.com/v3/businesses/search?latitude=${lat}&longitude=${lon}&limit=50`;
    const response = await axios(url, {
        headers: {
            Authorization: `Bearer ${YELP_API_KEY}`
        }
    });
    const data = response.data;
    res.send(data.businesses);

}