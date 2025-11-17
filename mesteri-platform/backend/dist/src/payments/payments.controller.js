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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentsController = void 0;
const common_1 = require("@nestjs/common");
const payments_service_1 = require("./payments.service");
const stripe_service_1 = require("./stripe.service");
const create_payment_dto_1 = require("./dto/create-payment.dto");
const update_payment_dto_1 = require("./dto/update-payment.dto");
const create_wallet_dto_1 = require("./dto/create-wallet.dto");
const update_wallet_dto_1 = require("./dto/update-wallet.dto");
const create_withdrawal_dto_1 = require("./dto/create-withdrawal.dto");
const update_withdrawal_dto_1 = require("./dto/update-withdrawal.dto");
let PaymentsController = class PaymentsController {
    paymentsService;
    stripeService;
    constructor(paymentsService, stripeService) {
        this.paymentsService = paymentsService;
        this.stripeService = stripeService;
    }
    findAll() {
        return this.paymentsService.findAllPayments();
    }
    findOne(id) {
        return this.paymentsService.findPaymentById(id);
    }
    findByUserId(userId) {
        return this.paymentsService.findPaymentsByUserId(userId);
    }
    findByProjectId(projectId) {
        return this.paymentsService.findPaymentsByProjectId(projectId);
    }
    findByStatus(status) {
        return this.paymentsService.findPaymentsByStatus(status);
    }
    findByMethod(method) {
        return this.paymentsService.findPaymentsByMethod(method);
    }
    create(paymentData) {
        return this.paymentsService.createPayment(paymentData);
    }
    update(id, updateData) {
        return this.paymentsService.updatePayment(id, updateData);
    }
    delete(id) {
        return this.paymentsService.deletePayment(id);
    }
    processPayment(id) {
        return this.paymentsService.processPayment(id);
    }
    completePayment(id) {
        return this.paymentsService.completePayment(id);
    }
    failPayment(id, reason) {
        return this.paymentsService.failPayment(id, reason);
    }
    refundPayment(id, reason) {
        return this.paymentsService.refundPayment(id, reason);
    }
    cancelPayment(id, reason) {
        return this.paymentsService.cancelPayment(id, reason);
    }
    verifyPayment(id) {
        return this.paymentsService.verifyPayment(id);
    }
    rejectPayment(id, reason) {
        return this.paymentsService.rejectPayment(id, reason);
    }
    reportPayment(id, reason) {
        return this.paymentsService.reportPayment(id, reason);
    }
    findAllWallets() {
        return this.paymentsService.findAllWallets();
    }
    findWalletById(id) {
        return this.paymentsService.findWalletById(id);
    }
    findWalletByUserId(userId) {
        return this.paymentsService.findWalletByUserId(userId);
    }
    createWallet(walletData) {
        return this.paymentsService.createWallet(walletData);
    }
    updateWallet(id, updateData) {
        return this.paymentsService.updateWallet(id, updateData);
    }
    deleteWallet(id) {
        return this.paymentsService.deleteWallet(id);
    }
    verifyWallet(id) {
        return this.paymentsService.verifyWallet(id);
    }
    suspendWallet(id, reason) {
        return this.paymentsService.suspendWallet(id, reason);
    }
    reactivateWallet(id) {
        return this.paymentsService.reactivateWallet(id);
    }
    submitKyc(id, kycData) {
        return this.paymentsService.submitKyc(id, kycData);
    }
    addBankAccount(id, bankAccountData) {
        return this.paymentsService.addBankAccount(id, bankAccountData);
    }
    removeBankAccount(id, accountId) {
        return this.paymentsService.removeBankAccount(id, accountId);
    }
    findAllWithdrawals() {
        return this.paymentsService.findAllWithdrawals();
    }
    findWithdrawalById(id) {
        return this.paymentsService.findWithdrawalById(id);
    }
    findWithdrawalsByUserId(userId) {
        return this.paymentsService.findWithdrawalsByUserId(userId);
    }
    findWithdrawalsByWalletId(walletId) {
        return this.paymentsService.findWithdrawalsByWalletId(walletId);
    }
    findWithdrawalsByStatus(status) {
        return this.paymentsService.findWithdrawalsByStatus(status);
    }
    createWithdrawal(withdrawalData) {
        return this.paymentsService.createWithdrawal(withdrawalData);
    }
    updateWithdrawal(id, updateData) {
        return this.paymentsService.updateWithdrawal(id, updateData);
    }
    deleteWithdrawal(id) {
        return this.paymentsService.deleteWithdrawal(id);
    }
    processWithdrawal(id) {
        return this.paymentsService.processWithdrawal(id);
    }
    completeWithdrawal(id) {
        return this.paymentsService.completeWithdrawal(id);
    }
    failWithdrawal(id, reason) {
        return this.paymentsService.failWithdrawal(id, reason);
    }
    cancelWithdrawal(id, reason) {
        return this.paymentsService.cancelWithdrawal(id, reason);
    }
    verifyWithdrawal(id) {
        return this.paymentsService.verifyWithdrawal(id);
    }
    rejectWithdrawal(id, reason) {
        return this.paymentsService.rejectWithdrawal(id, reason);
    }
    reportWithdrawal(id, reason) {
        return this.paymentsService.reportWithdrawal(id, reason);
    }
    getUserBalance(userId) {
        return this.paymentsService.getUserBalance(userId);
    }
    getUserPendingBalance(userId) {
        return this.paymentsService.getUserPendingBalance(userId);
    }
    getTotalEarnings(userId) {
        return this.paymentsService.getTotalEarnings(userId);
    }
    getTotalWithdrawn(userId) {
        return this.paymentsService.getTotalWithdrawn(userId);
    }
    getPaymentHistory(userId, limit) {
        return this.paymentsService.getPaymentHistory(userId, limit ? parseInt(limit) : undefined);
    }
    getRecentTransactions(userId, limit) {
        return this.paymentsService.getRecentTransactions(userId, limit ? parseInt(limit) : 10);
    }
    getMonthlyEarnings(userId) {
        return this.paymentsService.getMonthlyEarnings(userId);
    }
    getPaymentStats(userId) {
        return this.paymentsService.getPaymentStats(userId);
    }
    getPaymentOverview(userId) {
        return this.paymentsService.getPaymentOverview(userId);
    }
    getPaymentTrends(userId) {
        return this.paymentsService.getPaymentTrends(userId);
    }
    getPaymentRisk(userId) {
        return this.paymentsService.getPaymentRisk(userId);
    }
    getPaymentCompliance(userId) {
        return this.paymentsService.getPaymentCompliance(userId);
    }
    getPaymentSecurity(userId) {
        return this.paymentsService.getPaymentSecurity(userId);
    }
    getPaymentPerformance(userId) {
        return this.paymentsService.getPaymentPerformance(userId);
    }
    getPaymentAlerts(userId) {
        return this.paymentsService.getPaymentAlerts(userId);
    }
    getPaymentRecommendations(userId) {
        return this.paymentsService.getPaymentRecommendations(userId);
    }
    getPaymentInsights(userId) {
        return this.paymentsService.getPaymentInsights(userId);
    }
    getPaymentPredictions(userId) {
        return this.paymentsService.getPaymentPredictions(userId);
    }
    getPaymentForecast(userId) {
        return this.paymentsService.getPaymentForecast(userId);
    }
    getPaymentBudget(userId) {
        return this.paymentsService.getPaymentBudget(userId);
    }
    getPaymentGoals(userId) {
        return this.paymentsService.getPaymentGoals(userId);
    }
    getPaymentHabits(userId) {
        return this.paymentsService.getPaymentHabits(userId);
    }
    getSpendingAnalysis(userId) {
        return this.paymentsService.getSpendingAnalysis(userId);
    }
    getIncomeAnalysis(userId) {
        return this.paymentsService.getIncomeAnalysis(userId);
    }
    getNetWorthAnalysis(userId) {
        return this.paymentsService.getNetWorthAnalysis(userId);
    }
    getCashFlowAnalysis(userId) {
        return this.paymentsService.getCashFlowAnalysis(userId);
    }
    getDebtAnalysis(userId) {
        return this.paymentsService.getDebtAnalysis(userId);
    }
    getInvestmentAnalysis(userId) {
        return this.paymentsService.getInvestmentAnalysis(userId);
    }
    getRetirementAnalysis(userId) {
        return this.paymentsService.getRetirementAnalysis(userId);
    }
    getInsuranceAnalysis(userId) {
        return this.paymentsService.getInsuranceAnalysis(userId);
    }
    getTaxAnalysis(userId) {
        return this.paymentsService.getTaxAnalysis(userId);
    }
    getCreditAnalysis(userId) {
        return this.paymentsService.getCreditAnalysis(userId);
    }
    getFraudAnalysis(userId) {
        return this.paymentsService.getFraudAnalysis(userId);
    }
    getFeeAnalysis(userId) {
        return this.paymentsService.getFeeAnalysis(userId);
    }
    getExchangeAnalysis(userId) {
        return this.paymentsService.getExchangeAnalysis(userId);
    }
    getInternationalAnalysis(userId) {
        return this.paymentsService.getInternationalAnalysis(userId);
    }
    getCryptoAnalysis(userId) {
        return this.paymentsService.getCryptoAnalysis(userId);
    }
    getWeb3Analysis(userId) {
        return this.paymentsService.getWeb3Analysis(userId);
    }
    getStakingAnalysis(userId) {
        return this.paymentsService.getStakingAnalysis(userId);
    }
    getTradingAnalysis(userId) {
        return this.paymentsService.getTradingAnalysis(userId);
    }
    getPortfolioAnalysis(userId) {
        return this.paymentsService.getPortfolioAnalysis(userId);
    }
    getRiskAnalysis(userId) {
        return this.paymentsService.getRiskAnalysis(userId);
    }
    getEsgAnalysis(userId) {
        return this.paymentsService.getEsgAnalysis(userId);
    }
    getMarketAnalysis(userId) {
        return this.paymentsService.getMarketAnalysis(userId);
    }
    async createStripePayment(data) {
        return this.stripeService.createPaymentIntent(data.amount, 'ron', {
            projectId: data.projectId,
            clientId: data.clientId,
            craftsmanId: data.craftsmanId,
            milestoneId: data.milestoneId,
        });
    }
    async captureStripePayment(paymentIntentId, paymentId) {
        return this.stripeService.capturePayment(paymentIntentId, paymentId);
    }
    async refundStripePayment(paymentIntentId, paymentId, amount) {
        return this.stripeService.refundPayment(paymentIntentId, paymentId, amount);
    }
    async handleStripeWebhook(signature, request) {
        const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
        try {
            const event = stripe.webhooks.constructEvent(request.rawBody, signature, process.env.STRIPE_WEBHOOK_SECRET);
            await this.stripeService.handleWebhookEvent(event);
            return { received: true };
        }
        catch (err) {
            return { error: err.message };
        }
    }
    calculatePlatformFee(amount) {
        return this.stripeService.calculateFee(amount);
    }
};
exports.PaymentsController = PaymentsController;
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Get)('user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findByUserId", null);
__decorate([
    (0, common_1.Get)('project/:projectId'),
    __param(0, (0, common_1.Param)('projectId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findByProjectId", null);
__decorate([
    (0, common_1.Get)('status/:status'),
    __param(0, (0, common_1.Param)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findByStatus", null);
__decorate([
    (0, common_1.Get)('method/:method'),
    __param(0, (0, common_1.Param)('method')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findByMethod", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_payment_dto_1.CreatePaymentDto]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_payment_dto_1.UpdatePaymentDto]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "delete", null);
__decorate([
    (0, common_1.Post)(':id/process'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "processPayment", null);
__decorate([
    (0, common_1.Post)(':id/complete'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "completePayment", null);
__decorate([
    (0, common_1.Post)(':id/fail'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "failPayment", null);
__decorate([
    (0, common_1.Post)(':id/refund'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "refundPayment", null);
__decorate([
    (0, common_1.Post)(':id/cancel'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "cancelPayment", null);
__decorate([
    (0, common_1.Post)(':id/verify'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "verifyPayment", null);
__decorate([
    (0, common_1.Post)(':id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "rejectPayment", null);
__decorate([
    (0, common_1.Post)(':id/report'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "reportPayment", null);
__decorate([
    (0, common_1.Get)('wallets'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findAllWallets", null);
__decorate([
    (0, common_1.Get)('wallets/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findWalletById", null);
__decorate([
    (0, common_1.Get)('wallets/user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findWalletByUserId", null);
__decorate([
    (0, common_1.Post)('wallets'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_wallet_dto_1.CreateWalletDto]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "createWallet", null);
__decorate([
    (0, common_1.Put)('wallets/:id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_wallet_dto_1.UpdateWalletDto]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "updateWallet", null);
__decorate([
    (0, common_1.Delete)('wallets/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "deleteWallet", null);
__decorate([
    (0, common_1.Post)('wallets/:id/verify'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "verifyWallet", null);
__decorate([
    (0, common_1.Post)('wallets/:id/suspend'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "suspendWallet", null);
__decorate([
    (0, common_1.Post)('wallets/:id/reactivate'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "reactivateWallet", null);
__decorate([
    (0, common_1.Post)('wallets/:id/kyc'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "submitKyc", null);
__decorate([
    (0, common_1.Post)('wallets/:id/bank-account'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "addBankAccount", null);
__decorate([
    (0, common_1.Delete)('wallets/:id/bank-account/:accountId'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('accountId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "removeBankAccount", null);
__decorate([
    (0, common_1.Get)('withdrawals'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findAllWithdrawals", null);
__decorate([
    (0, common_1.Get)('withdrawals/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findWithdrawalById", null);
__decorate([
    (0, common_1.Get)('withdrawals/user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findWithdrawalsByUserId", null);
__decorate([
    (0, common_1.Get)('withdrawals/wallet/:walletId'),
    __param(0, (0, common_1.Param)('walletId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findWithdrawalsByWalletId", null);
__decorate([
    (0, common_1.Get)('withdrawals/status/:status'),
    __param(0, (0, common_1.Param)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "findWithdrawalsByStatus", null);
__decorate([
    (0, common_1.Post)('withdrawals'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_withdrawal_dto_1.CreateWithdrawalDto]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "createWithdrawal", null);
__decorate([
    (0, common_1.Put)('withdrawals/:id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_withdrawal_dto_1.UpdateWithdrawalDto]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "updateWithdrawal", null);
__decorate([
    (0, common_1.Delete)('withdrawals/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "deleteWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/process'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "processWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/complete'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "completeWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/fail'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "failWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/cancel'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "cancelWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/verify'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "verifyWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "rejectWithdrawal", null);
__decorate([
    (0, common_1.Post)('withdrawals/:id/report'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "reportWithdrawal", null);
__decorate([
    (0, common_1.Get)('analytics/balance/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getUserBalance", null);
__decorate([
    (0, common_1.Get)('analytics/pending-balance/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getUserPendingBalance", null);
__decorate([
    (0, common_1.Get)('analytics/earnings/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getTotalEarnings", null);
__decorate([
    (0, common_1.Get)('analytics/withdrawn/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getTotalWithdrawn", null);
__decorate([
    (0, common_1.Get)('analytics/history/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentHistory", null);
__decorate([
    (0, common_1.Get)('analytics/recent/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getRecentTransactions", null);
__decorate([
    (0, common_1.Get)('analytics/monthly/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getMonthlyEarnings", null);
__decorate([
    (0, common_1.Get)('analytics/stats/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentStats", null);
__decorate([
    (0, common_1.Get)('analytics/overview/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentOverview", null);
__decorate([
    (0, common_1.Get)('analytics/trends/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentTrends", null);
__decorate([
    (0, common_1.Get)('analytics/risk/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentRisk", null);
__decorate([
    (0, common_1.Get)('analytics/compliance/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentCompliance", null);
__decorate([
    (0, common_1.Get)('analytics/security/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentSecurity", null);
__decorate([
    (0, common_1.Get)('analytics/performance/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentPerformance", null);
__decorate([
    (0, common_1.Get)('analytics/alerts/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentAlerts", null);
__decorate([
    (0, common_1.Get)('analytics/recommendations/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentRecommendations", null);
__decorate([
    (0, common_1.Get)('analytics/insights/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentInsights", null);
__decorate([
    (0, common_1.Get)('analytics/predictions/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentPredictions", null);
__decorate([
    (0, common_1.Get)('analytics/forecast/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentForecast", null);
__decorate([
    (0, common_1.Get)('analytics/budget/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentBudget", null);
__decorate([
    (0, common_1.Get)('analytics/goals/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentGoals", null);
__decorate([
    (0, common_1.Get)('analytics/habits/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPaymentHabits", null);
__decorate([
    (0, common_1.Get)('analytics/spending/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getSpendingAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/income/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getIncomeAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/net-worth/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getNetWorthAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/cash-flow/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getCashFlowAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/debt/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getDebtAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/investment/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getInvestmentAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/retirement/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getRetirementAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/insurance/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getInsuranceAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/tax/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getTaxAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/credit/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getCreditAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/fraud/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getFraudAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/fees/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getFeeAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/exchange/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getExchangeAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/international/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getInternationalAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/crypto/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getCryptoAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/web3/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getWeb3Analysis", null);
__decorate([
    (0, common_1.Get)('analytics/staking/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getStakingAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/trading/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getTradingAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/portfolio/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getPortfolioAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/risk/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getRiskAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/esg/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getEsgAnalysis", null);
__decorate([
    (0, common_1.Get)('analytics/market/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "getMarketAnalysis", null);
__decorate([
    (0, common_1.Post)('stripe/create-payment-intent'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "createStripePayment", null);
__decorate([
    (0, common_1.Post)('stripe/capture/:paymentIntentId'),
    __param(0, (0, common_1.Param)('paymentIntentId')),
    __param(1, (0, common_1.Body)('paymentId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "captureStripePayment", null);
__decorate([
    (0, common_1.Post)('stripe/refund/:paymentIntentId'),
    __param(0, (0, common_1.Param)('paymentIntentId')),
    __param(1, (0, common_1.Body)('paymentId')),
    __param(2, (0, common_1.Body)('amount')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Number]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "refundStripePayment", null);
__decorate([
    (0, common_1.Post)('stripe/webhook'),
    __param(0, (0, common_1.Headers)('stripe-signature')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "handleStripeWebhook", null);
__decorate([
    (0, common_1.Post)('stripe/calculate-fee'),
    __param(0, (0, common_1.Body)('amount')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], PaymentsController.prototype, "calculatePlatformFee", null);
exports.PaymentsController = PaymentsController = __decorate([
    (0, common_1.Controller)('payments'),
    __metadata("design:paramtypes", [payments_service_1.PaymentsService,
        stripe_service_1.StripeService])
], PaymentsController);
//# sourceMappingURL=payments.controller.js.map