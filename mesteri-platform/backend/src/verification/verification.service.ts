import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateVerificationRequestDto } from './dto/create-verification-request.dto';
import { UpdateVerificationRequestDto } from './dto/update-verification-request.dto';
import { CreateDocumentDto } from './dto/create-document.dto';
import { UpdateDocumentDto } from './dto/update-document.dto';
import { VerificationRequest, Document, VerificationBadge, VerificationRequestStatus, DocumentStatus } from '@prisma/client';

@Injectable()
export class VerificationService {
  constructor(private prisma: PrismaService) {}

  async findAll(): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany();
  }

  async findOne(id: string): Promise<VerificationRequest | null> {
    return this.prisma.verificationRequest.findUnique({ where: { id } });
  }

  async findByUserId(userId: string): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({ where: { userId } });
  }

  async findByType(type: string): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({ where: { type: type as any } });
  }

  async findByStatus(status: string): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({ where: { status: status as VerificationRequestStatus } });
  }

  async create(verificationData: CreateVerificationRequestDto): Promise<VerificationRequest> {
    return this.prisma.verificationRequest.create({
      data: {
        ...verificationData,
        submittedAt: new Date(),
        status: VerificationRequestStatus.PENDING,
      },
    });
  }

  async update(id: string, updateData: UpdateVerificationRequestDto): Promise<VerificationRequest | null> {
    return this.prisma.verificationRequest.update({
      where: { id },
      data: { ...updateData, reviewedAt: new Date() },
    });
  }

  async delete(id: string): Promise<VerificationRequest> {
    return this.prisma.verificationRequest.delete({ where: { id } });
  }

  async submitForReview(id: string): Promise<VerificationRequest | null> {
    const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
    if (!request || request.status !== VerificationRequestStatus.PENDING) {
      return null;
    }
    return this.prisma.verificationRequest.update({
      where: { id },
      data: { status: VerificationRequestStatus.IN_REVIEW, reviewedAt: new Date() },
    });
  }

  async approveRequest(
    id: string,
    reviewerid: string,
    notes?: string,
  ): Promise<VerificationRequest | null> {
    const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
    if (!request || (request.status !== VerificationRequestStatus.IN_REVIEW && request.status !== VerificationRequestStatus.PENDING)) {
      return null;
    }

    const updatedRequest = await this.prisma.verificationRequest.update({
      where: { id },
      data: {
        status: VerificationRequestStatus.APPROVED,
        approvedAt: new Date(),
        reviewerId: reviewerid,
        notes,
        expiresAt: new Date(new Date().setFullYear(new Date().getFullYear() + 1)),
      },
    });

    // Award badges
    await this.awardVerificationBadges(updatedRequest.userId, updatedRequest.type);

    return updatedRequest;
  }

  async rejectRequest(
    id: string,
    reviewerid: string,
    reason: string,
  ): Promise<VerificationRequest | null> {
    const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
    if (!request || (request.status !== VerificationRequestStatus.IN_REVIEW && request.status !== VerificationRequestStatus.PENDING)) {
      return null;
    }
    return this.prisma.verificationRequest.update({
      where: { id },
      data: { status: VerificationRequestStatus.REJECTED, rejectedAt: new Date(), reviewerId: reviewerid, rejectionReason: reason },
    });
  }

  async addDocument(requestid: string, documentData: CreateDocumentDto): Promise<Document> {
    return this.prisma.document.create({
      data: {
        ...documentData,
        verificationRequestId: requestid,
        uploadedAt: new Date(),
        status: DocumentStatus.UPLOADED,
      },
    });
  }

  async verifyDocument(documentid: string): Promise<Document | null> {
    return this.prisma.document.update({
      where: { id: documentid },
      data: { status: DocumentStatus.VERIFIED, verifiedAt: new Date() },
    });
  }

  async rejectDocument(documentid: string, reason: string): Promise<Document | null> {
    return this.prisma.document.update({
      where: { id: documentid },
      data: { status: VerificationRequestStatus.REJECTED, rejectedAt: new Date(), rejectionReason: reason },
    });
  }

  async awardVerificationBadges(userId: string, verificationType: string): Promise<void> {
    // Award appropriate badges based on verification type
    const badgeTypes = this.getBadgeTypesForVerification(verificationType);

    for (const badgeType of badgeTypes) {
      const existingBadge = await this.prisma.verificationBadge.findFirst({
        where: { userId, type: badgeType.type as any },
      });

      if (!existingBadge) {
        await this.prisma.verificationBadge.create({
          data: {
            userId,
            type: badgeType.type as any,
            name: badgeType.name || '',
            description: badgeType.description || '',
            icon: badgeType.icon || '',
            awardedAt: new Date(),
            isActive: true,
          },
        });
      } else {
        // Update existing badge
        await this.prisma.verificationBadge.update({
          where: { id: existingBadge.id },
          data: { isActive: true, awardedAt: new Date() },
        });
      }
    }
  }

  private getBadgeTypesForVerification(
    verificationType: string,
  ): Array<{ type: string; name: string; description: string; icon: string }> {
    const badgeMap: Record<
      string,
      Array<{ type: string; name: string; description: string; icon: string }>
    > = {
      identity: [
        {
          type: DocumentStatus.VERIFIED,
          name: 'Cont Verificat',
          description: 'Identitate verificată',
          icon: DocumentStatus.VERIFIED,
        },
      ],
      business: [
        {
          type: DocumentStatus.VERIFIED,
          name: 'Cont Verificat',
          description: 'Identitate verificată',
          icon: DocumentStatus.VERIFIED,
        },
      ],
      skill: [
        {
          type: 'expert',
          name: 'Expert În Domeniu',
          description: 'Calificări verificate',
          icon: 'award',
        },
      ],
      insurance: [
        {
          type: 'trusted',
          name: 'Meșter Asigurat',
          description: 'Asigurare activă',
          icon: 'shield',
        },
      ],
    };

    return badgeMap[verificationType] || [];
  }

  async getUserBadges(userId: string): Promise<VerificationBadge[]> {
    return this.prisma.verificationBadge.findMany({
      where: { userId, isActive: true },
    });
  }

  async getAllBadges(): Promise<VerificationBadge[]> {
    return this.prisma.verificationBadge.findMany();
  }

  async getBadgeById(id: string): Promise<VerificationBadge | null> {
    return this.prisma.verificationBadge.findUnique({ where: { id } });
  }

  async getUserVerificationStatus(userId: string): Promise<{
    isVerified: boolean;
    verificationLevel: string;
    badges: VerificationBadge[];
    expiringSoon: boolean;
  }> {
    const userBadges = await this.getUserBadges(userId);
    const isVerified = userBadges.some((b) => b.type === DocumentStatus.VERIFIED);

    let verificationLevel = 'basic';
    if (userBadges.some((b) => b.type === 'premium')) {
      verificationLevel = 'premium';
    } else if (isVerified) {
      verificationLevel = DocumentStatus.VERIFIED;
    }

    const expiringSoon = userBadges.some(
      (badge) =>
        badge.expiresAt &&
        new Date(badge.expiresAt) <
          new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    );

    return {
      isVerified,
      verificationLevel,
      badges: userBadges,
      expiringSoon,
    };
  }

  async getPendingVerifications(): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({
      where: { OR: [{ status: VerificationRequestStatus.PENDING }, { status: VerificationRequestStatus.IN_REVIEW }] },
    });
  }

  async getApprovedVerifications(): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({ where: { status: VerificationRequestStatus.APPROVED } });
  }

  async getRejectedVerifications(): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({ where: { status: VerificationRequestStatus.REJECTED } });
  }

  async getUserVerificationRequests(userId: string): Promise<VerificationRequest[]> {
    return this.prisma.verificationRequest.findMany({ where: { userId } });
  }

  async getExpiringVerifications(days: number = 30): Promise<VerificationRequest[]> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() + days);

    return this.prisma.verificationRequest.findMany({
      where: {
        status: VerificationRequestStatus.APPROVED,
        expiresAt: { lt: cutoffDate },
      },
    });
  }

  async renewVerification(id: string): Promise<VerificationRequest | null> {
    const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
    if (!request || request.status !== VerificationRequestStatus.APPROVED || !request.expiresAt) {
      return null;
    }
    return this.prisma.verificationRequest.update({
      where: { id },
      data: {
        expiresAt: new Date(new Date(request.expiresAt).setFullYear(new Date().getFullYear() + 1)),
      },
    });
  }

  async getVerificationStats(): Promise<{
    total: number;
    pending: number;
    approved: number;
    rejected: number;
    expiringSoon: number;
  }> {
    const total = await this.prisma.verificationRequest.count();
    const pending = await this.prisma.verificationRequest.count({ where: { status: VerificationRequestStatus.PENDING } });
    const approved = await this.prisma.verificationRequest.count({ where: { status: VerificationRequestStatus.APPROVED } });
    const rejected = await this.prisma.verificationRequest.count({ where: { status: VerificationRequestStatus.REJECTED } });
    const expiringSoonRequests = await this.getExpiringVerifications(30);
    const expiringSoon = expiringSoonRequests.length;

    return {
      total,
      pending,
      approved,
      rejected,
      expiringSoon,
    };
  }
}
