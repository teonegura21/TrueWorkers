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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let PaymentsService = class PaymentsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAllPayments() {
        return this.prisma.payment.findMany();
    }
    async findPaymentById(id) {
        return this.prisma.payment.findUnique({ where: { id } });
    }
    async findPaymentsByUserId(userId) {
        return this.prisma.payment.findMany({ where: { userId } });
    }
    async findPaymentsByProjectId(projectId) {
        return this.prisma.payment.findMany({ where: { projectId } });
    }
    async findPaymentsByStatus(status) {
        return this.prisma.payment.findMany({ where: { status: status } });
    }
    async findPaymentsByMethod(method) {
        return this.prisma.payment.findMany({ where: { method: method } });
    }
    async processPayment(id) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment || payment.status !== client_1.WithdrawalStatus.PENDING) {
            return null;
        }
        return this.prisma.payment.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.PROCESSING, processedAt: new Date() },
        });
    }
    async completePayment(id) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment || (payment.status !== client_1.WithdrawalStatus.PROCESSING && payment.status !== client_1.WithdrawalStatus.PENDING)) {
            return null;
        }
        const updatedPayment = await this.prisma.payment.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.COMPLETED, completedAt: new Date() },
        });
        const masterWallet = await this.prisma.wallet.findUnique({ where: { userId: updatedPayment.masterId } });
        if (masterWallet) {
            await this.prisma.wallet.update({
                where: { id: masterWallet.id },
                data: {
                    pendingBalance: { decrement: updatedPayment.amount },
                    balance: { increment: updatedPayment.amount },
                    totalEarnings: { increment: updatedPayment.amount },
                },
            });
        }
        return updatedPayment;
    }
    async failPayment(id, reason) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment || (payment.status !== client_1.WithdrawalStatus.PROCESSING && payment.status !== client_1.WithdrawalStatus.PENDING)) {
            return null;
        }
        return this.prisma.payment.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.FAILED, failedAt: new Date(), failureReason: reason },
        });
    }
    async cancelPayment(id, reason) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment || payment.status !== client_1.WithdrawalStatus.PENDING) {
            return null;
        }
        return this.prisma.payment.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.CANCELLED, cancelledAt: new Date(), cancellationReason: reason },
        });
    }
    async verifyPayment(id) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment) {
            return null;
        }
        return this.prisma.payment.update({
            where: { id },
            data: { verifiedAt: new Date() },
        });
    }
    async rejectPayment(id, reason) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment) {
            return null;
        }
        return this.prisma.payment.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.REJECTED, rejectedAt: new Date(), rejectionReason: reason },
        });
    }
    async reportPayment(id, reason) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment) {
            return null;
        }
        return this.prisma.payment.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.REPORTED, reportedAt: new Date(), reportReason: reason },
        });
    }
    async refundPayment(id, reason) {
        const payment = await this.prisma.payment.findUnique({ where: { id } });
        if (!payment || payment.status !== client_1.WithdrawalStatus.COMPLETED) {
            return null;
        }
        const updatedPayment = await this.prisma.payment.update({
            where: { id },
            data: { status: client_1.PaymentStatus.REFUNDED, refundedAt: new Date(), refundReason: reason },
        });
        const clientWallet = await this.prisma.wallet.findUnique({ where: { userId: updatedPayment.clientId } });
        if (clientWallet) {
            await this.prisma.wallet.update({
                where: { id: clientWallet.id },
                data: { balance: { increment: updatedPayment.amount } },
            });
        }
        const masterWallet = await this.prisma.wallet.findUnique({ where: { userId: updatedPayment.masterId } });
        if (masterWallet) {
            await this.prisma.wallet.update({
                where: { id: masterWallet.id },
                data: {
                    balance: { decrement: updatedPayment.amount },
                    totalEarnings: { decrement: updatedPayment.amount },
                },
            });
        }
        return updatedPayment;
    }
    async createPayment(paymentData) {
        const newPayment = await this.prisma.payment.create({
            data: {
                ...paymentData,
            },
        });
        if (newPayment.status === client_1.WithdrawalStatus.COMPLETED) {
            const masterWallet = await this.prisma.wallet.findUnique({ where: { userId: newPayment.masterId } });
            if (masterWallet) {
                await this.prisma.wallet.update({
                    where: { id: masterWallet.id },
                    data: {
                        balance: { increment: newPayment.amount },
                        totalEarnings: { increment: newPayment.amount },
                    },
                });
            }
        }
        return newPayment;
    }
    async updatePayment(id, updateData) {
        return this.prisma.payment.update({
            where: { id },
            data: updateData,
        });
    }
    async deletePayment(id) {
        return this.prisma.payment.delete({ where: { id } });
    }
    async findAllWallets() {
        return this.prisma.wallet.findMany();
    }
    async findWalletById(id) {
        return this.prisma.wallet.findUnique({ where: { id } });
    }
    async findWalletByUserId(userId) {
        return this.prisma.wallet.findUnique({ where: { userId } });
    }
    async createWallet(walletData) {
        return this.prisma.wallet.create({ data: walletData });
    }
    async updateWallet(id, updateData) {
        return this.prisma.wallet.update({
            where: { id },
            data: updateData,
        });
    }
    async deleteWallet(id) {
        return this.prisma.wallet.delete({ where: { id } });
    }
    async verifyWallet(id) {
        const wallet = await this.prisma.wallet.findUnique({ where: { id } });
        if (!wallet) {
            return null;
        }
        return this.prisma.wallet.update({
            where: { id },
            data: { verifiedAt: new Date() },
        });
    }
    async suspendWallet(id, reason) {
        const wallet = await this.prisma.wallet.findUnique({ where: { id } });
        if (!wallet) {
            return null;
        }
        return this.prisma.wallet.update({
            where: { id },
            data: { suspendedAt: new Date(), suspensionReason: reason },
        });
    }
    async reactivateWallet(id) {
        const wallet = await this.prisma.wallet.findUnique({ where: { id } });
        if (!wallet) {
            return null;
        }
        return this.prisma.wallet.update({
            where: { id },
            data: { suspendedAt: null, suspensionReason: null },
        });
    }
    async submitKyc(id, kycData) {
        const wallet = await this.prisma.wallet.findUnique({ where: { id } });
        if (!wallet) {
            return null;
        }
        return this.prisma.wallet.update({
            where: { id },
            data: { kycStatus: 'submitted', kycSubmittedAt: new Date(), kycDocuments: kycData.documents || [] },
        });
    }
    async addBankAccount(id, bankAccountData) {
        const wallet = await this.prisma.wallet.findUnique({ where: { id } });
        if (!wallet) {
            return null;
        }
        const currentBankAccounts = (wallet.bankAccounts || []);
        return this.prisma.wallet.update({
            where: { id },
            data: { bankAccounts: [...currentBankAccounts, bankAccountData] },
        });
    }
    async removeBankAccount(id, accountid) {
        const wallet = await this.prisma.wallet.findUnique({ where: { id } });
        if (!wallet) {
            return null;
        }
        const currentBankAccounts = (wallet.bankAccounts || []);
        const updatedBankAccounts = currentBankAccounts.filter((acc) => acc.id !== accountid);
        return this.prisma.wallet.update({
            where: { id },
            data: { bankAccounts: updatedBankAccounts },
        });
    }
    async findAllWithdrawals() {
        return this.prisma.withdrawal.findMany();
    }
    async findWithdrawalById(id) {
        return this.prisma.withdrawal.findUnique({ where: { id } });
    }
    async findWithdrawalsByUserId(userId) {
        return this.prisma.withdrawal.findMany({ where: { userId } });
    }
    async findWithdrawalsByWalletId(walletid) {
        return this.prisma.withdrawal.findMany({ where: { walletId: walletid } });
    }
    async findWithdrawalsByStatus(status) {
        return this.prisma.withdrawal.findMany({ where: { status: status } });
    }
    async createWithdrawal(withdrawalData) {
        const newWithdrawal = await this.prisma.withdrawal.create({ data: withdrawalData });
        const wallet = await this.prisma.wallet.findUnique({ where: { id: withdrawalData.walletId } });
        if (wallet && wallet.balance >= withdrawalData.amount) {
            await this.prisma.wallet.update({
                where: { id: wallet.id },
                data: {
                    balance: { decrement: withdrawalData.amount },
                    pendingBalance: { increment: withdrawalData.amount },
                },
            });
        }
        return newWithdrawal;
    }
    async processWithdrawal(id) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal || withdrawal.status !== client_1.WithdrawalStatus.PENDING) {
            return null;
        }
        return this.prisma.withdrawal.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.PROCESSING, processedAt: new Date() },
        });
    }
    async completeWithdrawal(id) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal || withdrawal.status !== client_1.WithdrawalStatus.PROCESSING) {
            return null;
        }
        const updatedWithdrawal = await this.prisma.withdrawal.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.COMPLETED, completedAt: new Date() },
        });
        const wallet = await this.prisma.wallet.findUnique({ where: { id: updatedWithdrawal.walletId } });
        if (wallet) {
            await this.prisma.wallet.update({
                where: { id: wallet.id },
                data: {
                    pendingBalance: { decrement: updatedWithdrawal.amount },
                    totalWithdrawn: { increment: updatedWithdrawal.amount },
                },
            });
        }
        return updatedWithdrawal;
    }
    async updateWithdrawal(id, updateData) {
        return this.prisma.withdrawal.update({
            where: { id },
            data: updateData,
        });
    }
    async deleteWithdrawal(id) {
        return this.prisma.withdrawal.delete({ where: { id } });
    }
    async failWithdrawal(id, reason) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal || (withdrawal.status !== client_1.WithdrawalStatus.PROCESSING && withdrawal.status !== client_1.WithdrawalStatus.PENDING)) {
            return null;
        }
        return this.prisma.withdrawal.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.FAILED, failedAt: new Date(), failureReason: reason },
        });
    }
    async verifyWithdrawal(id) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal) {
            return null;
        }
        return this.prisma.withdrawal.update({
            where: { id },
            data: { verifiedAt: new Date() },
        });
    }
    async rejectWithdrawal(id, reason) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal) {
            return null;
        }
        return this.prisma.withdrawal.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.REJECTED, rejectedAt: new Date(), rejectionReason: reason },
        });
    }
    async reportWithdrawal(id, reason) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal) {
            return null;
        }
        return this.prisma.withdrawal.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.REPORTED, reportedAt: new Date(), reportReason: reason },
        });
    }
    async cancelWithdrawal(id, reason) {
        const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
        if (!withdrawal || withdrawal.status !== client_1.WithdrawalStatus.PENDING) {
            return null;
        }
        const updatedWithdrawal = await this.prisma.withdrawal.update({
            where: { id },
            data: { status: client_1.WithdrawalStatus.CANCELLED, cancelledAt: new Date(), cancellationReason: reason },
        });
        const wallet = await this.prisma.wallet.findUnique({ where: { id: updatedWithdrawal.walletId } });
        if (wallet) {
            await this.prisma.wallet.update({
                where: { id: wallet.id },
                data: {
                    balance: { increment: updatedWithdrawal.amount },
                    pendingBalance: { decrement: updatedWithdrawal.amount },
                },
            });
        }
        return updatedWithdrawal;
    }
    async getUserBalance(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        return wallet ? wallet.balance : 0;
    }
    async getUserPendingBalance(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        return wallet ? wallet.pendingBalance : 0;
    }
    async getTotalEarnings(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        return wallet ? wallet.totalEarnings : 0;
    }
    async getTotalWithdrawn(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        return wallet ? wallet.totalWithdrawn : 0;
    }
    async getPaymentHistory(userId, limit) {
        return this.prisma.payment.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
    }
    async getRecentTransactions(userId, limit = 10) {
        const payments = await this.prisma.payment.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
        const withdrawals = await this.prisma.withdrawal.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
        const allTransactions = [
            ...payments,
            ...withdrawals,
        ];
        allTransactions.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
        return allTransactions.slice(0, limit);
    }
    async getMonthlyEarnings(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { masterId: userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true },
        });
        const monthlyEarnings = {};
        payments.forEach((payment) => {
            const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
            monthlyEarnings[month] = (monthlyEarnings[month] || 0) + payment.amount;
        });
        return Object.entries(monthlyEarnings).map(([month, earnings]) => ({
            month,
            earnings,
        }));
    }
    async getPaymentStats(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const completedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.COMPLETED);
        const pendingPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.PENDING || p.status === client_1.WithdrawalStatus.PROCESSING);
        const failedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.FAILED ||
            p.status === client_1.WithdrawalStatus.CANCELLED ||
            p.status === client_1.WithdrawalStatus.REJECTED);
        const totalAmount = completedPayments.reduce((sum, payment) => sum + payment.amount, 0);
        const totalTransactions = payments.length;
        return {
            totalAmount,
            totalTransactions,
            completedTransactions: completedPayments.length,
            pendingTransactions: pendingPayments.length,
            failedTransactions: failedPayments.length,
            successRate: totalTransactions > 0
                ? (completedPayments.length / totalTransactions) * 100
                : 0,
        };
    }
    async getPaymentOverview(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const recentTransactions = await this.getRecentTransactions(userId, 5);
        return {
            wallet: wallet
                ? {
                    balance: wallet.balance,
                    pendingBalance: wallet.pendingBalance,
                    totalEarnings: wallet.totalEarnings,
                    totalWithdrawn: wallet.totalWithdrawn,
                }
                : null,
            recentTransactions,
            totalPayments: payments.length,
        };
    }
    async getPaymentTrends(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true },
        });
        const now = new Date();
        const trends = [];
        for (let i = 2; i >= 0; i--) {
            const month = new Date(now.getFullYear(), now.getMonth() - i, 1);
            const monthKey = `${month.getFullYear()}-${(month.getMonth() + 1).toString().padStart(2, '0')}`;
            const monthPayments = payments.filter((p) => {
                const paymentMonth = `${p.createdAt.getFullYear()}-${(p.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
                return paymentMonth === monthKey;
            });
            const total = monthPayments.reduce((sum, payment) => sum + payment.amount, 0);
            trends.push({
                month: monthKey,
                total,
                count: monthPayments.length,
            });
        }
        return trends;
    }
    async getPaymentRisk(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const failedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.FAILED ||
            p.status === client_1.WithdrawalStatus.CANCELLED ||
            p.status === client_1.WithdrawalStatus.REJECTED);
        const reportedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.REPORTED);
        const riskScore = Math.min(100, failedPayments.length * 10 + reportedPayments.length * 20);
        return {
            riskScore,
            failedPayments: failedPayments.length,
            reportedPayments: reportedPayments.length,
            totalPayments: payments.length,
            riskLevel: riskScore < 30 ? 'low' : riskScore < 70 ? 'medium' : 'high',
        };
    }
    async getPaymentCompliance(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        return {
            kycStatus: wallet?.kycStatus || client_1.WithdrawalStatus.PENDING,
            verifiedPayments: payments.filter((p) => p.verifiedAt).length,
            totalPayments: payments.length,
            complianceRate: payments.length > 0
                ? (payments.filter((p) => p.verifiedAt).length / payments.length) *
                    100
                : 0,
        };
    }
    async getPaymentSecurity(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        return {
            walletVerified: !!wallet?.verifiedAt,
            walletSuspended: !!wallet?.suspendedAt,
            kycCompleted: wallet?.kycStatus === 'approved',
            twoFactorAuth: false,
            securityScore: wallet?.verifiedAt && wallet.kycStatus === 'approved'
                ? 90
                : wallet?.verifiedAt
                    ? 60
                    : 30,
        };
    }
    async getPaymentPerformance(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const completedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.COMPLETED);
        let totalProcessingTime = 0;
        let completedWithTimeline = 0;
        completedPayments.forEach((payment) => {
            if (payment.processedAt && payment.completedAt) {
                const processingTime = payment.completedAt.getTime() - payment.processedAt.getTime();
                totalProcessingTime += processingTime;
                completedWithTimeline++;
            }
        });
        const avgProcessingTime = completedWithTimeline > 0
            ? totalProcessingTime / completedWithTimeline
            : 0;
        return {
            avgProcessingTime,
            totalPayments: payments.length,
            completedPayments: completedPayments.length,
            successRate: payments.length > 0
                ? (completedPayments.length / payments.length) * 100
                : 0,
            performanceScore: payments.length > 0
                ? Math.min(100, (completedPayments.length / payments.length) * 100)
                : 0,
        };
    }
    async getPaymentAlerts(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const alerts = [];
        if (wallet && wallet.balance < 100) {
            alerts.push({
                type: 'low_balance',
                message: 'Low wallet balance',
                severity: 'warning',
                timestamp: new Date(),
            });
        }
        const recentFailedPayments = payments.filter((p) => (p.status === client_1.WithdrawalStatus.FAILED ||
            p.status === client_1.WithdrawalStatus.CANCELLED ||
            p.status === client_1.WithdrawalStatus.REJECTED) &&
            new Date().getTime() - p.updatedAt.getTime() < 7 * 24 * 60 * 60 * 1000);
        if (recentFailedPayments.length > 0) {
            alerts.push({
                type: 'failed_payments',
                message: `You have ${recentFailedPayments.length} failed payments in the last 7 days`,
                severity: 'warning',
                timestamp: new Date(),
            });
        }
        const largePayments = payments.filter((p) => p.amount > 1000 &&
            new Date().getTime() - p.createdAt.getTime() < 24 * 60 * 60 * 1000);
        if (largePayments.length > 0) {
            alerts.push({
                type: 'large_payment',
                message: `Large payment detected: ${largePayments[0].amount} ${largePayments[0].currency}`,
                severity: 'info',
                timestamp: new Date(),
            });
        }
        return alerts;
    }
    async getPaymentRecommendations(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const recommendations = [];
        if (wallet && !wallet.verifiedAt) {
            recommendations.push({
                type: 'verify_wallet',
                message: 'Verify your wallet to increase security and limits',
                priority: 'high',
            });
        }
        if (wallet && wallet.kycStatus !== 'approved') {
            recommendations.push({
                type: 'complete_kyc',
                message: 'Complete KYC verification to unlock higher transaction limits',
                priority: 'medium',
            });
        }
        const paymentMethods = payments.reduce((acc, payment) => {
            acc[payment.paymentMethod] = (acc[payment.paymentMethod] || 0) + 1;
            return acc;
        }, {});
        const preferredMethod = Object.entries(paymentMethods).sort((a, b) => b[1] - a[1])[0];
        if (preferredMethod && preferredMethod[1] > 5) {
            recommendations.push({
                type: 'payment_method',
                message: `You frequently use ${preferredMethod[0]} payments. Consider setting it as default.`,
                priority: 'low',
            });
        }
        return recommendations;
    }
    async getPaymentInsights(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const paymentDays = payments.map((p) => p.createdAt.getDay());
        const dayFrequency = paymentDays.reduce((acc, day) => {
            acc[day] = (acc[day] || 0) + 1;
            return acc;
        }, {});
        const mostActiveDay = Object.entries(dayFrequency).sort((a, b) => b[1] - a[1])[0];
        const dayNames = [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
        ];
        const amounts = payments.map((p) => p.amount);
        const avgAmount = amounts.length > 0
            ? amounts.reduce((a, b) => a + b, 0) / amounts.length
            : 0;
        const maxAmount = amounts.length > 0 ? Math.max(...amounts) : 0;
        const minAmount = amounts.length > 0 ? Math.min(...amounts) : 0;
        return {
            behavioral: {
                mostActiveDay: mostActiveDay
                    ? dayNames[parseInt(mostActiveDay[0])]
                    : 'N/A',
                paymentFrequency: payments.length,
            },
            financial: {
                averageAmount: avgAmount,
                maxAmount,
                minAmount,
                totalVolume: amounts.reduce((a, b) => a + b, 0),
            },
            wallet: wallet
                ? {
                    balanceUtilization: wallet.totalEarnings > 0
                        ? (wallet.balance / wallet.totalEarnings) * 100
                        : 0,
                }
                : null,
        };
    }
    async getPaymentPredictions(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true },
        });
        const monthlyData = await this.getMonthlyEarnings(userId);
        const avgMonthlyEarnings = monthlyData.length > 0
            ? monthlyData.reduce((sum, month) => sum + month.earnings, 0) /
                monthlyData.length
            : 0;
        const predictions = [];
        const now = new Date();
        for (let i = 1; i <= 3; i++) {
            const futureMonth = new Date(now.getFullYear(), now.getMonth() + i, 1);
            const monthKey = `${futureMonth.getFullYear()}-${(futureMonth.getMonth() + 1).toString().padStart(2, '0')}`;
            predictions.push({
                month: monthKey,
                predictedEarnings: Math.round(avgMonthlyEarnings),
                confidence: Math.max(30, 100 - i * 20),
            });
        }
        return {
            monthlyPredictions: predictions,
            trend: avgMonthlyEarnings > 0 ? 'stable' : 'declining',
        };
    }
    async getPaymentForecast(userId) {
        return this.getPaymentPredictions(userId);
    }
    async getPaymentBudget(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true },
        });
        const monthlyData = await this.getMonthlyEarnings(userId);
        const avgMonthlySpending = monthlyData.length > 0
            ? monthlyData.reduce((sum, month) => sum + month.earnings, 0) /
                monthlyData.length
            : 0;
        return {
            monthlyBudget: avgMonthlySpending * 1.2,
            currentSpending: avgMonthlySpending,
            remainingBudget: Math.max(0, avgMonthlySpending * 1.2 - avgMonthlySpending),
            walletBalance: wallet ? wallet.balance : 0,
        };
    }
    async getPaymentGoals(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true, masterId: true },
        });
        const goals = [];
        const totalEarnings = wallet ? wallet.totalEarnings : 0;
        const savingsTarget = totalEarnings * 0.2;
        const currentSavings = wallet ? wallet.balance : 0;
        const savingsProgress = savingsTarget > 0 ? (currentSavings / savingsTarget) * 100 : 0;
        goals.push({
            id: 'savings',
            name: 'Savings Goal',
            target: savingsTarget,
            current: currentSavings,
            progress: Math.min(100, savingsProgress),
            status: savingsProgress >= 100 ? client_1.WithdrawalStatus.COMPLETED : 'in_progress',
        });
        const transactionGoal = 50;
        const currentTransactions = payments.length;
        const transactionProgress = (currentTransactions / transactionGoal) * 100;
        goals.push({
            id: 'transactions',
            name: 'Transaction Volume Goal',
            target: transactionGoal,
            current: currentTransactions,
            progress: Math.min(100, transactionProgress),
            status: transactionProgress >= 100 ? client_1.WithdrawalStatus.COMPLETED : 'in_progress',
        });
        return goals;
    }
    async getPaymentHabits(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const hourDistribution = payments.reduce((acc, payment) => {
            const hour = payment.createdAt.getHours();
            const timePeriod = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
            acc[timePeriod] = (acc[timePeriod] || 0) + 1;
            return acc;
        }, {});
        const methodPreferences = payments.reduce((acc, payment) => {
            acc[payment.paymentMethod] = (acc[payment.paymentMethod] || 0) + 1;
            return acc;
        }, {});
        const paymentDates = payments.map((p) => p.createdAt.toDateString());
        const uniqueDays = [...new Set(paymentDates)];
        const frequency = uniqueDays.length > 0 ? payments.length / uniqueDays.length : 0;
        return {
            timePreferences: hourDistribution,
            methodPreferences,
            frequency: `${frequency.toFixed(1)} payments per day`,
            consistency: payments.length > 10 ? 'high' : payments.length > 5 ? 'medium' : 'low',
        };
    }
    async getSpendingAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, paymentMethod: true, clientId: true, masterId: true },
        });
        const outgoingPayments = payments.filter((p) => p.clientId === userId);
        const incomingPayments = payments.filter((p) => p.masterId === userId);
        const spendingByMethod = outgoingPayments.reduce((acc, payment) => {
            acc[payment.paymentMethod] =
                (acc[payment.paymentMethod] || 0) + payment.amount;
            return acc;
        }, {});
        const incomeByMethod = incomingPayments.reduce((acc, payment) => {
            acc[payment.paymentMethod] =
                (acc[payment.paymentMethod] || 0) + payment.amount;
            return acc;
        }, {});
        return {
            totalSpent: outgoingPayments.reduce((sum, p) => sum + p.amount, 0),
            totalIncome: incomingPayments.reduce((sum, p) => sum + p.amount, 0),
            spendingByMethod,
            incomeByMethod,
            netBalance: incomingPayments.reduce((sum, p) => sum + p.amount, 0) -
                outgoingPayments.reduce((sum, p) => sum + p.amount, 0),
            transactionCount: {
                outgoing: outgoingPayments.length,
                incoming: incomingPayments.length,
            },
        };
    }
    async getIncomeAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { masterId: userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, projectId: true },
        });
        const incomeByProject = payments.reduce((acc, payment) => {
            const projectId = payment.projectId;
            acc[projectId] = (acc[projectId] || 0) + payment.amount;
            return acc;
        }, {});
        const monthlyIncome = await this.getMonthlyEarnings(userId);
        return {
            totalIncome: payments.reduce((sum, p) => sum + p.amount, 0),
            incomeByProject,
            monthlyIncome,
            averageIncomePerTransaction: payments.length > 0
                ? payments.reduce((sum, p) => sum + p.amount, 0) / payments.length
                : 0,
            topEarningProjects: Object.entries(incomeByProject)
                .sort(([, a], [, b]) => b - a)
                .slice(0, 5)
                .map(([projectId, amount]) => ({
                projectId: parseInt(projectId),
                amount,
            })),
        };
    }
    async getNetWorthAnalysis(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        if (!wallet)
            return { netWorth: 0, assets: 0, liabilities: 0 };
        return {
            netWorth: wallet.balance + wallet.pendingBalance,
            assets: {
                availableBalance: wallet.balance,
                pendingBalance: wallet.pendingBalance,
            },
            growth: {
                totalEarnings: wallet.totalEarnings,
                totalWithdrawn: wallet.totalWithdrawn,
                netGrowth: wallet.totalEarnings - wallet.totalWithdrawn,
            },
        };
    }
    async getCashFlowAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true, clientId: true, masterId: true },
        });
        const outgoing = payments.filter((p) => p.clientId === userId);
        const incoming = payments.filter((p) => p.masterId === userId);
        const monthlyCashFlow = {};
        outgoing.forEach((payment) => {
            const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
            if (!monthlyCashFlow[month]) {
                monthlyCashFlow[month] = { income: 0, expenses: 0, net: 0 };
            }
            monthlyCashFlow[month].expenses += payment.amount;
        });
        incoming.forEach((payment) => {
            const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
            if (!monthlyCashFlow[month]) {
                monthlyCashFlow[month] = { income: 0, expenses: 0, net: 0 };
            }
            monthlyCashFlow[month].income += payment.amount;
        });
        Object.keys(monthlyCashFlow).forEach((month) => {
            monthlyCashFlow[month].net =
                monthlyCashFlow[month].income - monthlyCashFlow[month].expenses;
        });
        return {
            totalIncome: incoming.reduce((sum, p) => sum + p.amount, 0),
            totalExpenses: outgoing.reduce((sum, p) => sum + p.amount, 0),
            netCashFlow: incoming.reduce((sum, p) => sum + p.amount, 0) -
                outgoing.reduce((sum, p) => sum + p.amount, 0),
            monthlyCashFlow,
        };
    }
    async getDebtAnalysis(userId) {
        return {
            totalDebt: 0,
            debtToIncomeRatio: 0,
            monthlyDebtPayments: 0,
            debtCategories: {},
            creditScore: 0,
            debtTrend: 'stable',
        };
    }
    async getInvestmentAnalysis(userId) {
        return {
            totalInvestments: 0,
            portfolioValue: 0,
            investmentReturns: 0,
            riskExposure: 0,
            assetAllocation: {},
            performance: {
                overall: 0,
                annualized: 0,
            },
        };
    }
    async getRetirementAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, clientId: true, masterId: true },
        });
        const totalEarnings = payments
            .filter((p) => p.masterId === userId)
            .reduce((sum, p) => sum + p.amount, 0);
        const totalSpending = payments
            .filter((p) => p.clientId === userId)
            .reduce((sum, p) => sum + p.amount, 0);
        const retirementSavings = totalEarnings * 0.2;
        const yearsToRetirement = 30;
        const projectedRetirementFund = retirementSavings * yearsToRetirement * 1.05;
        return {
            currentRetirementSavings: retirementSavings,
            projectedRetirementFund,
            yearsToRetirement,
            monthlyRetirementContributions: retirementSavings / (yearsToRetirement * 12),
            retirementReadinessScore: Math.min(100, (retirementSavings / (totalEarnings * 0.3)) * 100),
        };
    }
    async getInsuranceAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, description: true },
        });
        const insurancePayments = payments.filter((p) => p.description.toLowerCase().includes('insurance') ||
            p.description.toLowerCase().includes('asigurare'));
        const totalInsuranceSpent = insurancePayments.reduce((sum, p) => sum + p.amount, 0);
        const monthlyAverage = totalInsuranceSpent / 12;
        return {
            totalInsuranceSpent,
            monthlyAverage,
            insurancePayments: insurancePayments.length,
            insuranceTypes: this.categorizeInsurancePayments(insurancePayments),
            coverageRatio: payments.length > 0
                ? (insurancePayments.length / payments.length) * 100
                : 0,
        };
    }
    categorizeInsurancePayments(payments) {
        const categories = {
            health: 0,
            life: 0,
            property: 0,
            auto: 0,
            other: 0,
        };
        payments.forEach((payment) => {
            const desc = payment.description.toLowerCase();
            if (desc.includes('health') ||
                desc.includes('medical') ||
                desc.includes('sanatate')) {
                categories.health += payment.amount;
            }
            else if (desc.includes('life') || desc.includes('viata')) {
                categories.life += payment.amount;
            }
            else if (desc.includes('property') ||
                desc.includes('home') ||
                desc.includes('casa') ||
                desc.includes('proprietate')) {
                categories.property += payment.amount;
            }
            else if (desc.includes('auto') ||
                desc.includes('car') ||
                desc.includes('masina')) {
                categories.auto += payment.amount;
            }
            else {
                categories.other += payment.amount;
            }
        });
        return categories;
    }
    async getTaxAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, clientId: true, masterId: true },
        });
        const incomePayments = payments.filter((p) => p.masterId === userId);
        const expensePayments = payments.filter((p) => p.clientId === userId);
        const totalIncome = incomePayments.reduce((sum, p) => sum + p.amount, 0);
        const totalExpenses = expensePayments.reduce((sum, p) => sum + p.amount, 0);
        const taxableIncome = totalIncome - totalExpenses;
        const estimatedTax = Math.max(0, taxableIncome * 0.25);
        return {
            totalIncome,
            totalExpenses,
            taxableIncome,
            estimatedTax,
            taxRate: 25,
            taxToIncomeRatio: totalIncome > 0 ? (estimatedTax / totalIncome) * 100 : 0,
            deductions: totalExpenses,
        };
    }
    async getCreditAnalysis(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const successfulPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.COMPLETED).length;
        const failedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.FAILED ||
            p.status === client_1.WithdrawalStatus.CANCELLED ||
            p.status === client_1.WithdrawalStatus.REJECTED).length;
        const totalPayments = payments.length;
        const paymentSuccessRate = totalPayments > 0 ? (successfulPayments / totalPayments) * 100 : 0;
        const walletHealthScore = wallet
            ? (wallet.balance > 0 ? 80 : 40) +
                (wallet.kycStatus === 'approved' ? 20 : 0)
            : 0;
        const creditScore = Math.min(850, Math.max(300, paymentSuccessRate * 0.6 + walletHealthScore * 0.4));
        return {
            creditScore: Math.round(creditScore),
            paymentSuccessRate,
            totalPayments,
            successfulPayments,
            failedPayments,
            walletHealthScore,
            creditRating: creditScore >= 750
                ? 'excellent'
                : creditScore >= 700
                    ? 'good'
                    : creditScore >= 650
                        ? 'fair'
                        : creditScore >= 600
                            ? 'poor'
                            : 'bad',
        };
    }
    async getFraudAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const reportedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.REPORTED);
        const rejectedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.REJECTED);
        const flaggedPayments = payments.filter((p) => p.flaggedAsInappropriate);
        const fraudRiskScore = Math.min(100, reportedPayments.length * 20 +
            rejectedPayments.length * 10 +
            flaggedPayments.length * 15);
        return {
            fraudRiskScore,
            reportedPayments: reportedPayments.length,
            rejectedPayments: rejectedPayments.length,
            flaggedPayments: flaggedPayments.length,
            fraudRiskLevel: fraudRiskScore < 30 ? 'low' : fraudRiskScore < 70 ? 'medium' : 'high',
            suspiciousActivities: this.identifySuspiciousActivities(payments),
            securityRecommendations: await this.getFraudSecurityRecommendations(userId),
        };
    }
    identifySuspiciousActivities(payments) {
        const suspicious = [];
        const largeTransactions = payments.filter((p) => p.amount > 10000);
        if (largeTransactions.length > 0) {
            suspicious.push({
                type: 'large_transactions',
                count: largeTransactions.length,
                description: 'Large transactions detected',
            });
        }
        const failedTransactions = payments.filter((p) => p.status === client_1.WithdrawalStatus.FAILED);
        if (failedTransactions.length > 5) {
            suspicious.push({
                type: 'high_failure_rate',
                count: failedTransactions.length,
                description: 'High number of failed transactions',
            });
        }
        return suspicious;
    }
    async getFraudSecurityRecommendations(userId) {
        const recommendations = [];
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const paymentMethods = [...new Set(payments.map((p) => p.paymentMethod))];
        if (paymentMethods.length === 1) {
            recommendations.push({
                type: 'payment_method_diversity',
                message: 'Consider using multiple payment methods for security',
                priority: 'medium',
            });
        }
        return recommendations;
    }
    async getFeeAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true },
        });
        const feeRate = 0.029;
        const fixedFee = 0.3;
        const totalAmount = payments.reduce((sum, p) => sum + p.amount, 0);
        const totalFees = payments.reduce((sum, p) => sum + (p.amount * feeRate + fixedFee), 0);
        const averageFeePerTransaction = payments.length > 0 ? totalFees / payments.length : 0;
        return {
            totalFeesPaid: parseFloat(totalFees.toFixed(2)),
            totalTransactionAmount: totalAmount,
            feeToTransactionRatio: totalAmount > 0 ? (totalFees / totalAmount) * 100 : 0,
            averageFeePerTransaction: parseFloat(averageFeePerTransaction.toFixed(2)),
            feeBreakdown: {
                percentageFees: parseFloat((totalAmount * feeRate).toFixed(2)),
                fixedFees: parseFloat((payments.length * fixedFee).toFixed(2)),
            },
            feeOptimizationScore: 0,
        };
    }
    calculateFeeOptimizationScore(payments) {
        if (payments.length === 0)
            return 50;
        const avgTransactionSize = payments.reduce((sum, p) => sum + p.amount, 0) / payments.length;
        const efficiencyScore = Math.min(100, avgTransactionSize / 100);
        return Math.round(efficiencyScore);
    }
    async getExchangeAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { currency: true },
        });
        const multiCurrencyPayments = payments.filter((p) => p.currency !== 'RON');
        const currencies = [...new Set(payments.map((p) => p.currency))];
        const exchangeTransactions = multiCurrencyPayments.length;
        return {
            currenciesUsed: currencies,
            exchangeTransactions,
            multiCurrencyUsage: payments.length > 0
                ? (exchangeTransactions / payments.length) * 100
                : 0,
            currencyPreferences: {},
            exchangeComplexityScore: Math.min(100, currencies.length * 20),
        };
    }
    analyzeCurrencyPreferences(payments) {
        const preferences = {};
        payments.forEach((payment) => {
            preferences[payment.currency] =
                (preferences[payment.currency] || 0) + (payment.amount || 0);
        });
        return preferences;
    }
    async getInternationalAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, currency: true, description: true },
        });
        const internationalPayments = payments.filter((p) => p.currency !== 'RON' ||
            p.description.toLowerCase().includes('international') ||
            p.description.toLowerCase().includes('international'));
        const totalInternationalVolume = internationalPayments.reduce((sum, p) => sum + p.amount, 0);
        return {
            internationalTransactions: internationalPayments.length,
            totalInternationalVolume,
            internationalToTotalRatio: payments.length > 0
                ? (internationalPayments.length / payments.length) * 100
                : 0,
            internationalVolumeRatio: payments.reduce((sum, p) => sum + p.amount, 0) > 0
                ? (totalInternationalVolume /
                    payments.reduce((sum, p) => sum + p.amount, 0)) *
                    100
                : 0,
            crossBorderScore: internationalPayments.length > 0 ? 80 : 40,
        };
    }
    async getCryptoAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, description: true },
        });
        const cryptoPayments = payments.filter((p) => p.description.toLowerCase().includes('crypto') ||
            p.description.toLowerCase().includes('bitcoin') ||
            p.description.toLowerCase().includes('ethereum'));
        const totalCryptoVolume = cryptoPayments.reduce((sum, p) => sum + p.amount, 0);
        return {
            cryptoTransactions: cryptoPayments.length,
            totalCryptoVolume,
            cryptoAdoptionRate: payments.length > 0
                ? (cryptoPayments.length / payments.length) * 100
                : 0,
            cryptoToTotalRatio: payments.reduce((sum, p) => sum + p.amount, 0) > 0
                ? (totalCryptoVolume /
                    payments.reduce((sum, p) => sum + p.amount, 0)) *
                    100
                : 0,
            cryptoTrend: cryptoPayments.length > 0 ? 'adopting' : 'not_using',
        };
    }
    async getWeb3Analysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { description: true },
        });
        const web3Payments = payments.filter((p) => p.description.toLowerCase().includes('web3') ||
            p.description.toLowerCase().includes('nft') ||
            p.description.toLowerCase().includes('defi') ||
            p.description.toLowerCase().includes('dao'));
        return {
            web3Transactions: web3Payments.length,
            web3AdoptionScore: Math.min(100, web3Payments.length * 10),
            web3Trend: web3Payments.length > 0 ? 'emerging' : 'not_adopted',
            web3Opportunities: this.identifyWeb3Opportunities(userId),
        };
    }
    identifyWeb3Opportunities(userId) {
        const opportunities = [];
        opportunities.push({
            type: 'education',
            message: 'Learn about Web3 payment opportunities',
            priority: 'low',
        });
        return opportunities;
    }
    async getStakingAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, description: true },
        });
        const stakingPayments = payments.filter((p) => p.description.toLowerCase().includes('staking') ||
            p.description.toLowerCase().includes('yield') ||
            p.description.toLowerCase().includes('interest'));
        const totalStakingRewards = stakingPayments.reduce((sum, p) => sum + p.amount, 0);
        const stakingReturnRate = payments.length > 0
            ? (totalStakingRewards /
                payments.reduce((sum, p) => sum + p.amount, 0)) *
                100
            : 0;
        return {
            stakingTransactions: stakingPayments.length,
            totalStakingRewards,
            stakingReturnRate,
            stakingPerformance: stakingReturnRate > 5
                ? 'good'
                : stakingReturnRate > 2
                    ? 'moderate'
                    : 'low',
            stakingOpportunities: this.identifyStakingOpportunities(),
        };
    }
    identifyStakingOpportunities() {
        const opportunities = [];
        opportunities.push({
            type: 'diversification',
            message: 'Consider diversifying staking assets',
            priority: 'medium',
        });
        return opportunities;
    }
    async getTradingAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, description: true },
        });
        const tradingPayments = payments.filter((p) => p.description.toLowerCase().includes('trade') ||
            p.description.toLowerCase().includes('exchange') ||
            p.description.toLowerCase().includes('buy') ||
            p.description.toLowerCase().includes('sell'));
        const totalTradingVolume = tradingPayments.reduce((sum, p) => sum + p.amount, 0);
        return {
            tradingTransactions: tradingPayments.length,
            totalTradingVolume,
            tradingFrequency: tradingPayments.length > 0
                ? tradingPayments.length / payments.length
                : 0,
            tradingPerformance: totalTradingVolume > 1000 ? 'high' : 'low',
            tradingOpportunities: this.identifyTradingOpportunities(),
        };
    }
    identifyTradingOpportunities() {
        const opportunities = [];
        opportunities.push({
            type: 'market_analysis',
            message: 'Analyze market trends to identify trading opportunities',
            priority: 'medium',
        });
        return opportunities;
    }
    async getPortfolioAnalysis(userId) {
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, clientId: true, masterId: true, projectId: true },
        });
        const totalIncome = payments
            .filter((p) => p.masterId === userId)
            .reduce((sum, p) => sum + p.amount, 0);
        const totalExpenses = payments
            .filter((p) => p.clientId === userId)
            .reduce((sum, p) => sum + p.amount, 0);
        const netWorth = wallet ? wallet.balance + wallet.pendingBalance : 0;
        return {
            netWorth,
            totalAssets: netWorth,
            totalLiabilities: 0,
            incomeToNetWorthRatio: netWorth > 0 ? (totalIncome / netWorth) * 100 : 0,
            expenseToNetWorthRatio: netWorth > 0 ? (totalExpenses / netWorth) * 100 : 0,
            portfolioHealth: netWorth > 0 ? 'positive' : 'negative',
            diversificationScore: 0,
        };
    }
    calculateDiversificationScore(payments) {
        const incomeSources = [
            ...new Set(payments.filter((p) => p.masterId).map((p) => p.projectId)),
        ];
        const expenseCategories = [
            ...new Set(payments
                .filter((p) => p.clientId)
                .map((p) => {
                const desc = (p.description || '').toLowerCase();
                if (desc.includes('material') || desc.includes('supply'))
                    return 'materials';
                if (desc.includes('service') || desc.includes('serviciu'))
                    return 'services';
                return 'other';
            })),
        ];
        return Math.min(100, (incomeSources.length + expenseCategories.length) * 10);
    }
    async getRiskAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({ where: { userId } });
        const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
        const financialRisk = await this.calculateFinancialRisk(payments, wallet);
        const transactionRisk = this.calculateTransactionRisk(payments);
        const marketRisk = this.calculateMarketRisk(payments);
        const overallRiskScore = (financialRisk + transactionRisk + marketRisk) / 3;
        return {
            overallRiskScore: Math.round(overallRiskScore),
            financialRisk,
            transactionRisk,
            marketRisk,
            riskLevel: overallRiskScore < 30
                ? 'low'
                : overallRiskScore < 70
                    ? 'medium'
                    : 'high',
            riskRecommendations: this.getRiskRecommendations(overallRiskScore),
        };
    }
    async calculateFinancialRisk(payments, wallet) {
        if (!wallet)
            return 80;
        const incomePayments = payments.filter((p) => p.masterId === wallet.userId && p.status === client_1.WithdrawalStatus.COMPLETED);
        const expensePayments = payments.filter((p) => p.clientId === wallet.userId && p.status === client_1.WithdrawalStatus.COMPLETED);
        const monthlyIncome = incomePayments.reduce((sum, p) => sum + p.amount, 0) / 12;
        const monthlyExpenses = expensePayments.reduce((sum, p) => sum + p.amount, 0) / 12;
        const incomeToExpenseRatio = monthlyExpenses > 0 ? monthlyIncome / monthlyExpenses : 10;
        let risk = 50;
        if (incomeToExpenseRatio < 1) {
            risk = 90;
        }
        else if (incomeToExpenseRatio < 2) {
            risk = 70;
        }
        else if (incomeToExpenseRatio < 5) {
            risk = 40;
        }
        else {
            risk = 20;
        }
        return risk;
    }
    calculateTransactionRisk(payments) {
        const failedPayments = payments.filter((p) => p.status === client_1.WithdrawalStatus.FAILED || p.status === client_1.WithdrawalStatus.CANCELLED).length;
        const totalPayments = payments.length;
        return totalPayments > 0
            ? Math.min(100, (failedPayments / totalPayments) * 100)
            : 30;
    }
    calculateMarketRisk(payments) {
        const recentPayments = payments.filter((p) => {
            const daysAgo = (new Date().getTime() - p.createdAt.getTime()) / (1000 * 60 * 60 * 24);
            return daysAgo < 90;
        });
        const paymentDiversity = [
            ...new Set(recentPayments.map((p) => p.projectId)),
        ].length;
        return Math.max(20, 100 - paymentDiversity * 5);
    }
    getRiskRecommendations(riskScore) {
        const recommendations = [];
        if (riskScore > 70) {
            recommendations.push({
                type: 'high_risk',
                message: 'Consider diversifying income sources and reducing expenses',
                priority: 'high',
            });
        }
        else if (riskScore > 40) {
            recommendations.push({
                type: 'medium_risk',
                message: 'Monitor spending patterns and maintain emergency fund',
                priority: 'medium',
            });
        }
        else {
            recommendations.push({
                type: 'low_risk',
                message: 'Financial position is stable, consider growth opportunities',
                priority: 'low',
            });
        }
        return recommendations;
    }
    async getEsgAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, description: true, verifiedAt: true },
        });
        const esgPayments = payments.filter((p) => p.description.toLowerCase().includes('sustainable') ||
            p.description.toLowerCase().includes('green') ||
            p.description.toLowerCase().includes('eco') ||
            p.description.toLowerCase().includes('social') ||
            p.description.toLowerCase().includes('community'));
        const esgScore = Math.min(100, esgPayments.length * 15);
        return {
            esgScore,
            sustainableTransactions: esgPayments.length,
            esgAdoptionRate: payments.length > 0 ? (esgPayments.length / payments.length) * 100 : 0,
            environmentalScore: 0,
            socialScore: 0,
            governanceScore: 0,
        };
    }
    calculateEnvironmentalScore(payments) {
        const greenPayments = payments.filter((p) => p.description.toLowerCase().includes('green') ||
            p.description.toLowerCase().includes('eco') ||
            p.description.toLowerCase().includes('sustainable'));
        return Math.min(100, greenPayments.length * 20);
    }
    calculateSocialScore(payments) {
        const socialPayments = payments.filter((p) => p.description.toLowerCase().includes('charity') ||
            p.description.toLowerCase().includes('donation') ||
            p.description.toLowerCase().includes('community') ||
            p.description.toLowerCase().includes('social'));
        return Math.min(100, socialPayments.length * 25);
    }
    calculateGovernanceScore(payments) {
        const verifiedPayments = payments.filter((p) => p.verifiedAt);
        return payments.length > 0
            ? (verifiedPayments.length / payments.length) * 100
            : 50;
    }
    async getMarketAnalysis(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true, createdAt: true, projectId: true },
        });
        const monthlyData = await this.getMonthlyEarnings(userId);
        const recentMonths = monthlyData.slice(-3);
        const trend = this.calculateTrend(recentMonths.map((m) => m.earnings));
        return {
            marketTrend: trend,
            volatilityScore: this.calculateVolatility(recentMonths.map((m) => m.earnings)),
            marketPosition: await this.calculateMarketPosition(userId),
            growthOpportunities: [],
        };
    }
    calculateTrend(values) {
        if (values.length < 2)
            return 'stable';
        const firstHalf = values.slice(0, Math.floor(values.length / 2));
        const secondHalf = values.slice(Math.floor(values.length / 2));
        const firstAvg = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
        const secondAvg = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;
        const change = ((secondAvg - firstAvg) / firstAvg) * 100;
        if (change > 10)
            return 'growing';
        if (change < -10)
            return 'declining';
        return 'stable';
    }
    calculateVolatility(values) {
        if (values.length <= 1)
            return 50;
        const mean = values.reduce((a, b) => a + b, 0) / values.length;
        const squaredDiffs = values.map((value) => Math.pow(value - mean, 2));
        const avgSquaredDiff = squaredDiffs.reduce((a, b) => a + b, 0) / squaredDiffs.length;
        const stdDev = Math.sqrt(avgSquaredDiff);
        return Math.min(100, (stdDev / mean) * 50);
    }
    async calculateMarketPosition(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId, status: client_1.WithdrawalStatus.COMPLETED },
            select: { amount: true },
        });
        const userVolume = payments.reduce((sum, p) => sum + p.amount, 0);
        const avgVolume = 5000;
        if (userVolume > avgVolume * 1.5)
            return 'leader';
        if (userVolume > avgVolume)
            return 'above_average';
        if (userVolume > avgVolume * 0.5)
            return 'average';
        return 'emerging';
    }
    identifyGrowthOpportunities(payments) {
        const opportunities = [];
        const monthlyGrowth = 0;
        if (monthlyGrowth < 10) {
            opportunities.push({
                type: 'volume_growth',
                message: 'Opportunity to increase transaction volume',
                priority: 'medium',
            });
        }
        return opportunities;
    }
    calculateMonthlyGrowth(payments) {
        const monthlyData = [];
        if (monthlyData.length < 2)
            return 0;
        const recentMonths = monthlyData.slice(-2);
        const previous = recentMonths[0].total;
        const current = recentMonths[1].total;
        return previous > 0 ? ((current - previous) / previous) * 100 : 0;
    }
    groupPaymentsByMonth(payments) {
        const grouped = {};
        payments.forEach((payment) => {
            const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
            grouped[month] = (grouped[month] || 0) + payment.amount;
        });
        return Object.entries(grouped)
            .map(([month, total]) => ({ month, total }))
            .sort((a, b) => a.month.localeCompare(b.month));
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PaymentsService);
//# sourceMappingURL=payments.service.js.map