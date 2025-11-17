import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { UpdatePaymentDto } from './dto/update-payment.dto';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { UpdateWalletDto } from './dto/update-wallet.dto';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { UpdateWithdrawalDto } from './dto/update-withdrawal.dto';
import { Payment, Wallet, Withdrawal, PaymentStatus, WithdrawalStatus } from '@prisma/client';

// Analytics interfaces
export interface PaymentStats {
  totalAmount: number;
  totalTransactions: number;
  completedTransactions: number;
  pendingTransactions: number;
  failedTransactions: number;
  successRate: number;
}

export interface PaymentOverview {
  wallet: {
    balance: number;
    pendingBalance: number;
    totalEarnings: number;
    totalWithdrawn: number;
  } | null;
  recentTransactions: (Payment | Withdrawal)[];
  totalPayments: number;
}

export interface MonthlyTrend {
  month: string;
  total: number;
  count: number;
}

export interface PaymentRisk {
  riskScore: number;
  failedPayments: number;
  reportedPayments: number;
  totalPayments: number;
  riskLevel: 'low' | 'medium' | 'high';
}

export interface PaymentCompliance {
  kycStatus: string;
  verifiedPayments: number;
  totalPayments: number;
  complianceRate: number;
}

export interface PaymentSecurity {
  walletVerified: boolean;
  walletSuspended: boolean;
  kycCompleted: boolean;
  twoFactorAuth: boolean;
  securityScore: number;
}

export interface PaymentPerformance {
  avgProcessingTime: number;
  totalPayments: number;
  completedPayments: number;
  successRate: number;
  performanceScore: number;
}

export interface PaymentAlert {
  type: string;
  message: string;
  severity: 'info' | 'warning' | 'error';
  timestamp: Date;
}

export interface PaymentRecommendation {
  type: string;
  message: string;
  priority: 'low' | 'medium' | 'high';
}

export interface PaymentInsights {
  behavioral: {
    mostActiveDay: string;
    paymentFrequency: number;
  };
  financial: {
    averageAmount: number;
    maxAmount: number;
    minAmount: number;
    totalVolume: number;
  };
  wallet: {
    balanceUtilization: number;
  } | null;
}

export interface KycData {
  documents?: string[];
  idNumber?: string;
  nationality?: string;
  dateOfBirth?: string;
  address?: string;
  [key: string]: unknown;
}

export interface BankAccountData {
  id?: string;
  accountNumber: string;
  bankName: string;
  accountHolderName: string;
  iban?: string;
  swiftCode?: string;
  currency?: string;
  isPrimary?: boolean;
}

export interface SuspiciousActivity {
  type: string;
  count: number;
  description: string;
}

export interface SecurityRecommendation {
  type: string;
  message: string;
  priority: 'low' | 'medium' | 'high';
}

export interface Web3Opportunity {
  type: string;
  description: string;
  estimatedReturn: number;
  riskLevel: 'low' | 'medium' | 'high';
}

export interface StakingOpportunity {
  platform: string;
  apr: number;
  minimumStake: number;
  lockPeriod: string;
  riskLevel: 'low' | 'medium' | 'high';
}

export interface TradingOpportunity {
  pair: string;
  signal: 'buy' | 'sell' | 'hold';
  confidence: number;
  potentialProfit: number;
}

export interface RiskRecommendation {
  type: string;
  message: string;
  action: string;
  priority: 'low' | 'medium' | 'high';
}

export interface TaxOptimizationOpportunity {
  type: string;
  description: string;
  potentialSavings: number;
  deadline?: string;
}

export interface MonthlyPaymentData {
  month: string;
  totalAmount: number;
  transactionCount: number;
  averageAmount: number;
}

export interface GrowthOpportunity {
  type: string;
  message: string;
  priority: 'low' | 'medium' | 'high';
  potentialIncrease?: number;
}

export interface MonthlyGrowthData {
  month: string;
  total: number;
  count: number;
}

export interface PaymentPrediction {
  month: string;
  predictedEarnings: number;
  confidence: number;
}

export interface PaymentForecast {
  monthlyPredictions: PaymentPrediction[];
  trend: string;
}

export interface PaymentBudget {
  monthlyBudget: number;
  currentSpending: number;
  remainingBudget: number;
  walletBalance: number;
}

export interface PaymentGoal {
  id: string;
  name: string;
  target: number;
  current: number;
  progress: number;
  status: 'COMPLETED' | 'in_progress';
}

export interface PaymentHabits {
  timePreferences: Record<string, number>;
  methodPreferences: Record<string, number>;
  frequency: string;
  consistency: 'low' | 'medium' | 'high';
}

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  // Payment methods
  async findAllPayments(): Promise<Payment[]> {
    return this.prisma.payment.findMany();
  }

  async findPaymentById(id: string): Promise<Payment | null> {
    return this.prisma.payment.findUnique({ where: { id } });
  }

  async findPaymentsByUserId(userId: string): Promise<Payment[]> {
    return this.prisma.payment.findMany({ where: { userId } });
  }

  async findPaymentsByProjectId(projectId: string): Promise<Payment[]> {
    return this.prisma.payment.findMany({ where: { projectId } });
  }

  async findPaymentsByStatus(status: string): Promise<Payment[]> {
    return this.prisma.payment.findMany({ where: { status: status as PaymentStatus } });
  }

  async findPaymentsByMethod(method: string): Promise<Payment[]> {
    return this.prisma.payment.findMany({ where: { method: method as any } });
  }

  async processPayment(id: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment || payment.status !== WithdrawalStatus.PENDING) {
      return null;
    }
    return this.prisma.payment.update({
      where: { id },
      data: { status: WithdrawalStatus.PROCESSING, processedAt: new Date() },
    });
  }

  async completePayment(id: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment || (payment.status !== WithdrawalStatus.PROCESSING && payment.status !== WithdrawalStatus.PENDING)) {
      return null;
    }

    const updatedPayment = await this.prisma.payment.update({
      where: { id },
      data: { status: WithdrawalStatus.COMPLETED, completedAt: new Date() },
    });

    // Update master's wallet
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

  async failPayment(id: string, reason: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment || (payment.status !== WithdrawalStatus.PROCESSING && payment.status !== WithdrawalStatus.PENDING)) {
      return null;
    }
    return this.prisma.payment.update({
      where: { id },
      data: { status: WithdrawalStatus.FAILED, failedAt: new Date(), failureReason: reason },
    });
  }

  async cancelPayment(id: string, reason: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment || payment.status !== WithdrawalStatus.PENDING) {
      return null;
    }
    return this.prisma.payment.update({
      where: { id },
      data: { status: WithdrawalStatus.CANCELLED, cancelledAt: new Date(), cancellationReason: reason },
    });
  }

  async verifyPayment(id: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment) {
      return null;
    }
    return this.prisma.payment.update({
      where: { id },
      data: { verifiedAt: new Date() },
    });
  }

  async rejectPayment(id: string, reason: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment) {
      return null;
    }
    return this.prisma.payment.update({
      where: { id },
      data: { status: WithdrawalStatus.REJECTED, rejectedAt: new Date(), rejectionReason: reason },
    });
  }

  async reportPayment(id: string, reason: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment) {
      return null;
    }
    return this.prisma.payment.update({
      where: { id },
      data: { status: WithdrawalStatus.REPORTED, reportedAt: new Date(), reportReason: reason },
    });
  }

  async refundPayment(id: string, reason: string): Promise<Payment | null> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment || payment.status !== WithdrawalStatus.COMPLETED) {
      return null;
    }

    const updatedPayment = await this.prisma.payment.update({
      where: { id },
      data: { status: PaymentStatus.REFUNDED, refundedAt: new Date(), refundReason: reason },
    });

    // Return funds to client's wallet
    const clientWallet = await this.prisma.wallet.findUnique({ where: { userId: updatedPayment.clientId } });
    if (clientWallet) {
      await this.prisma.wallet.update({
        where: { id: clientWallet.id },
        data: { balance: { increment: updatedPayment.amount } },
      });
    }

    // Deduct from master's wallet
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

  async createPayment(paymentData: CreatePaymentDto): Promise<Payment> {
    const newPayment = await this.prisma.payment.create({
      data: {
        ...paymentData,
      },
    });

    // Update wallet balances if payment is completed immediately
    if (newPayment.status === WithdrawalStatus.COMPLETED) {
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

  async updatePayment(id: string, updateData: UpdatePaymentDto): Promise<Payment | null> {
    return this.prisma.payment.update({
      where: { id },
      data: updateData,
    });
  }

  async deletePayment(id: string): Promise<Payment> {
    return this.prisma.payment.delete({ where: { id } });
  }

  // Wallet methods
  async findAllWallets(): Promise<Wallet[]> {
    return this.prisma.wallet.findMany();
  }

  async findWalletById(id: string): Promise<Wallet | null> {
    return this.prisma.wallet.findUnique({ where: { id } });
  }

  async findWalletByUserId(userId: string): Promise<Wallet | null> {
    return this.prisma.wallet.findUnique({ where: { userId } });
  }

  async createWallet(walletData: CreateWalletDto): Promise<Wallet> {
    return this.prisma.wallet.create({ data: walletData });
  }

  async updateWallet(id: string, updateData: UpdateWalletDto): Promise<Wallet | null> {
    return this.prisma.wallet.update({
      where: { id },
      data: updateData,
    });
  }

  async deleteWallet(id: string): Promise<Wallet> {
    return this.prisma.wallet.delete({ where: { id } });
  }

  async verifyWallet(id: string): Promise<Wallet | null> {
    const wallet = await this.prisma.wallet.findUnique({ where: { id } });
    if (!wallet) {
      return null;
    }
    return this.prisma.wallet.update({
      where: { id },
      data: { verifiedAt: new Date() },
    });
  }

  async suspendWallet(id: string, reason: string): Promise<Wallet | null> {
    const wallet = await this.prisma.wallet.findUnique({ where: { id } });
    if (!wallet) {
      return null;
    }
    return this.prisma.wallet.update({
      where: { id },
      data: { suspendedAt: new Date(), suspensionReason: reason },
    });
  }

  async reactivateWallet(id: string): Promise<Wallet | null> {
    const wallet = await this.prisma.wallet.findUnique({ where: { id } });
    if (!wallet) {
      return null;
    }
    return this.prisma.wallet.update({
      where: { id },
      data: { suspendedAt: null, suspensionReason: null },
    });
  }

  async submitKyc(id: string, kycData: KycData): Promise<Wallet | null> {
    const wallet = await this.prisma.wallet.findUnique({ where: { id } });
    if (!wallet) {
      return null;
    }
    return this.prisma.wallet.update({
      where: { id },
      data: { kycStatus: 'submitted', kycSubmittedAt: new Date(), kycDocuments: kycData.documents || [] },
    });
  }

  async addBankAccount(id: string, bankAccountData: BankAccountData): Promise<Wallet | null> {
    const wallet = await this.prisma.wallet.findUnique({ where: { id } });
    if (!wallet) {
      return null;
    }
    const currentBankAccounts = (wallet.bankAccounts || []) as BankAccountData[];
    return this.prisma.wallet.update({
      where: { id },
      data: { bankAccounts: [...currentBankAccounts, bankAccountData] },
    });
  }

  async removeBankAccount(id: string, accountid: string): Promise<Wallet | null> {
    const wallet = await this.prisma.wallet.findUnique({ where: { id } });
    if (!wallet) {
      return null;
    }
    const currentBankAccounts = (wallet.bankAccounts || []) as BankAccountData[];
    const updatedBankAccounts = currentBankAccounts.filter((acc) => acc.id !== accountid);
    return this.prisma.wallet.update({
      where: { id },
      data: { bankAccounts: updatedBankAccounts },
    });
  }

  // Withdrawal methods
  async findAllWithdrawals(): Promise<Withdrawal[]> {
    return this.prisma.withdrawal.findMany();
  }

  async findWithdrawalById(id: string): Promise<Withdrawal | null> {
    return this.prisma.withdrawal.findUnique({ where: { id } });
  }

  async findWithdrawalsByUserId(userId: string): Promise<Withdrawal[]> {
    return this.prisma.withdrawal.findMany({ where: { userId } });
  }

  async findWithdrawalsByWalletId(walletid: string): Promise<Withdrawal[]> {
    return this.prisma.withdrawal.findMany({ where: { walletId: walletid } });
  }

  async findWithdrawalsByStatus(status: string): Promise<Withdrawal[]> {
    return this.prisma.withdrawal.findMany({ where: { status: status as WithdrawalStatus } });
  }

  async createWithdrawal(withdrawalData: CreateWithdrawalDto): Promise<Withdrawal> {
    const newWithdrawal = await this.prisma.withdrawal.create({ data: withdrawalData });

    // Deduct from wallet balance
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

  async processWithdrawal(id: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal || withdrawal.status !== WithdrawalStatus.PENDING) {
      return null;
    }
    return this.prisma.withdrawal.update({
      where: { id },
      data: { status: WithdrawalStatus.PROCESSING, processedAt: new Date() },
    });
  }

  async completeWithdrawal(id: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal || withdrawal.status !== WithdrawalStatus.PROCESSING) {
      return null;
    }

    const updatedWithdrawal = await this.prisma.withdrawal.update({
      where: { id },
      data: { status: WithdrawalStatus.COMPLETED, completedAt: new Date() },
    });

    // Update wallet
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

  async updateWithdrawal(id: string, updateData: UpdateWithdrawalDto): Promise<Withdrawal | null> {
    return this.prisma.withdrawal.update({
      where: { id },
      data: updateData,
    });
  }

  async deleteWithdrawal(id: string): Promise<Withdrawal> {
    return this.prisma.withdrawal.delete({ where: { id } });
  }

  async failWithdrawal(id: string, reason: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal || (withdrawal.status !== WithdrawalStatus.PROCESSING && withdrawal.status !== WithdrawalStatus.PENDING)) {
      return null;
    }
    return this.prisma.withdrawal.update({
      where: { id },
      data: { status: WithdrawalStatus.FAILED, failedAt: new Date(), failureReason: reason },
    });
  }

  async verifyWithdrawal(id: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal) {
      return null;
    }
    return this.prisma.withdrawal.update({
      where: { id },
      data: { verifiedAt: new Date() },
    });
  }

  async rejectWithdrawal(id: string, reason: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal) {
      return null;
    }
    return this.prisma.withdrawal.update({
      where: { id },
      data: { status: WithdrawalStatus.REJECTED, rejectedAt: new Date(), rejectionReason: reason },
    });
  }

  async reportWithdrawal(id: string, reason: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal) {
      return null;
    }
    return this.prisma.withdrawal.update({
      where: { id },
      data: { status: WithdrawalStatus.REPORTED, reportedAt: new Date(), reportReason: reason },
    });
  }

  async cancelWithdrawal(id: string, reason: string): Promise<Withdrawal | null> {
    const withdrawal = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!withdrawal || withdrawal.status !== WithdrawalStatus.PENDING) {
      return null;
    }

    const updatedWithdrawal = await this.prisma.withdrawal.update({
      where: { id },
      data: { status: WithdrawalStatus.CANCELLED, cancelledAt: new Date(), cancellationReason: reason },
    });

    // Return funds to wallet
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

  // Analytics methods
  async getUserBalance(userId: string): Promise<number> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    return wallet ? wallet.balance : 0;
  }

  async getUserPendingBalance(userId: string): Promise<number> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    return wallet ? wallet.pendingBalance : 0;
  }

  async getTotalEarnings(userId: string): Promise<number> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    return wallet ? wallet.totalEarnings : 0;
  }

  async getTotalWithdrawn(userId: string): Promise<number> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    return wallet ? wallet.totalWithdrawn : 0;
  }

  async getPaymentHistory(userId: string, limit?: number): Promise<Payment[]> {
    return this.prisma.payment.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async getRecentTransactions(
    userId: string,
    limit: number = 10,
  ): Promise<(Payment | Withdrawal)[]> {
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

    const allTransactions: (Payment | Withdrawal)[] = [
      ...payments,
      ...withdrawals,
    ];
    allTransactions.sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime(),
    );

    return allTransactions.slice(0, limit);
  }

  async getMonthlyEarnings(userId: string): Promise<{ month: string; earnings: number }[]> {
    const payments = await this.prisma.payment.findMany({
      where: { masterId: userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true },
    });

    // Group by month and sum earnings
    const monthlyEarnings: Record<string, number> = {};
    payments.forEach((payment) => {
      const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
      monthlyEarnings[month] = (monthlyEarnings[month] || 0) + payment.amount;
    });

    return Object.entries(monthlyEarnings).map(([month, earnings]) => ({
      month,
      earnings,
    }));
  }

  async getPaymentStats(userId: string): Promise<PaymentStats> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const completedPayments = payments.filter((p) => p.status === WithdrawalStatus.COMPLETED);
    const pendingPayments = payments.filter(
      (p) => p.status === WithdrawalStatus.PENDING || p.status === WithdrawalStatus.PROCESSING,
    );
    const failedPayments = payments.filter(
      (p) =>
        p.status === WithdrawalStatus.FAILED ||
        p.status === WithdrawalStatus.CANCELLED ||
        p.status === WithdrawalStatus.REJECTED,
    );

    const totalAmount = completedPayments.reduce(
      (sum, payment) => sum + payment.amount,
      0,
    );
    const totalTransactions = payments.length;

    return {
      totalAmount,
      totalTransactions,
      completedTransactions: completedPayments.length,
      pendingTransactions: pendingPayments.length,
      failedTransactions: failedPayments.length,
      successRate:
        totalTransactions > 0
          ? (completedPayments.length / totalTransactions) * 100
          : 0,
    };
  }

  async getPaymentOverview(userId: string): Promise<PaymentOverview> {
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

  async getPaymentTrends(userId: string): Promise<MonthlyTrend[]> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true },
    });

    // Calculate trends over last 3 months
    const now = new Date();
    const trends: MonthlyTrend[] = [];

    for (let i = 2; i >= 0; i--) {
      const month = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const monthKey = `${month.getFullYear()}-${(month.getMonth() + 1).toString().padStart(2, '0')}`;

      const monthPayments = payments.filter((p) => {
        const paymentMonth = `${p.createdAt.getFullYear()}-${(p.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
        return paymentMonth === monthKey;
      });

      const total = monthPayments.reduce(
        (sum, payment) => sum + payment.amount,
        0,
      );

      trends.push({
        month: monthKey,
        total,
        count: monthPayments.length,
      });
    }

    return trends;
  }

  async getPaymentRisk(userId: string): Promise<PaymentRisk> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const failedPayments = payments.filter(
      (p) =>
        p.status === WithdrawalStatus.FAILED ||
        p.status === WithdrawalStatus.CANCELLED ||
        p.status === WithdrawalStatus.REJECTED,
    );
    const reportedPayments = payments.filter((p) => p.status === WithdrawalStatus.REPORTED);

    const riskScore = Math.min(
      100,
      failedPayments.length * 10 + reportedPayments.length * 20,
    );

    return {
      riskScore,
      failedPayments: failedPayments.length,
      reportedPayments: reportedPayments.length,
      totalPayments: payments.length,
      riskLevel: riskScore < 30 ? 'low' : riskScore < 70 ? 'medium' : 'high',
    };
  }

  async getPaymentCompliance(userId: string): Promise<PaymentCompliance> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    const payments = await this.prisma.payment.findMany({ where: { userId } });

    return {
      kycStatus: wallet?.kycStatus || WithdrawalStatus.PENDING,
      verifiedPayments: payments.filter((p) => p.verifiedAt).length,
      totalPayments: payments.length,
      complianceRate:
        payments.length > 0
          ? (payments.filter((p) => p.verifiedAt).length / payments.length) *
            100
          : 0,
    };
  }

  async getPaymentSecurity(userId: string): Promise<PaymentSecurity> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });

    return {
      walletVerified: !!wallet?.verifiedAt,
      walletSuspended: !!wallet?.suspendedAt,
      kycCompleted: wallet?.kycStatus === 'approved',
      twoFactorAuth: false, // Placeholder for future implementation
      securityScore:
        wallet?.verifiedAt && wallet.kycStatus === 'approved'
          ? 90
          : wallet?.verifiedAt
            ? 60
            : 30,
    };
  }

  async getPaymentPerformance(userId: string): Promise<PaymentPerformance> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const completedPayments = payments.filter((p) => p.status === WithdrawalStatus.COMPLETED);

    // Calculate average processing time for completed payments
    let totalProcessingTime = 0;
    let completedWithTimeline = 0;

    completedPayments.forEach((payment) => {
      if (payment.processedAt && payment.completedAt) {
        const processingTime =
          payment.completedAt.getTime() - payment.processedAt.getTime();
        totalProcessingTime += processingTime;
        completedWithTimeline++;
      }
    });

    const avgProcessingTime =
      completedWithTimeline > 0
        ? totalProcessingTime / completedWithTimeline
        : 0;

    return {
      avgProcessingTime,
      totalPayments: payments.length,
      completedPayments: completedPayments.length,
      successRate:
        payments.length > 0
          ? (completedPayments.length / payments.length) * 100
          : 0,
      performanceScore:
        payments.length > 0
          ? Math.min(100, (completedPayments.length / payments.length) * 100)
          : 0,
    };
  }

  async getPaymentAlerts(userId: string): Promise<PaymentAlert[]> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });

    const alerts: PaymentAlert[] = [];

    // Low balance alert
    if (wallet && wallet.balance < 100) {
      alerts.push({
        type: 'low_balance',
        message: 'Low wallet balance',
        severity: 'warning',
        timestamp: new Date(),
      });
    }

    // Failed payment alert
    const recentFailedPayments = payments.filter(
      (p) =>
        (p.status === WithdrawalStatus.FAILED ||
          p.status === WithdrawalStatus.CANCELLED ||
          p.status === WithdrawalStatus.REJECTED) &&
        new Date().getTime() - p.updatedAt.getTime() < 7 * 24 * 60 * 60 * 1000, // Last 7 days
    );

    if (recentFailedPayments.length > 0) {
      alerts.push({
        type: 'failed_payments',
        message: `You have ${recentFailedPayments.length} failed payments in the last 7 days`,
        severity: 'warning',
        timestamp: new Date(),
      });
    }

    // Large payment alert
    const largePayments = payments.filter(
      (p) =>
        p.amount > 1000 &&
        new Date().getTime() - p.createdAt.getTime() < 24 * 60 * 60 * 1000, // Last 24 hours
    );

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

  async getPaymentRecommendations(userId: string): Promise<PaymentRecommendation[]> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });

    const recommendations: PaymentRecommendation[] = [];

    // Recommend wallet verification
    if (wallet && !wallet.verifiedAt) {
      recommendations.push({
        type: 'verify_wallet',
        message: 'Verify your wallet to increase security and limits',
        priority: 'high',
      });
    }

    // Recommend KYC completion
    if (wallet && wallet.kycStatus !== 'approved') {
      recommendations.push({
        type: 'complete_kyc',
        message:
          'Complete KYC verification to unlock higher transaction limits',
        priority: 'medium',
      });
    }

    // Payment method recommendation
    const paymentMethods = payments.reduce(
      (acc, payment) => {
        acc[payment.paymentMethod] = (acc[payment.paymentMethod] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    const preferredMethod = Object.entries(paymentMethods).sort(
      (a, b) => b[1] - a[1],
    )[0];
    if (preferredMethod && preferredMethod[1] > 5) {
      recommendations.push({
        type: 'payment_method',
        message: `You frequently use ${preferredMethod[0]} payments. Consider setting it as default.`,
        priority: 'low',
      });
    }

    return recommendations;
  }

  async getPaymentInsights(userId: string): Promise<PaymentInsights> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });

    // Payment pattern analysis
    const paymentDays = payments.map((p) => p.createdAt.getDay());
    const dayFrequency = paymentDays.reduce(
      (acc, day) => {
        acc[day] = (acc[day] || 0) + 1;
        return acc;
      },
      {} as Record<number, number>,
    );

    const mostActiveDay = Object.entries(dayFrequency).sort(
      (a, b) => b[1] - a[1],
    )[0];
    const dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    // Amount distribution
    const amounts = payments.map((p) => p.amount);
    const avgAmount =
      amounts.length > 0
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
            balanceUtilization:
              wallet.totalEarnings > 0
                ? (wallet.balance / wallet.totalEarnings) * 100
                : 0,
          }
        : null,
    };
  }

  async getPaymentPredictions(userId: string): Promise<PaymentForecast> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true },
    });

    // Simple prediction based on historical data
    const monthlyData = await this.getMonthlyEarnings(userId);
    const avgMonthlyEarnings =
      monthlyData.length > 0
        ? monthlyData.reduce((sum, month) => sum + month.earnings, 0) /
          monthlyData.length
        : 0;

    // Predict next 3 months
    const predictions: PaymentPrediction[] = [];
    const now = new Date();

    for (let i = 1; i <= 3; i++) {
      const futureMonth = new Date(now.getFullYear(), now.getMonth() + i, 1);
      const monthKey = `${futureMonth.getFullYear()}-${(futureMonth.getMonth() + 1).toString().padStart(2, '0')}`;

      predictions.push({
        month: monthKey,
        predictedEarnings: Math.round(avgMonthlyEarnings),
        confidence: Math.max(30, 100 - i * 20), // Decreasing confidence
      });
    }

    return {
      monthlyPredictions: predictions,
      trend: avgMonthlyEarnings > 0 ? 'stable' : 'declining',
    };
  }

  async getPaymentForecast(userId: string): Promise<PaymentForecast> {
    return this.getPaymentPredictions(userId);
  }

  async getPaymentBudget(userId: string): Promise<PaymentBudget> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true },
    });

    // Calculate monthly average spending
    const monthlyData = await this.getMonthlyEarnings(userId);
    const avgMonthlySpending =
      monthlyData.length > 0
        ? monthlyData.reduce((sum, month) => sum + month.earnings, 0) /
          monthlyData.length
        : 0;

    return {
      monthlyBudget: avgMonthlySpending * 1.2, // 20% buffer
      currentSpending: avgMonthlySpending,
      remainingBudget: Math.max(
        0,
        avgMonthlySpending * 1.2 - avgMonthlySpending,
      ),
      walletBalance: wallet ? wallet.balance : 0,
    };
  }

  async getPaymentGoals(userId: string): Promise<PaymentGoal[]> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true, masterId: true },
    });

    const goals: PaymentGoal[] = [];

    // Savings goal
    const totalEarnings = wallet ? wallet.totalEarnings : 0;
    const savingsTarget = totalEarnings * 0.2; // 20% savings target
    const currentSavings = wallet ? wallet.balance : 0;
    const savingsProgress =
      savingsTarget > 0 ? (currentSavings / savingsTarget) * 100 : 0;

    goals.push({
      id: 'savings',
      name: 'Savings Goal',
      target: savingsTarget,
      current: currentSavings,
      progress: Math.min(100, savingsProgress),
      status: savingsProgress >= 100 ? WithdrawalStatus.COMPLETED : 'in_progress',
    });

    // Transaction volume goal
    const transactionGoal = 50;
    const currentTransactions = payments.length;
    const transactionProgress = (currentTransactions / transactionGoal) * 100;

    goals.push({
      id: 'transactions',
      name: 'Transaction Volume Goal',
      target: transactionGoal,
      current: currentTransactions,
      progress: Math.min(100, transactionProgress),
      status: transactionProgress >= 100 ? WithdrawalStatus.COMPLETED : 'in_progress',
    });

    return goals;
  }

  async getPaymentHabits(userId: string): Promise<PaymentHabits> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });

    // Time-based habits
    const hourDistribution = payments.reduce(
      (acc, payment) => {
        const hour = payment.createdAt.getHours();
        const timePeriod =
          hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
        acc[timePeriod] = (acc[timePeriod] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    // Method preferences
    const methodPreferences = payments.reduce(
      (acc, payment) => {
        acc[payment.paymentMethod] = (acc[payment.paymentMethod] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    // Frequency analysis
    const paymentDates = payments.map((p) => p.createdAt.toDateString());
    const uniqueDays = [...new Set(paymentDates)];
    const frequency =
      uniqueDays.length > 0 ? payments.length / uniqueDays.length : 0;

    return {
      timePreferences: hourDistribution,
      methodPreferences,
      frequency: `${frequency.toFixed(1)} payments per day`,
      consistency:
        payments.length > 10 ? 'high' : payments.length > 5 ? 'medium' : 'low',
    };
  }

  // Spending analysis method
  async getSpendingAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, paymentMethod: true, clientId: true, masterId: true },
    });
    const outgoingPayments = payments.filter((p) => p.clientId === userId);
    const incomingPayments = payments.filter((p) => p.masterId === userId);

    // Spending by category (simplified)
    const spendingByMethod = outgoingPayments.reduce(
      (acc, payment) => {
        acc[payment.paymentMethod] =
          (acc[payment.paymentMethod] || 0) + payment.amount;
        return acc;
      },
      {} as Record<string, number>,
    );

    // Income by source
    const incomeByMethod = incomingPayments.reduce(
      (acc, payment) => {
        acc[payment.paymentMethod] =
          (acc[payment.paymentMethod] || 0) + payment.amount;
        return acc;
      },
      {} as Record<string, number>,
    );

    return {
      totalSpent: outgoingPayments.reduce((sum, p) => sum + p.amount, 0),
      totalIncome: incomingPayments.reduce((sum, p) => sum + p.amount, 0),
      spendingByMethod,
      incomeByMethod,
      netBalance:
        incomingPayments.reduce((sum, p) => sum + p.amount, 0) -
        outgoingPayments.reduce((sum, p) => sum + p.amount, 0),
      transactionCount: {
        outgoing: outgoingPayments.length,
        incoming: incomingPayments.length,
      },
    };
  }

  // Income analysis method
  async getIncomeAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { masterId: userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, projectId: true },
    });

    // Group by project
    const incomeByProject = payments.reduce(
      (acc, payment) => {
        const projectId = payment.projectId;
        acc[projectId] = (acc[projectId] || 0) + payment.amount;
        return acc;
      },
      {} as Record<number, number>,
    );

    // Group by time period
    const monthlyIncome = await this.getMonthlyEarnings(userId);

    return {
      totalIncome: payments.reduce((sum, p) => sum + p.amount, 0),
      incomeByProject,
      monthlyIncome,
      averageIncomePerTransaction:
        payments.length > 0
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

  // Additional analytics methods that might be referenced
  async getNetWorthAnalysis(userId: string): Promise<any> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) return { netWorth: 0, assets: 0, liabilities: 0 };

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

  async getCashFlowAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true, clientId: true, masterId: true },
    });
    const outgoing = payments.filter((p) => p.clientId === userId);
    const incoming = payments.filter((p) => p.masterId === userId);

    const monthlyCashFlow: Record<
      string,
      { income: number; expenses: number; net: number }
    > = {};

    // Process outgoing payments
    outgoing.forEach((payment) => {
      const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
      if (!monthlyCashFlow[month]) {
        monthlyCashFlow[month] = { income: 0, expenses: 0, net: 0 };
      }
      monthlyCashFlow[month].expenses += payment.amount;
    });

    // Process incoming payments
    incoming.forEach((payment) => {
      const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
      if (!monthlyCashFlow[month]) {
        monthlyCashFlow[month] = { income: 0, expenses: 0, net: 0 };
      }
      monthlyCashFlow[month].income += payment.amount;
    });

    // Calculate net for each month
    Object.keys(monthlyCashFlow).forEach((month) => {
      monthlyCashFlow[month].net =
        monthlyCashFlow[month].income - monthlyCashFlow[month].expenses;
    });

    return {
      totalIncome: incoming.reduce((sum, p) => sum + p.amount, 0),
      totalExpenses: outgoing.reduce((sum, p) => sum + p.amount, 0),
      netCashFlow:
        incoming.reduce((sum, p) => sum + p.amount, 0) -
        outgoing.reduce((sum, p) => sum + p.amount, 0),
      monthlyCashFlow,
    };
  }

  async getDebtAnalysis(userId: string): Promise<any> {
    // Placeholder for debt analysis - would integrate with loan/credit systems
    return {
      totalDebt: 0,
      debtToIncomeRatio: 0,
      monthlyDebtPayments: 0,
      debtCategories: {},
      creditScore: 0,
      debtTrend: 'stable',
    };
  }

  async getInvestmentAnalysis(userId: string): Promise<any> {
    // Placeholder for investment analysis - would integrate with investment systems
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

  // Additional important analytics methods for surface and medium level analysis
  async getRetirementAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, clientId: true, masterId: true },
    });
    const totalEarnings = payments
      .filter((p) => p.masterId === userId)
      .reduce((sum, p) => sum + p.amount, 0);
    const totalSpending = payments
      .filter((p) => p.clientId === userId)
      .reduce((sum, p) => sum + p.amount, 0);

    // Simple retirement savings calculation (20% of earnings saved)
    const retirementSavings = totalEarnings * 0.2;
    const yearsToRetirement = 30; // Assumed 30 years until retirement
    const projectedRetirementFund =
      retirementSavings * yearsToRetirement * 1.05; // 5% annual growth

    return {
      currentRetirementSavings: retirementSavings,
      projectedRetirementFund,
      yearsToRetirement,
      monthlyRetirementContributions:
        retirementSavings / (yearsToRetirement * 12),
      retirementReadinessScore: Math.min(
        100,
        (retirementSavings / (totalEarnings * 0.3)) * 100,
      ), // Simple score
    };
  }

  async getInsuranceAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, description: true },
    });
    const insurancePayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('insurance') ||
        p.description.toLowerCase().includes('asigurare'),
    );

    const totalInsuranceSpent = insurancePayments.reduce(
      (sum, p) => sum + p.amount,
      0,
    );
    const monthlyAverage = totalInsuranceSpent / 12; // Assuming 12 months of data

    return {
      totalInsuranceSpent,
      monthlyAverage,
      insurancePayments: insurancePayments.length,
      insuranceTypes: this.categorizeInsurancePayments(insurancePayments),
      coverageRatio:
        payments.length > 0
          ? (insurancePayments.length / payments.length) * 100
          : 0,
    };
  }

  private categorizeInsurancePayments(
    payments: Array<{ description: string; amount: number }>,
  ): Record<string, number> {
    const categories: Record<string, number> = {
      health: 0,
      life: 0,
      property: 0,
      auto: 0,
      other: 0,
    };

    payments.forEach((payment) => {
      const desc = payment.description.toLowerCase();
      if (
        desc.includes('health') ||
        desc.includes('medical') ||
        desc.includes('sanatate')
      ) {
        categories.health += payment.amount;
      } else if (desc.includes('life') || desc.includes('viata')) {
        categories.life += payment.amount;
      } else if (
        desc.includes('property') ||
        desc.includes('home') ||
        desc.includes('casa') ||
        desc.includes('proprietate')
      ) {
        categories.property += payment.amount;
      } else if (
        desc.includes('auto') ||
        desc.includes('car') ||
        desc.includes('masina')
      ) {
        categories.auto += payment.amount;
      } else {
        categories.other += payment.amount;
      }
    });

    return categories;
  }

    async getTaxAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, clientId: true, masterId: true },
    });
    const incomePayments = payments.filter((p) => p.masterId === userId);
    const expensePayments = payments.filter((p) => p.clientId === userId);

    const totalIncome = incomePayments.reduce((sum, p) => sum + p.amount, 0);
    const totalExpenses = expensePayments.reduce((sum, p) => sum + p.amount, 0);

    // Simple tax calculation (25% tax rate assumption)
    const taxableIncome = totalIncome - totalExpenses;
    const estimatedTax = Math.max(0, taxableIncome * 0.25);

    return {
      totalIncome,
      totalExpenses,
      taxableIncome,
      estimatedTax,
      taxRate: 25,
      taxToIncomeRatio:
        totalIncome > 0 ? (estimatedTax / totalIncome) * 100 : 0,
      deductions: totalExpenses,
    };
  }

  async getCreditAnalysis(userId: string): Promise<any> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    const payments = await this.prisma.payment.findMany({ where: { userId } });

    // Simple credit score based on payment history and wallet health
    const successfulPayments = payments.filter(
      (p) => p.status === WithdrawalStatus.COMPLETED,
    ).length;
    const failedPayments = payments.filter(
      (p) =>
        p.status === WithdrawalStatus.FAILED ||
        p.status === WithdrawalStatus.CANCELLED ||
        p.status === WithdrawalStatus.REJECTED,
    ).length;
    const totalPayments = payments.length;

    const paymentSuccessRate =
      totalPayments > 0 ? (successfulPayments / totalPayments) * 100 : 0;
    const walletHealthScore = wallet
      ? (wallet.balance > 0 ? 80 : 40) +
        (wallet.kycStatus === 'approved' ? 20 : 0)
      : 0;

    const creditScore = Math.min(
      850,
      Math.max(300, paymentSuccessRate * 0.6 + walletHealthScore * 0.4),
    );

    return {
      creditScore: Math.round(creditScore),
      paymentSuccessRate,
      totalPayments,
      successfulPayments,
      failedPayments,
      walletHealthScore,
      creditRating:
        creditScore >= 750
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

  async getFraudAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const reportedPayments = payments.filter((p) => p.status === WithdrawalStatus.REPORTED);
    const rejectedPayments = payments.filter((p) => p.status === WithdrawalStatus.REJECTED);
    const flaggedPayments = payments.filter((p) => p.flaggedAsInappropriate);

    const fraudRiskScore = Math.min(
      100,
      reportedPayments.length * 20 +
        rejectedPayments.length * 10 +
        flaggedPayments.length * 15,
    );

    return {
      fraudRiskScore,
      reportedPayments: reportedPayments.length,
      rejectedPayments: rejectedPayments.length,
      flaggedPayments: flaggedPayments.length,
      fraudRiskLevel:
        fraudRiskScore < 30 ? 'low' : fraudRiskScore < 70 ? 'medium' : 'high',
      suspiciousActivities: this.identifySuspiciousActivities(payments),
      securityRecommendations: await this.getFraudSecurityRecommendations(userId),
    };
  }

  private identifySuspiciousActivities(payments: Payment[]): SuspiciousActivity[] {
    const suspicious: SuspiciousActivity[] = [];

    // Large transactions
    const largeTransactions = payments.filter((p) => p.amount > 10000);
    if (largeTransactions.length > 0) {
      suspicious.push({
        type: 'large_transactions',
        count: largeTransactions.length,
        description: 'Large transactions detected',
      });
    }

    // Failed transactions
    const failedTransactions = payments.filter((p) => p.status === WithdrawalStatus.FAILED);
    if (failedTransactions.length > 5) {
      suspicious.push({
        type: 'high_failure_rate',
        count: failedTransactions.length,
        description: 'High number of failed transactions',
      });
    }

    return suspicious;
  }

  private async getFraudSecurityRecommendations(userId: string): Promise<SecurityRecommendation[]> {
    const recommendations: SecurityRecommendation[] = [];
    const payments = await this.prisma.payment.findMany({ where: { userId } });

    // Check for diverse payment methods
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

  async getFeeAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true },
    });

    // Simple fee calculation (2.9% + 30 cents per transaction)
    const feeRate = 0.029;
    const fixedFee = 0.3;

    const totalAmount = payments.reduce((sum, p) => sum + p.amount, 0);
    const totalFees = payments.reduce(
      (sum, p) => sum + (p.amount * feeRate + fixedFee),
      0,
    );
    const averageFeePerTransaction =
      payments.length > 0 ? totalFees / payments.length : 0;

    return {
      totalFeesPaid: parseFloat(totalFees.toFixed(2)),
      totalTransactionAmount: totalAmount,
      feeToTransactionRatio:
        totalAmount > 0 ? (totalFees / totalAmount) * 100 : 0,
      averageFeePerTransaction: parseFloat(averageFeePerTransaction.toFixed(2)),
      feeBreakdown: {
        percentageFees: parseFloat((totalAmount * feeRate).toFixed(2)),
        fixedFees: parseFloat((payments.length * fixedFee).toFixed(2)),
      },
      feeOptimizationScore: 0, // this.calculateFeeOptimizationScore(payments),
    };
  }

  private calculateFeeOptimizationScore(payments: Array<{ amount: number }>): number {
    if (payments.length === 0) return 50;

    // Score based on transaction size efficiency
    const avgTransactionSize =
      payments.reduce((sum, p) => sum + p.amount, 0) / payments.length;
    const efficiencyScore = Math.min(100, avgTransactionSize / 100); // Higher average = better fee efficiency

    return Math.round(efficiencyScore);
  }

  async getExchangeAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { currency: true },
    });
    const multiCurrencyPayments = payments.filter((p) => p.currency !== 'RON');

    const currencies = [...new Set(payments.map((p) => p.currency))];
    const exchangeTransactions = multiCurrencyPayments.length;

    return {
      currenciesUsed: currencies,
      exchangeTransactions,
      multiCurrencyUsage:
        payments.length > 0
          ? (exchangeTransactions / payments.length) * 100
          : 0,
      currencyPreferences: {}, // this.analyzeCurrencyPreferences(payments),
      exchangeComplexityScore: Math.min(100, currencies.length * 20),
    };
  }

  private analyzeCurrencyPreferences(
    payments: Array<{ currency: string; amount?: number }>,
  ): Record<string, number> {
    const preferences: Record<string, number> = {};

    payments.forEach((payment) => {
      preferences[payment.currency] =
        (preferences[payment.currency] || 0) + (payment.amount || 0);
    });

    return preferences;
  }

  async getInternationalAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, currency: true, description: true },
    });
    // For now, assume international payments are those with different currencies or specific descriptions
    const internationalPayments = payments.filter(
      (p) =>
        p.currency !== 'RON' ||
        p.description.toLowerCase().includes('international') ||
        p.description.toLowerCase().includes('international'),
    );

    const totalInternationalVolume = internationalPayments.reduce(
      (sum, p) => sum + p.amount,
      0,
    );

    return {
      internationalTransactions: internationalPayments.length,
      totalInternationalVolume,
      internationalToTotalRatio:
        payments.length > 0
          ? (internationalPayments.length / payments.length) * 100
          : 0,
      internationalVolumeRatio:
        payments.reduce((sum, p) => sum + p.amount, 0) > 0
          ? (totalInternationalVolume /
              payments.reduce((sum, p) => sum + p.amount, 0)) *
            100
          : 0,
      crossBorderScore: internationalPayments.length > 0 ? 80 : 40,
    };
  }

    async getCryptoAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, description: true },
    });
    const cryptoPayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('crypto') ||
        p.description.toLowerCase().includes('bitcoin') ||
        p.description.toLowerCase().includes('ethereum'),
    );

    const totalCryptoVolume = cryptoPayments.reduce(
      (sum, p) => sum + p.amount,
      0,
    );

    return {
      cryptoTransactions: cryptoPayments.length,
      totalCryptoVolume,
      cryptoAdoptionRate:
        payments.length > 0
          ? (cryptoPayments.length / payments.length) * 100
          : 0,
      cryptoToTotalRatio:
        payments.reduce((sum, p) => sum + p.amount, 0) > 0
          ? (totalCryptoVolume /
              payments.reduce((sum, p) => sum + p.amount, 0)) *
            100
          : 0,
      cryptoTrend: cryptoPayments.length > 0 ? 'adopting' : 'not_using',
    };
  }

  async getWeb3Analysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { description: true },
    });
    const web3Payments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('web3') ||
        p.description.toLowerCase().includes('nft') ||
        p.description.toLowerCase().includes('defi') ||
        p.description.toLowerCase().includes('dao'),
    );

    return {
      web3Transactions: web3Payments.length,
      web3AdoptionScore: Math.min(100, web3Payments.length * 10),
      web3Trend: web3Payments.length > 0 ? 'emerging' : 'not_adopted',
      web3Opportunities: this.identifyWeb3Opportunities(userId),
    };
  }

  private identifyWeb3Opportunities(userId: string): Web3Opportunity[] {
    const opportunities: Web3Opportunity[] = [];
    opportunities.push({
      type: 'education',
      message: 'Learn about Web3 payment opportunities',
      priority: 'low',
    });
    return opportunities;
  }

    async getStakingAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, description: true },
    });
    const stakingPayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('staking') ||
        p.description.toLowerCase().includes('yield') ||
        p.description.toLowerCase().includes('interest'),
    );

    const totalStakingRewards = stakingPayments.reduce(
      (sum, p) => sum + p.amount,
      0,
    );
    const stakingReturnRate =
      payments.length > 0
        ? (totalStakingRewards /
            payments.reduce((sum, p) => sum + p.amount, 0)) *
          100
        : 0;

    return {
      stakingTransactions: stakingPayments.length,
      totalStakingRewards,
      stakingReturnRate,
      stakingPerformance:
        stakingReturnRate > 5
          ? 'good'
          : stakingReturnRate > 2
            ? 'moderate'
            : 'low',
      stakingOpportunities: this.identifyStakingOpportunities(),
    };
  }

  private identifyStakingOpportunities(): StakingOpportunity[] {
    const opportunities: StakingOpportunity[] = [];
    opportunities.push({
      type: 'diversification',
      message: 'Consider diversifying staking assets',
      priority: 'medium',
    });
    return opportunities;
  }

  async getTradingAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, description: true },
    });
    const tradingPayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('trade') ||
        p.description.toLowerCase().includes('exchange') ||
        p.description.toLowerCase().includes('buy') ||
        p.description.toLowerCase().includes('sell'),
    );

    const totalTradingVolume = tradingPayments.reduce(
      (sum, p) => sum + p.amount,
      0,
    );

    return {
      tradingTransactions: tradingPayments.length,
      totalTradingVolume,
      tradingFrequency:
        tradingPayments.length > 0
          ? tradingPayments.length / payments.length
          : 0,
      tradingPerformance: totalTradingVolume > 1000 ? 'high' : 'low',
      tradingOpportunities: this.identifyTradingOpportunities(),
    };
  }

  private identifyTradingOpportunities(): TradingOpportunity[] {
    const opportunities: TradingOpportunity[] = [];
    opportunities.push({
      type: 'market_analysis',
      message: 'Analyze market trends to identify trading opportunities',
      priority: 'medium',
    });
    return opportunities;
  }

  async getPortfolioAnalysis(userId: string): Promise<any> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
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
      expenseToNetWorthRatio:
        netWorth > 0 ? (totalExpenses / netWorth) * 100 : 0,
      portfolioHealth: netWorth > 0 ? 'positive' : 'negative',
      diversificationScore: 0, // this.calculateDiversificationScore(payments),
    };
  }

  private calculateDiversificationScore(
    payments: Array<{ clientId: string; projectId: string; amount: number; masterId: string; description?: string }>
  ): number {
    const incomeSources = [
      ...new Set(payments.filter((p) => p.masterId).map((p) => p.projectId)),
    ];
    const expenseCategories = [
      ...new Set(
        payments
          .filter((p) => p.clientId)
          .map((p) => {
            // Simple categorization based on description keywords
            const desc = (p.description || '').toLowerCase();
            if (desc.includes('material') || desc.includes('supply'))
              return 'materials';
            if (desc.includes('service') || desc.includes('serviciu'))
              return 'services';
            return 'other';
          }),
      ),
    ];

    return Math.min(
      100,
      (incomeSources.length + expenseCategories.length) * 10,
    );
  }

  async getRiskAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({ where: { userId } });
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });

    // Comprehensive risk assessment
    const financialRisk = await this.calculateFinancialRisk(payments, wallet);
    const transactionRisk = this.calculateTransactionRisk(payments);
    const marketRisk = this.calculateMarketRisk(payments);

    const overallRiskScore = (financialRisk + transactionRisk + marketRisk) / 3;

    return {
      overallRiskScore: Math.round(overallRiskScore),
      financialRisk,
      transactionRisk,
      marketRisk,
      riskLevel:
        overallRiskScore < 30
          ? 'low'
          : overallRiskScore < 70
            ? 'medium'
            : 'high',
      riskRecommendations: this.getRiskRecommendations(overallRiskScore),
    };
  }

  private async calculateFinancialRisk(
    payments: Payment[],
    wallet: Wallet | null,
  ): Promise<number> {
    if (!wallet) return 80;

    const incomePayments = payments.filter(
      (p) => p.masterId === wallet.userId && p.status === WithdrawalStatus.COMPLETED,
    );
    const expensePayments = payments.filter(
      (p) => p.clientId === wallet.userId && p.status === WithdrawalStatus.COMPLETED,
    );

    const monthlyIncome =
      incomePayments.reduce((sum, p) => sum + p.amount, 0) / 12;
    const monthlyExpenses =
      expensePayments.reduce((sum, p) => sum + p.amount, 0) / 12;

    // Risk based on income vs expenses
    const incomeToExpenseRatio =
      monthlyExpenses > 0 ? monthlyIncome / monthlyExpenses : 10;
    let risk = 50;

    if (incomeToExpenseRatio < 1) {
      risk = 90; // High risk - spending more than earning
    } else if (incomeToExpenseRatio < 2) {
      risk = 70; // Medium risk
    } else if (incomeToExpenseRatio < 5) {
      risk = 40; // Low risk
    } else {
      risk = 20; // Very low risk
    }

    return risk;
  }

  private calculateTransactionRisk(payments: Payment[]): number {
    const failedPayments = payments.filter(
      (p) => p.status === WithdrawalStatus.FAILED || p.status === WithdrawalStatus.CANCELLED,
    ).length;
    const totalPayments = payments.length;

    return totalPayments > 0
      ? Math.min(100, (failedPayments / totalPayments) * 100)
      : 30;
  }

  private calculateMarketRisk(payments: Payment[]): number {
    // Simple market risk based on payment diversity and recency
    const recentPayments = payments.filter((p) => {
      const daysAgo =
        (new Date().getTime() - p.createdAt.getTime()) / (1000 * 60 * 60 * 24);
      return daysAgo < 90; // Last 90 days
    });

    const paymentDiversity = [
      ...new Set(recentPayments.map((p) => p.projectId)),
    ].length;
    return Math.max(20, 100 - paymentDiversity * 5);
  }

  private getRiskRecommendations(riskScore: number): RiskRecommendation[] {
    const recommendations: RiskRecommendation[] = [];

    if (riskScore > 70) {
      recommendations.push({
        type: 'high_risk',
        message: 'Consider diversifying income sources and reducing expenses',
        priority: 'high',
      });
    } else if (riskScore > 40) {
      recommendations.push({
        type: 'medium_risk',
        message: 'Monitor spending patterns and maintain emergency fund',
        priority: 'medium',
      });
    } else {
      recommendations.push({
        type: 'low_risk',
        message: 'Financial position is stable, consider growth opportunities',
        priority: 'low',
      });
    }

    return recommendations;
  }

  async getEsgAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, description: true, verifiedAt: true },
    });
    const esgPayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('sustainable') ||
        p.description.toLowerCase().includes('green') ||
        p.description.toLowerCase().includes('eco') ||
        p.description.toLowerCase().includes('social') ||
        p.description.toLowerCase().includes('community'),
    );

    const esgScore = Math.min(100, esgPayments.length * 15);

    return {
      esgScore,
      sustainableTransactions: esgPayments.length,
      esgAdoptionRate:
        payments.length > 0 ? (esgPayments.length / payments.length) * 100 : 0,
      environmentalScore: 0, // this.calculateEnvironmentalScore(payments),
      socialScore: 0, // this.calculateSocialScore(payments),
      governanceScore: 0, // this.calculateGovernanceScore(payments),
    };
  }

  private calculateEnvironmentalScore(
    payments: Array<{ description: string; amount: number; verifiedAt: Date }>
  ): number {
    const greenPayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('green') ||
        p.description.toLowerCase().includes('eco') ||
        p.description.toLowerCase().includes('sustainable'),
    );
    return Math.min(100, greenPayments.length * 20);
  }

  private calculateSocialScore(
    payments: Array<{ description: string; amount: number; verifiedAt: Date }>
  ): number {
    const socialPayments = payments.filter(
      (p) =>
        p.description.toLowerCase().includes('charity') ||
        p.description.toLowerCase().includes('donation') ||
        p.description.toLowerCase().includes('community') ||
        p.description.toLowerCase().includes('social'),
    );
    return Math.min(100, socialPayments.length * 25);
  }

  private calculateGovernanceScore(
    payments: Array<{ description: string; amount: number; verifiedAt: Date }>
  ): number {
    const verifiedPayments = payments.filter((p) => p.verifiedAt);
    return payments.length > 0
      ? (verifiedPayments.length / payments.length) * 100
      : 50;
  }

  async getMarketAnalysis(userId: string): Promise<any> {
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true, createdAt: true, projectId: true },
    });
    const monthlyData = await this.getMonthlyEarnings(userId);

    // Simple market trend analysis
    const recentMonths = monthlyData.slice(-3); // Last 3 months
    const trend = this.calculateTrend(recentMonths.map((m) => m.earnings));

    return {
      marketTrend: trend,
      volatilityScore: this.calculateVolatility(
        recentMonths.map((m) => m.earnings),
      ),
      marketPosition: await this.calculateMarketPosition(userId),
      growthOpportunities: [], // this.identifyGrowthOpportunities(payments),
    };
  }

  private calculateTrend(values: number[]): string {
    if (values.length < 2) return 'stable';

    const firstHalf = values.slice(0, Math.floor(values.length / 2));
    const secondHalf = values.slice(Math.floor(values.length / 2));

    const firstAvg = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
    const secondAvg = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;

    const change = ((secondAvg - firstAvg) / firstAvg) * 100;

    if (change > 10) return 'growing';
    if (change < -10) return 'declining';
    return 'stable';
  }

  private calculateVolatility(values: number[]): number {
    if (values.length <= 1) return 50;

    const mean = values.reduce((a, b) => a + b, 0) / values.length;
    const squaredDiffs = values.map((value) => Math.pow(value - mean, 2));
    const avgSquaredDiff =
      squaredDiffs.reduce((a, b) => a + b, 0) / squaredDiffs.length;
    const stdDev = Math.sqrt(avgSquaredDiff);

    // Normalize to 0-100 scale
    return Math.min(100, (stdDev / mean) * 50);
  }

  private async calculateMarketPosition(userId: string): Promise<string> {
    // Simple market position based on transaction volume compared to average
    const payments = await this.prisma.payment.findMany({
      where: { userId, status: WithdrawalStatus.COMPLETED },
      select: { amount: true },
    });
    const userVolume = payments.reduce((sum, p) => sum + p.amount, 0);

    // Calculate average user volume (simplified)
    const avgVolume = 5000; // Placeholder average

    if (userVolume > avgVolume * 1.5) return 'leader';
    if (userVolume > avgVolume) return 'above_average';
    if (userVolume > avgVolume * 0.5) return 'average';
    return 'emerging';
  }

  private identifyGrowthOpportunities(
    payments: Array<{ createdAt: Date; projectId: string; amount: number }>
  ): GrowthOpportunity[] {
    const opportunities: GrowthOpportunity[] = [];
    const monthlyGrowth = 0; // this.calculateMonthlyGrowth(payments);

    if (monthlyGrowth < 10) {
      opportunities.push({
        type: 'volume_growth',
        message: 'Opportunity to increase transaction volume',
        priority: 'medium',
      });
    }

    return opportunities;
  }

  private calculateMonthlyGrowth(
    payments: Array<{ createdAt: Date; amount: number }>
  ): number {
    // const monthlyData = this.groupPaymentsByMonth(payments);
    const monthlyData: MonthlyGrowthData[] = [];
    if (monthlyData.length < 2) return 0;

    const recentMonths = monthlyData.slice(-2);
    const previous = recentMonths[0].total;
    const current = recentMonths[1].total;

    return previous > 0 ? ((current - previous) / previous) * 100 : 0;
  }

  private groupPaymentsByMonth(
    payments: Payment[],
  ): { month: string; total: number }[] {
    const grouped: Record<string, number> = {};

    payments.forEach((payment) => {
      const month = `${payment.createdAt.getFullYear()}-${(payment.createdAt.getMonth() + 1).toString().padStart(2, '0')}`;
      grouped[month] = (grouped[month] || 0) + payment.amount;
    });

    return Object.entries(grouped)
      .map(([month, total]) => ({ month, total }))
      .sort((a, b) => a.month.localeCompare(b.month));
  }
}
