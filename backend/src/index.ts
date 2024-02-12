import * as functions from "firebase-functions";

import * as express from 'express';
const axios = require('axios');
const fs = require('fs');
const path = require('path');
import 'dotenv/config';
import { searchFlights, searchAirlines, searchAirports } from "./flights";
import { getHotels } from "./hotels";
const app = express();
const cors = require('cors')({origin: true});
app.use(cors);
// const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get("/search/airports", searchAirports);
app.get("/search/airlines", searchAirlines);
app.get('/search/flights', searchFlights);

app.get('/airline-logo', async (req, res) => {
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
});

app.get('/search/hotels', getHotels);


exports.api = functions.https.onRequest(app);