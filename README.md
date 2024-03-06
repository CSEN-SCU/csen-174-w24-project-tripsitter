# Instructions

## Setup and Dependencies

[Install Flutter](https://docs.flutter.dev/get-started/install)

[Install Node.js LTS (not "current")](https://nodejs.org/en)

Install Firebase CLI tools: `npm install -g firebase-tools`

### Mapbox API

[Mapbox](https://mapbox.com) is used for displaying maps on the frontend.

Create an account for Mapbox at [https://account.mapbox.com/](https://account.mapbox.com/). If you use your school email address you won't need to add a credit card.

Click on the [tokens](https://account.mapbox.com/access-tokens/) tab and copy your default public token (should start with "pk.")

In the frontend folder, create a file called config.json, and add your mapbox key to it like so:

```
{
    "MAPBOX_ACCESS_TOKEN": "yourMapboxKey"
}
```

It is also encouraged that you copy the config.json file to the root directory of the project so you can run your flutter app from there too.

If you are also developing for iOS and Android, follow the respective guides. Follow the "Configure credentials" and "Configure your secret token" sections. You don't need to configure your public token.

- [iOS](https://docs.mapbox.com/ios/maps/guides/install/#configure-credentials)
- [Android](https://docs.mapbox.com/android/maps/guides/install/#configure-credentials)

### Stripe API

Stripe is used to handle processing payments from users.

Create a Stripe account at [dashboard.stripe.com](https://dashboard.stripe.com/). You don't need to follow the actions for "activating your account" unless you want to accept actual payments.

Click on the "Developers" tab in the top right and then select the "API Keys" tab. Copy your "Publishable key" and add it to your config.json:

```
{
    "MAPBOX_ACCESS_TOKEN": "yourMapboxKey", //don't forget to add a comma here!
    "STRIPE_PK_TEST": "pk_test_yourKey"
}
```

Next, create a `.env` file in the backend folder, and add your Stripe Secret Key like so:
```
STRIPE_SECRET=sk_test_yourSecretKey
```

### Amadeus
Make an account on the [Amadeus website](https://developers.amadeus.com/register) then go to [https://developers.amadeus.com/my-apps](https://developers.amadeus.com/my-apps)

Get your Test API key and secret and add it to the .env file:
AMADEUS_DEV_KEY=<your key>
AMADEUS_DEV_SECRET=<your secret>


### Ticketmaster
Create an account on the [Ticketmaster Developer Website](https://developer.ticketmaster.com/), and then go to "My Apps". Copy the API key and secret and add it to your .env file:
TICKETMASTER_KEY=<your-key>
TICKETMASTER_SECRET=<your-secret>

### SkyScrapper
Create an account on [RapidAPI](https://rapidapi.com/apiheya/api/sky-scrapper) and select the Free plan for the SkyScanner API.
In the API endpoints explorer, look for the field called "X-RapidAPI-Key" and copy the key to add to your .env file:
SKYSCRAPER_KEY=<your-key>


## Running the frontend

Make sure you've installed the latest dependencies: `cd frontend && flutter pub get`

In VSCode: Open main.dart and select Run -> Start Debugging, or press F5

In terminal: `flutter run --dart-define-from-file=./config.json`

## Running the backend functions

Make sure you've installed the latest dependencies: `cd backend && npm install`

In terminal: `cd backend && npm run build && cd .. && firebase emulators:start --only functions`
