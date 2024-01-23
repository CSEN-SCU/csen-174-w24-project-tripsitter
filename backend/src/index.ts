import * as functions from "firebase-functions";

import * as express from 'express'
const app = express();
const cors = require('cors')({origin: true});
app.use(cors);
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get('/test', (req, res) => {
  res.send('endpoint2!');
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

// // Start writing functions
// // https://firebase.google.com/docs/functions/typescript

exports.api = functions.https.onRequest(app);