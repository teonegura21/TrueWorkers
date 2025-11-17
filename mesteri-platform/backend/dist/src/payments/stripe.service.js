"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.StripeService = void 0;
const common_1 = require("@nestjs/common");
const stripe_1 = __importDefault(require("stripe"));
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let StripeService = class StripeService {
    prisma;
    stripe;
    constructor(prisma) {
        this.prisma = prisma;
        this.stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', {
            apiVersion: '2025-10-29.clover',
        });
    }
    async createPaymentIntent(amount, currency = 'ron', metadata) {
        const paymentIntent = await this.stripe.paymentIntents.create({
            amount: Math.round(amount * 100),
            currency: currency.toLowerCase(),
            metadata,
            capture_method: 'manual',
            payment_method_types: ['card'],
        });
        const payment = await this.prisma.payment.create({
            data: {
                amount,
                currency: currency.toUpperCase(),
                status: client_1.PaymentStatus.PENDING,
                method: 'CARD',
                userId: metadata.clientId,
                masterId: metadata.craftsmanId,
                clientId: metadata.clientId,
                projectId: metadata.projectId,
                description: `Payment for project ${metadata.projectId}`,
            },
        });
        return {
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
            paymentId: payment.id,
        };
    }
    async capturePayment(paymentIntentId, paymentId) {
        const paymentIntent = await this.stripe.paymentIntents.capture(paymentIntentId);
        const payment = await this.prisma.payment.update({
            where: { id: paymentId },
            data: {
                status: client_1.PaymentStatus.COMPLETED,
                processedAt: new Date(),
                completedAt: new Date(),
            },
        });
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
    async refundPayment(paymentIntentId, paymentId, amount) {
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
        await this.prisma.payment.update({
            where: { id: paymentId },
            data: {
                status: client_1.PaymentStatus.REFUNDED,
                refundedAt: new Date(),
                refundReason: 'Refund requested',
            },
        });
        const refundAmount = amount || payment.amount;
        const clientWallet = await this.prisma.wallet.findUnique({
            where: { userId: payment.clientId },
        });
        if (clientWallet) {
            await this.prisma.wallet.update({
                where: { id: clientWallet.id },
                data: { balance: { increment: refundAmount } },
            });
        }
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
    async createCustomer(email, name, metadata) {
        return this.stripe.customers.create({
            email,
            name,
            metadata,
        });
    }
    async attachPaymentMethod(paymentMethodId, customerId) {
        return this.stripe.paymentMethods.attach(paymentMethodId, {
            customer: customerId,
        });
    }
    async handleWebhookEvent(event) {
        switch (event.type) {
            case 'payment_intent.succeeded':
                await this.handlePaymentSuccess(event.data.object);
                break;
            case 'payment_intent.payment_failed':
                await this.handlePaymentFailure(event.data.object);
                break;
            case 'charge.refunded':
                await this.handleRefund(event.data.object);
                break;
            default:
                console.log(`Unhandled event type: ${event.type}`);
        }
    }
    async handlePaymentSuccess(paymentIntent) {
    }
    async handlePaymentFailure(paymentIntent) {
    }
    async handleRefund(charge) {
        console.log('Refund processed:', charge.id);
    }
    async getPaymentMethod(paymentMethodId) {
        return this.stripe.paymentMethods.retrieve(paymentMethodId);
    }
    calculateFee(amount) {
        const platformFee = amount * 0.05;
        const craftsmanReceives = amount - platformFee;
        return {
            platformFee: Math.round(platformFee * 100) / 100,
            craftsmanReceives: Math.round(craftsmanReceives * 100) / 100,
        };
    }
};
exports.StripeService = StripeService;
exports.StripeService = StripeService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StripeService);
//# sourceMappingURL=stripe.service.js.map