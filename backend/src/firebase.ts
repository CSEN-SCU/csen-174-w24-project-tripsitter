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
    await tripRef.update({
        uids: FieldValue.arrayUnion(userId)
    });
    res.send("User added to trip");
}

export async function removeUserFromTrip(req: Request, res: Response) {
    const tripId = req.body.tripId;
    const uid = req.body.uid;
    const tripRef = db.collection("trips").doc(tripId);
    await tripRef.update({
        uids: FieldValue.arrayRemove(uid)
    });
    res.send("User removed from trip");
}