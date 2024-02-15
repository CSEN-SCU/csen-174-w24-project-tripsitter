import * as admin from 'firebase-admin';
import { Request, Response } from "express";
const  serviceAccount = require("./admin.json");
import { FieldValue } from "firebase-admin/firestore";
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

export const db = admin.firestore();
export const auth = admin.auth();

export async function addUserToTrip(req: Request, res: Response) {
    const tripId = req.body.tripId;
    const email = req.body.email;
    console.log(email, tripId);
    const user = await auth.getUserByEmail(email);
    const userId = user.uid;
    const tripRef = db.collection("trips").doc(tripId);
    // check if the user is already in the trip
    const trip = await tripRef.get();
    const data = trip.data();
    if(data) {
        if(data.uids.includes(userId)) {
            res.send("User already in trip");
            return;
        }
        
        await tripRef.update({
            uids: FieldValue.arrayUnion(userId)
        });

        // increment the numberTrips field on the user object
        const userRef = db.collection("users").doc(userId);
        const user = await userRef.get();
        const userData = user.data();
        if(userData) {
            const newNumberTrips = userData.numberTrips + 1;
            await userRef.update({
                numberTrips: newNumberTrips
            });
        }
    }
    res.send("User added to trip");
}

export async function removeUserFromTrip(req: Request, res: Response) {
    const tripId = req.body.tripId;
    const uid = req.body.uid;
    const tripRef = db.collection("trips").doc(tripId);
    await tripRef.update({
        uids: FieldValue.arrayRemove(uid)
    });
    // decrement the numberTrips field on the user object
    const userRef = db.collection("users").doc(uid);
    const user = await userRef.get();
    const data = user.data();
    if(data) {
        const newNumberTrips = data.numberTrips - 1;
        await userRef.update({
            numberTrips: newNumberTrips
        });
    }
    res.send("User removed from trip");
}