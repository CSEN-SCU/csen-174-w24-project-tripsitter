const Amadeus = require('amadeus');

const amadeus = new Amadeus({
  clientId: process.env.AMADEUS_DEV_KEY,
  clientSecret: process.env.AMADEUS_DEV_SECRET
});

export default amadeus;