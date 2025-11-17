import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Query,
} from '@nestjs/common';
import { VerificationService } from './verification.service';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';
import { CreateVerificationRequestDto } from './dto/create-verification-request.dto';
import { UpdateVerificationRequestDto } from './dto/update-verification-request.dto';
import { CreateDocumentDto } from './dto/create-document.dto';
import { UpdateDocumentDto } from './dto/update-document.dto';
import { VerificationRequest, Document, VerificationBadge } from '@prisma/client';

@Controller('verification')
@UseGuards(FirebaseAuthGuard)
export class VerificationController {
  constructor(private readonly verificationService: VerificationService) {}

  @Get()
  findAll() {
    return this.verificationService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.verificationService.findOne(id);
  }

  @Get('user/:userId')
  findByUserId(@Param('userId') userId: string) {
    return this.verificationService.findByUserId(userId);
  }

  @Get('type/:type')
  findByType(@Param('type') type: string) {
    return this.verificationService.findByType(type);
  }

  @Get('status/:status')
  findByStatus(@Param('status') status: string) {
    return this.verificationService.findByStatus(status);
  }

  @Post()
  create(
    @Body()
    verificationData: CreateVerificationRequestDto,
  ) {
    return this.verificationService.create(verificationData);
  }

  @Put(':id')
  update(
    @Param('id') id: string,
    @Body() updateData: UpdateVerificationRequestDto,
  ) {
    return this.verificationService.update(id, updateData);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.verificationService.delete(id);
  }

  @Post(':id/submit')
  submitForReview(@Param('id') id: string) {
    return this.verificationService.submitForReview(id);
  }

  @Post(':id/approve')
  approveRequest(
    @Param('id') id: string,
    @Body('reviewerId') reviewerId: number,
    @Body('notes') notes?: string,
  ) {
    return this.verificationService.approveRequest(
      id,
      reviewerId.toString(),
      notes,
    );
  }

  @Post(':id/reject')
  rejectRequest(
    @Param('id') id: string,
    @Body('reviewerId') reviewerId: number,
    @Body('reason') reason: string,
  ) {
    return this.verificationService.rejectRequest(
      id,
      reviewerId.toString(),
      reason,
    );
  }

  @Post(':requestId/documents')
  addDocument(
    @Param('requestId') requestId: string,
    @Body()
    documentData: CreateDocumentDto,
  ) {
    return this.verificationService.addDocument(
      requestId,
      documentData,
    );
  }

  @Post('documents/:documentId/verify')
  verifyDocument(@Param('documentId') documentId: string) {
    return this.verificationService.verifyDocument(documentId);
  }

  @Post('documents/:documentId/reject')
  rejectDocument(
    @Param('documentId') documentId: string,
    @Body('reason') reason: string,
  ) {
    return this.verificationService.rejectDocument(
      documentId,
      reason,
    );
  }

  @Get('badges/user/:userId')
  getUserBadges(@Param('userId') userId: string) {
    return this.verificationService.getUserBadges(userId);
  }

  @Get('badges')
  getAllBadges() {
    return this.verificationService.getAllBadges();
  }

  @Get('badges/:id')
  getBadgeById(@Param('id') id: string) {
    return this.verificationService.getBadgeById(id);
  }

  @Get('status/:userId')
  getUserVerificationStatus(@Param('userId') userId: string) {
    return this.verificationService.getUserVerificationStatus(userId);
  }

  @Get('pending')
  getPendingVerifications() {
    return this.verificationService.getPendingVerifications();
  }

  @Get('approved')
  getApprovedVerifications() {
    return this.verificationService.getApprovedVerifications();
  }

  @Get('rejected')
  getRejectedVerifications() {
    return this.verificationService.getRejectedVerifications();
  }

  @Get('user/:userId/requests')
  getUserVerificationRequests(@Param('userId') userId: string) {
    return this.verificationService.getUserVerificationRequests(
      userId,
    );
  }

  @Get('expiring')
  getExpiringVerifications(@Query('days') days?: string) {
    return this.verificationService.getExpiringVerifications(
      days ? parseInt(days) : 30,
    );
  }

  @Post(':id/renew')
  renewVerification(@Param('id') id: string) {
    return this.verificationService.renewVerification(id);
  }

  @Get('stats')
  getVerificationStats() {
    return this.verificationService.getVerificationStats();
  }
}
