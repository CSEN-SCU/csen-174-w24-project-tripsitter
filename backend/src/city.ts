import axios from "axios";
import { Request, Response } from "express";

const MAPS_API_KEY = process.env.MAPS_API_KEY!

export async function getCityImage(req: Request, res: Response) {
    const city = req.query.city;
    const url = `https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${city}&inputtype=textquery&fields=photos&key=${MAPS_API_KEY}`
    const response = await axios(url);
    const data = response.data;
    console.log(data);
    if (data.candidates && data.candidates.length > 0) {
    const photoReference = data.candidates[0].photos[0].photo_reference
        const photoUrl = `https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=${photoReference}&key=${MAPS_API_KEY}`;
        const buff = await axios
            .get(photoUrl, {
                responseType: 'arraybuffer'
            })
            .then(response => Buffer.from(response.data, 'binary').toString('base64'))
        res.send({src: "data:image/jpeg;base64," + buff});
    }
    else {
        res.status(404).send("No image found")
    }
}