import Stripe from 'stripe';

import {db} from "./firebase";
import { Request, Response } from "express";

export const stripe = new Stripe(process.env.STRIPE_SECRET!);

export async function getOrCreateCustomer(userId: string, params?: Stripe.CustomerCreateParams) {
    const ref = db.collection('users').doc(userId);
    const userSnapshot = await ref.get();
    const { stripeId, email, name } = userSnapshot.data() || {};
  
    // If missing customerID, create it
    if (!stripeId) {
      const customer = await stripe.customers.create({
        email,
        name,
        description: userId,
        metadata: {
          firebaseUID: userId,
        },
        ...params
      });
      await ref.set({ stripeId: customer.id }, {merge: true});
      return customer;
    } else {
      return await stripe.customers.retrieve(stripeId) as Stripe.Customer;
    }
  
}

export async function createPaymentIntent(req: Request, res: Response) {
    const { amount, currency, userId, description } = req.body;
    if(!amount || !currency || !userId || !description) {
        res.status(400).send('Missing parameters');
        return;
    }
    const customer = await getOrCreateCustomer(userId);
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      customer: customer.id,
      description
    });
    res.send({
        clientSecret: paymentIntent.client_secret,
        customerId: customer.id,
    });
}