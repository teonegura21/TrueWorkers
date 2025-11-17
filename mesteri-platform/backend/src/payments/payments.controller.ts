import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  Headers,
  RawBodyRequest,
  Req,
} from '@nestjs/common';
import {
  PaymentsService,
} from './payments.service';
import { StripeService } from './stripe.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { UpdatePaymentDto } from './dto/update-payment.dto';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { UpdateWalletDto } from './dto/update-wallet.dto';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { UpdateWithdrawalDto } from './dto/update-withdrawal.dto';
import { Payment, Wallet, Withdrawal } from '@prisma/client';
import type { Request } from 'express';

@Controller('payments')
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly stripeService: StripeService,
  ) {}

  @Get()
  findAll() {
    return this.paymentsService.findAllPayments();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.paymentsService.findPaymentById(id);
  }

  @Get('user/:userId')
  findByUserId(@Param('userId') userId: string) {
    return this.paymentsService.findPaymentsByUserId(userId);
  }

  @Get('project/:projectId')
  findByProjectId(@Param('projectId') projectId: string) {
    return this.paymentsService.findPaymentsByProjectId(projectId);
  }

  @Get('status/:status')
  findByStatus(@Param('status') status: string) {
    return this.paymentsService.findPaymentsByStatus(status);
  }

  @Get('method/:method')
  findByMethod(@Param('method') method: string) {
    return this.paymentsService.findPaymentsByMethod(method);
  }

  @Post()
  create(
    @Body()
    paymentData: CreatePaymentDto,
  ) {
    return this.paymentsService.createPayment(paymentData);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateData: UpdatePaymentDto) {
    return this.paymentsService.updatePayment(id, updateData);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.paymentsService.deletePayment(id);
  }

  @Post(':id/process')
  processPayment(@Param('id') id: string) {
    return this.paymentsService.processPayment(id);
  }

  @Post(':id/complete')
  completePayment(@Param('id') id: string) {
    return this.paymentsService.completePayment(id);
  }

  @Post(':id/fail')
  failPayment(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.failPayment(id, reason);
  }

  @Post(':id/refund')
  refundPayment(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.refundPayment(id, reason);
  }

  @Post(':id/cancel')
  cancelPayment(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.cancelPayment(id, reason);
  }

  @Post(':id/verify')
  verifyPayment(@Param('id') id: string) {
    return this.paymentsService.verifyPayment(id);
  }

  @Post(':id/reject')
  rejectPayment(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.rejectPayment(id, reason);
  }

  @Post(':id/report')
  reportPayment(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.reportPayment(id, reason);
  }

  // Wallet endpoints
  @Get('wallets')
  findAllWallets() {
    return this.paymentsService.findAllWallets();
  }

  @Get('wallets/:id')
  findWalletById(@Param('id') id: string) {
    return this.paymentsService.findWalletById(id);
  }

  @Get('wallets/user/:userId')
  findWalletByUserId(@Param('userId') userId: string) {
    return this.paymentsService.findWalletByUserId(userId);
  }

  @Post('wallets')
  createWallet(
    @Body()
    walletData: CreateWalletDto,
  ) {
    return this.paymentsService.createWallet(walletData);
  }

  @Put('wallets/:id')
  updateWallet(@Param('id') id: string, @Body() updateData: UpdateWalletDto) {
    return this.paymentsService.updateWallet(id, updateData);
  }

  @Delete('wallets/:id')
  deleteWallet(@Param('id') id: string) {
    return this.paymentsService.deleteWallet(id);
  }

  @Post('wallets/:id/verify')
  verifyWallet(@Param('id') id: string) {
    return this.paymentsService.verifyWallet(id);
  }

  @Post('wallets/:id/suspend')
  suspendWallet(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.suspendWallet(id, reason);
  }

  @Post('wallets/:id/reactivate')
  reactivateWallet(@Param('id') id: string) {
    return this.paymentsService.reactivateWallet(id);
  }

  @Post('wallets/:id/kyc')
  submitKyc(@Param('id') id: string, @Body() kycData: any) {
    return this.paymentsService.submitKyc(id, kycData);
  }

  @Post('wallets/:id/bank-account')
  addBankAccount(@Param('id') id: string, @Body() bankAccountData: any) {
    return this.paymentsService.addBankAccount(id, bankAccountData);
  }

  @Delete('wallets/:id/bank-account/:accountId')
  removeBankAccount(
    @Param('id') id: string,
    @Param('accountId') accountId: string,
  ) {
    return this.paymentsService.removeBankAccount(
      id,
      accountId,
    );
  }

  // Withdrawal endpoints
  @Get('withdrawals')
  findAllWithdrawals() {
    return this.paymentsService.findAllWithdrawals();
  }

  @Get('withdrawals/:id')
  findWithdrawalById(@Param('id') id: string) {
    return this.paymentsService.findWithdrawalById(id);
  }

  @Get('withdrawals/user/:userId')
  findWithdrawalsByUserId(@Param('userId') userId: string) {
    return this.paymentsService.findWithdrawalsByUserId(userId);
  }

  @Get('withdrawals/wallet/:walletId')
  findWithdrawalsByWalletId(@Param('walletId') walletId: string) {
    return this.paymentsService.findWithdrawalsByWalletId(walletId);
  }

  @Get('withdrawals/status/:status')
  findWithdrawalsByStatus(@Param('status') status: string) {
    return this.paymentsService.findWithdrawalsByStatus(status);
  }

  @Post('withdrawals')
  createWithdrawal(
    @Body()
    withdrawalData: CreateWithdrawalDto,
  ) {
    return this.paymentsService.createWithdrawal(withdrawalData);
  }

  @Put('withdrawals/:id')
  updateWithdrawal(
    @Param('id') id: string,
    @Body() updateData: UpdateWithdrawalDto,
  ) {
    return this.paymentsService.updateWithdrawal(id, updateData);
  }

  @Delete('withdrawals/:id')
  deleteWithdrawal(@Param('id') id: string) {
    return this.paymentsService.deleteWithdrawal(id);
  }

  @Post('withdrawals/:id/process')
  processWithdrawal(@Param('id') id: string) {
    return this.paymentsService.processWithdrawal(id);
  }

  @Post('withdrawals/:id/complete')
  completeWithdrawal(@Param('id') id: string) {
    return this.paymentsService.completeWithdrawal(id);
  }

  @Post('withdrawals/:id/fail')
  failWithdrawal(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.failWithdrawal(id, reason);
  }

  @Post('withdrawals/:id/cancel')
  cancelWithdrawal(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.cancelWithdrawal(id, reason);
  }

  @Post('withdrawals/:id/verify')
  verifyWithdrawal(@Param('id') id: string) {
    return this.paymentsService.verifyWithdrawal(id);
  }

  @Post('withdrawals/:id/reject')
  rejectWithdrawal(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.rejectWithdrawal(id, reason);
  }

  @Post('withdrawals/:id/report')
  reportWithdrawal(@Param('id') id: string, @Body('reason') reason: string) {
    return this.paymentsService.reportWithdrawal(id, reason);
  }

  // Analytics endpoints
  @Get('analytics/balance/:userId')
  getUserBalance(@Param('userId') userId: string) {
    return this.paymentsService.getUserBalance(userId);
  }

  @Get('analytics/pending-balance/:userId')
  getUserPendingBalance(@Param('userId') userId: string) {
    return this.paymentsService.getUserPendingBalance(userId);
  }

  @Get('analytics/earnings/:userId')
  getTotalEarnings(@Param('userId') userId: string) {
    return this.paymentsService.getTotalEarnings(userId);
  }

  @Get('analytics/withdrawn/:userId')
  getTotalWithdrawn(@Param('userId') userId: string) {
    return this.paymentsService.getTotalWithdrawn(userId);
  }

  @Get('analytics/history/:userId')
  getPaymentHistory(
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
  ) {
    return this.paymentsService.getPaymentHistory(
      userId,
      limit ? parseInt(limit) : undefined,
    );
  }

  @Get('analytics/recent/:userId')
  getRecentTransactions(
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
  ) {
    return this.paymentsService.getRecentTransactions(
      userId,
      limit ? parseInt(limit) : 10,
    );
  }

  @Get('analytics/monthly/:userId')
  getMonthlyEarnings(@Param('userId') userId: string) {
    return this.paymentsService.getMonthlyEarnings(userId);
  }

  @Get('analytics/stats/:userId')
  getPaymentStats(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentStats(userId);
  }

  @Get('analytics/overview/:userId')
  getPaymentOverview(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentOverview(userId);
  }

  @Get('analytics/trends/:userId')
  getPaymentTrends(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentTrends(userId);
  }

  @Get('analytics/risk/:userId')
  getPaymentRisk(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentRisk(userId);
  }

  @Get('analytics/compliance/:userId')
  getPaymentCompliance(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentCompliance(userId);
  }

  @Get('analytics/security/:userId')
  getPaymentSecurity(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentSecurity(userId);
  }

  @Get('analytics/performance/:userId')
  getPaymentPerformance(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentPerformance(userId);
  }

  @Get('analytics/alerts/:userId')
  getPaymentAlerts(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentAlerts(userId);
  }

  @Get('analytics/recommendations/:userId')
  getPaymentRecommendations(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentRecommendations(userId);
  }

  @Get('analytics/insights/:userId')
  getPaymentInsights(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentInsights(userId);
  }

  @Get('analytics/predictions/:userId')
  getPaymentPredictions(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentPredictions(userId);
  }

  @Get('analytics/forecast/:userId')
  getPaymentForecast(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentForecast(userId);
  }

  @Get('analytics/budget/:userId')
  getPaymentBudget(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentBudget(userId);
  }

  @Get('analytics/goals/:userId')
  getPaymentGoals(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentGoals(userId);
  }

  @Get('analytics/habits/:userId')
  getPaymentHabits(@Param('userId') userId: string) {
    return this.paymentsService.getPaymentHabits(userId);
  }

  @Get('analytics/spending/:userId')
  getSpendingAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getSpendingAnalysis(userId);
  }

  @Get('analytics/income/:userId')
  getIncomeAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getIncomeAnalysis(userId);
  }

  @Get('analytics/net-worth/:userId')
  getNetWorthAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getNetWorthAnalysis(userId);
  }

  @Get('analytics/cash-flow/:userId')
  getCashFlowAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getCashFlowAnalysis(userId);
  }

  @Get('analytics/debt/:userId')
  getDebtAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getDebtAnalysis(userId);
  }

  @Get('analytics/investment/:userId')
  getInvestmentAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getInvestmentAnalysis(userId);
  }

  @Get('analytics/retirement/:userId')
  getRetirementAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getRetirementAnalysis(userId);
  }

  @Get('analytics/insurance/:userId')
  getInsuranceAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getInsuranceAnalysis(userId);
  }

  @Get('analytics/tax/:userId')
  getTaxAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getTaxAnalysis(userId);
  }

  @Get('analytics/credit/:userId')
  getCreditAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getCreditAnalysis(userId);
  }

  @Get('analytics/fraud/:userId')
  getFraudAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getFraudAnalysis(userId);
  }

  @Get('analytics/fees/:userId')
  getFeeAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getFeeAnalysis(userId);
  }

  @Get('analytics/exchange/:userId')
  getExchangeAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getExchangeAnalysis(userId);
  }

  @Get('analytics/international/:userId')
  getInternationalAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getInternationalAnalysis(userId);
  }

  @Get('analytics/crypto/:userId')
  getCryptoAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getCryptoAnalysis(userId);
  }

  @Get('analytics/web3/:userId')
  getWeb3Analysis(@Param('userId') userId: string) {
    return this.paymentsService.getWeb3Analysis(userId);
  }

  @Get('analytics/staking/:userId')
  getStakingAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getStakingAnalysis(userId);
  }

  @Get('analytics/trading/:userId')
  getTradingAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getTradingAnalysis(userId);
  }

  @Get('analytics/portfolio/:userId')
  getPortfolioAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getPortfolioAnalysis(userId);
  }

  @Get('analytics/risk/:userId')
  getRiskAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getRiskAnalysis(userId);
  }

  @Get('analytics/esg/:userId')
  getEsgAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getEsgAnalysis(userId);
  }

  @Get('analytics/market/:userId')
  getMarketAnalysis(@Param('userId') userId: string) {
    return this.paymentsService.getMarketAnalysis(userId);
  }

  // ========== STRIPE INTEGRATION ENDPOINTS ==========
  
  @Post('stripe/create-payment-intent')
  async createStripePayment(
    @Body()
    data: {
      amount: number;
      projectId: string;
      clientId: string;
      craftsmanId: string;
      milestoneId?: string;
    },
  ) {
    return this.stripeService.createPaymentIntent(
      data.amount,
      'ron',
      {
        projectId: data.projectId,
        clientId: data.clientId,
        craftsmanId: data.craftsmanId,
        milestoneId: data.milestoneId,
      },
    );
  }

  @Post('stripe/capture/:paymentIntentId')
  async captureStripePayment(
    @Param('paymentIntentId') paymentIntentId: string,
    @Body('paymentId') paymentId: string,
  ) {
    return this.stripeService.capturePayment(paymentIntentId, paymentId);
  }

  @Post('stripe/refund/:paymentIntentId')
  async refundStripePayment(
    @Param('paymentIntentId') paymentIntentId: string,
    @Body('paymentId') paymentId: string,
    @Body('amount') amount?: number,
  ) {
    return this.stripeService.refundPayment(paymentIntentId, paymentId, amount);
  }

  @Post('stripe/webhook')
  async handleStripeWebhook(
    @Headers('stripe-signature') signature: string,
    @Req() request: any,
  ) {
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    
    try {
      const event = stripe.webhooks.constructEvent(
        request.rawBody,
        signature,
        process.env.STRIPE_WEBHOOK_SECRET,
      );

      await this.stripeService.handleWebhookEvent(event);

      return { received: true };
    } catch (err) {
      return { error: err.message };
    }
  }

  @Post('stripe/calculate-fee')
  calculatePlatformFee(@Body('amount') amount: number) {
    return this.stripeService.calculateFee(amount);
  }
}
