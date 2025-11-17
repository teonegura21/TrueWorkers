import Stripe from 'stripe';
import { PrismaService } from '../prisma/prisma.service';
export declare class StripeService {
    private prisma;
    private stripe;
    constructor(prisma: PrismaService);
    createPaymentIntent(amount: number, currency: string, metadata: {
        projectId: string;
        clientId: string;
        craftsmanId: string;
        milestoneId?: string;
    }): Promise<{
        clientSecret: string;
        paymentIntentId: string;
        paymentId: string;
    }>;
    capturePayment(paymentIntentId: string, paymentId: string): Promise<{
        paymentIntent: Stripe.Response<Stripe.PaymentIntent>;
        payment: {
            id: string;
            description: string | null;
            createdAt: Date;
            updatedAt: Date;
            status: import("@prisma/client").$Enums.PaymentStatus;
            clientId: string;
            projectId: string | null;
            userId: string;
            amount: number;
            currency: string;
            method: import("@prisma/client").$Enums.PaymentMethod;
            masterId: string;
            processedAt: Date | null;
            completedAt: Date | null;
            failedAt: Date | null;
            failureReason: string | null;
            cancelledAt: Date | null;
            cancellationReason: string | null;
            verifiedAt: Date | null;
            rejectedAt: Date | null;
            rejectionReason: string | null;
            reportedAt: Date | null;
            reportReason: string | null;
            refundedAt: Date | null;
            refundReason: string | null;
            paymentMethod: string | null;
            flaggedAsInappropriate: boolean | null;
        };
    }>;
    refundPayment(paymentIntentId: string, paymentId: string, amount?: number): Promise<Stripe.Response<Stripe.Refund>>;
    createCustomer(email: string, name: string, metadata?: any): Promise<Stripe.Response<Stripe.Customer>>;
    attachPaymentMethod(paymentMethodId: string, customerId: string): Promise<Stripe.Response<Stripe.PaymentMethod>>;
    handleWebhookEvent(event: Stripe.Event): Promise<void>;
    private handlePaymentSuccess;
    private handlePaymentFailure;
    private handleRefund;
    getPaymentMethod(paymentMethodId: string): Promise<Stripe.Response<Stripe.PaymentMethod>>;
    calculateFee(amount: number): {
        platformFee: number;
        craftsmanReceives: number;
    };
}
