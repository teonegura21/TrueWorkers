import { Injectable } from '@nestjs/common';
import Stripe from 'stripe';
import { PrismaService } from '../prisma/prisma.service';
import { PaymentStatus } from '@prisma/client';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor(private prisma: PrismaService) {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
      apiVersion: '2025-10-29.clover',
    });
  }

  /**
   * Create a payment intent for project payment
   */
  async createPaymentIntent(
    amount: number,
    currency: string = 'ron',
    metadata: {
      projectId: string;
      clientId: string;
      craftsmanId: string;
      milestoneId?: string;
    },
  ) {
    const paymentIntent = await this.stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe uses smallest currency unit
      currency: currency.toLowerCase(),
      metadata,
      capture_method: 'manual', // Hold funds in escrow
      payment_method_types: ['card'],
    });

    // Create payment record in database
    const payment = await this.prisma.payment.create({
      data: {
        amount,
        currency: currency.toUpperCase(),
        status: PaymentStatus.PENDING,
        method: 'CARD' as any,
        userId: metadata.clientId,
        masterId: metadata.craftsmanId,
        clientId: metadata.clientId,
        projectId: metadata.projectId,
        stripePaymentIntentId: paymentIntent.id,
        description: `Payment for project ${metadata.projectId}`,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      paymentId: payment.id,
    };
  }

  /**
   * Capture payment (release escrow funds)
   */
  async capturePayment(paymentIntentId: string, paymentId: string) {
    // Capture the payment intent
    const paymentIntent = await this.stripe.paymentIntents.capture(
      paymentIntentId,
    );

    // Update payment status in database
    const payment = await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        status: PaymentStatus.COMPLETED,
        processedAt: new Date(),
        completedAt: new Date(),
      },
    });

    // Update craftsman wallet
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId: payment.masterId },
    });

    if (wallet) {
      await this.prisma.wallet.update({
        where: { id: wallet.id },
        data: {
          balance: { increment: payment.amount },
          totalEarnings: { increment: payment.amount },
        },
      });
    }

    return { paymentIntent, payment };
  }

  /**
   * Refund a payment
   */
  async refundPayment(paymentIntentId: string, paymentId: string, amount?: number) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new Error('Payment not found');
    }

    const refund = await this.stripe.refunds.create({
      payment_intent: paymentIntentId,
      amount: amount ? Math.round(amount * 100) : undefined,
    });

    // Update payment status
    await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        status: PaymentStatus.REFUNDED,
        refundedAt: new Date(),
        refundReason: 'Refund requested',
      },
    });

    // Update wallet balances
    const refundAmount = amount || payment.amount;

    // Return to client wallet
    const clientWallet = await this.prisma.wallet.findUnique({
      where: { userId: payment.clientId },
    });
    if (clientWallet) {
      await this.prisma.wallet.update({
        where: { id: clientWallet.id },
        data: { balance: { increment: refundAmount } },
      });
    }

    // Deduct from craftsman wallet
    const craftsmanWallet = await this.prisma.wallet.findUnique({
      where: { userId: payment.masterId },
    });
    if (craftsmanWallet) {
      await this.prisma.wallet.update({
        where: { id: craftsmanWallet.id },
        data: {
          balance: { decrement: refundAmount },
          totalEarnings: { decrement: refundAmount },
        },
      });
    }

    return refund;
  }

  /**
   * Create a customer for recurring payments
   */
  async createCustomer(email: string, name: string, metadata?: Record<string, string>) {
    return this.stripe.customers.create({
      email,
      name,
      metadata,
    });
  }

  /**
   * Create payment method
   */
  async attachPaymentMethod(paymentMethodId: string, customerId: string) {
    return this.stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });
  }

  /**
   * Handle Stripe webhook events
   */
  async handleWebhookEvent(event: Stripe.Event) {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await this.handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
        break;
      
      case 'payment_intent.payment_failed':
        await this.handlePaymentFailure(event.data.object as Stripe.PaymentIntent);
        break;
      
      case 'charge.refunded':
        await this.handleRefund(event.data.object as Stripe.Charge);
        break;
      
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
  }

  private async handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
    const payment = await this.prisma.payment.findUnique({
      where: {
        stripePaymentIntentId: paymentIntent.id,
      },
    });

    if (payment) {
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.PROCESSING,
          processedAt: new Date(),
        },
      });
      console.log(`Payment ${payment.id} marked as PROCESSING via webhook`);
    } else {
      console.warn(`Payment not found for Stripe PaymentIntent: ${paymentIntent.id}`);
    }
  }

  private async handlePaymentFailure(paymentIntent: Stripe.PaymentIntent) {
    const payment = await this.prisma.payment.findUnique({
      where: {
        stripePaymentIntentId: paymentIntent.id,
      },
    });

    if (payment) {
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.FAILED,
          failedAt: new Date(),
          failureReason: paymentIntent.last_payment_error?.message || 'Payment failed',
        },
      });
      console.log(`Payment ${payment.id} marked as FAILED via webhook`);
    } else {
      console.warn(`Payment not found for Stripe PaymentIntent: ${paymentIntent.id}`);
    }
  }

  private async handleRefund(charge: Stripe.Charge) {
    // Handle refund notification
    console.log('Refund processed:', charge.id);
  }

  /**
   * Get payment method details
   */
  async getPaymentMethod(paymentMethodId: string) {
    return this.stripe.paymentMethods.retrieve(paymentMethodId);
  }

  /**
   * Calculate platform fee (5%)
   */
  calculateFee(amount: number): { platformFee: number; craftsmanReceives: number } {
    const platformFee = amount * 0.05; // 5% platform fee
    const craftsmanReceives = amount - platformFee;
    
    return {
      platformFee: Math.round(platformFee * 100) / 100,
      craftsmanReceives: Math.round(craftsmanReceives * 100) / 100,
    };
  }
}
