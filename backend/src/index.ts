import * as functions from "firebase-functions";

import * as express from 'express';
import 'dotenv/config';
import { searchFlights, searchAirlines, searchAirports } from "./flights";
const app = express();
const cors = require('cors')({origin: true});
app.use(cors);
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get("/search/airports", searchAirports);
app.get("/search/airlines", searchAirlines);
app.get('/search/flights', searchFlights);

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

exports.api = functions.https.onRequest(app);