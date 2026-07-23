import Stripe from 'stripe';
const key = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';
export const stripe = new Stripe(key, { apiVersion: '2024-06-20' as any });
