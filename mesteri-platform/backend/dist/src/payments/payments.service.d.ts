import { PrismaService } from '../prisma/prisma.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { UpdatePaymentDto } from './dto/update-payment.dto';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { UpdateWalletDto } from './dto/update-wallet.dto';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { UpdateWithdrawalDto } from './dto/update-withdrawal.dto';
import { Payment, Wallet, Withdrawal } from '@prisma/client';
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
export declare class PaymentsService {
    private prisma;
    constructor(prisma: PrismaService);
    findAllPayments(): Promise<Payment[]>;
    findPaymentById(id: string): Promise<Payment | null>;
    findPaymentsByUserId(userId: string): Promise<Payment[]>;
    findPaymentsByProjectId(projectId: string): Promise<Payment[]>;
    findPaymentsByStatus(status: string): Promise<Payment[]>;
    findPaymentsByMethod(method: string): Promise<Payment[]>;
    processPayment(id: string): Promise<Payment | null>;
    completePayment(id: string): Promise<Payment | null>;
    failPayment(id: string, reason: string): Promise<Payment | null>;
    cancelPayment(id: string, reason: string): Promise<Payment | null>;
    verifyPayment(id: string): Promise<Payment | null>;
    rejectPayment(id: string, reason: string): Promise<Payment | null>;
    reportPayment(id: string, reason: string): Promise<Payment | null>;
    refundPayment(id: string, reason: string): Promise<Payment | null>;
    createPayment(paymentData: CreatePaymentDto): Promise<Payment>;
    updatePayment(id: string, updateData: UpdatePaymentDto): Promise<Payment | null>;
    deletePayment(id: string): Promise<Payment>;
    findAllWallets(): Promise<Wallet[]>;
    findWalletById(id: string): Promise<Wallet | null>;
    findWalletByUserId(userId: string): Promise<Wallet | null>;
    createWallet(walletData: CreateWalletDto): Promise<Wallet>;
    updateWallet(id: string, updateData: UpdateWalletDto): Promise<Wallet | null>;
    deleteWallet(id: string): Promise<Wallet>;
    verifyWallet(id: string): Promise<Wallet | null>;
    suspendWallet(id: string, reason: string): Promise<Wallet | null>;
    reactivateWallet(id: string): Promise<Wallet | null>;
    submitKyc(id: string, kycData: any): Promise<Wallet | null>;
    addBankAccount(id: string, bankAccountData: any): Promise<Wallet | null>;
    removeBankAccount(id: string, accountid: string): Promise<Wallet | null>;
    findAllWithdrawals(): Promise<Withdrawal[]>;
    findWithdrawalById(id: string): Promise<Withdrawal | null>;
    findWithdrawalsByUserId(userId: string): Promise<Withdrawal[]>;
    findWithdrawalsByWalletId(walletid: string): Promise<Withdrawal[]>;
    findWithdrawalsByStatus(status: string): Promise<Withdrawal[]>;
    createWithdrawal(withdrawalData: CreateWithdrawalDto): Promise<Withdrawal>;
    processWithdrawal(id: string): Promise<Withdrawal | null>;
    completeWithdrawal(id: string): Promise<Withdrawal | null>;
    updateWithdrawal(id: string, updateData: UpdateWithdrawalDto): Promise<Withdrawal | null>;
    deleteWithdrawal(id: string): Promise<Withdrawal>;
    failWithdrawal(id: string, reason: string): Promise<Withdrawal | null>;
    verifyWithdrawal(id: string): Promise<Withdrawal | null>;
    rejectWithdrawal(id: string, reason: string): Promise<Withdrawal | null>;
    reportWithdrawal(id: string, reason: string): Promise<Withdrawal | null>;
    cancelWithdrawal(id: string, reason: string): Promise<Withdrawal | null>;
    getUserBalance(userId: string): Promise<number>;
    getUserPendingBalance(userId: string): Promise<number>;
    getTotalEarnings(userId: string): Promise<number>;
    getTotalWithdrawn(userId: string): Promise<number>;
    getPaymentHistory(userId: string, limit?: number): Promise<Payment[]>;
    getRecentTransactions(userId: string, limit?: number): Promise<(Payment | Withdrawal)[]>;
    getMonthlyEarnings(userId: string): Promise<{
        month: string;
        earnings: number;
    }[]>;
    getPaymentStats(userId: string): Promise<PaymentStats>;
    getPaymentOverview(userId: string): Promise<PaymentOverview>;
    getPaymentTrends(userId: string): Promise<MonthlyTrend[]>;
    getPaymentRisk(userId: string): Promise<PaymentRisk>;
    getPaymentCompliance(userId: string): Promise<PaymentCompliance>;
    getPaymentSecurity(userId: string): Promise<PaymentSecurity>;
    getPaymentPerformance(userId: string): Promise<PaymentPerformance>;
    getPaymentAlerts(userId: string): Promise<PaymentAlert[]>;
    getPaymentRecommendations(userId: string): Promise<PaymentRecommendation[]>;
    getPaymentInsights(userId: string): Promise<PaymentInsights>;
    getPaymentPredictions(userId: string): Promise<PaymentForecast>;
    getPaymentForecast(userId: string): Promise<PaymentForecast>;
    getPaymentBudget(userId: string): Promise<PaymentBudget>;
    getPaymentGoals(userId: string): Promise<PaymentGoal[]>;
    getPaymentHabits(userId: string): Promise<PaymentHabits>;
    getSpendingAnalysis(userId: string): Promise<any>;
    getIncomeAnalysis(userId: string): Promise<any>;
    getNetWorthAnalysis(userId: string): Promise<any>;
    getCashFlowAnalysis(userId: string): Promise<any>;
    getDebtAnalysis(userId: string): Promise<any>;
    getInvestmentAnalysis(userId: string): Promise<any>;
    getRetirementAnalysis(userId: string): Promise<any>;
    getInsuranceAnalysis(userId: string): Promise<any>;
    private categorizeInsurancePayments;
    getTaxAnalysis(userId: string): Promise<any>;
    getCreditAnalysis(userId: string): Promise<any>;
    getFraudAnalysis(userId: string): Promise<any>;
    private identifySuspiciousActivities;
    private getFraudSecurityRecommendations;
    getFeeAnalysis(userId: string): Promise<any>;
    private calculateFeeOptimizationScore;
    getExchangeAnalysis(userId: string): Promise<any>;
    private analyzeCurrencyPreferences;
    getInternationalAnalysis(userId: string): Promise<any>;
    getCryptoAnalysis(userId: string): Promise<any>;
    getWeb3Analysis(userId: string): Promise<any>;
    private identifyWeb3Opportunities;
    getStakingAnalysis(userId: string): Promise<any>;
    private identifyStakingOpportunities;
    getTradingAnalysis(userId: string): Promise<any>;
    private identifyTradingOpportunities;
    getPortfolioAnalysis(userId: string): Promise<any>;
    private calculateDiversificationScore;
    getRiskAnalysis(userId: string): Promise<any>;
    private calculateFinancialRisk;
    private calculateTransactionRisk;
    private calculateMarketRisk;
    private getRiskRecommendations;
    getEsgAnalysis(userId: string): Promise<any>;
    private calculateEnvironmentalScore;
    private calculateSocialScore;
    private calculateGovernanceScore;
    getMarketAnalysis(userId: string): Promise<any>;
    private calculateTrend;
    private calculateVolatility;
    private calculateMarketPosition;
    private identifyGrowthOpportunities;
    private calculateMonthlyGrowth;
    private groupPaymentsByMonth;
}
