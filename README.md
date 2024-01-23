# Instructions

## Setup

Clone the repo

[Install Flutter](https://docs.flutter.dev/get-started/install)

[Install Node.js LTS (not "current")](https://nodejs.org/en)

Install Firebase CLI tools: `npm install -g firebase-tools`

Add API keys in backend/.env

## Running the frontend

In VSCode: Open main.dart and select Run -> Start Debugging, or press F5

In terminal: `flutter run`

## Running the backend functions

In terminal: `cd backend && npm run build && cd .. && firebase emulators:start --only functions`