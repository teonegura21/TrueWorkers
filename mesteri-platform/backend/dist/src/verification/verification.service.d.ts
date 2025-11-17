import { PrismaService } from '../prisma/prisma.service';
import { CreateVerificationRequestDto } from './dto/create-verification-request.dto';
import { UpdateVerificationRequestDto } from './dto/update-verification-request.dto';
import { CreateDocumentDto } from './dto/create-document.dto';
import { VerificationRequest, Document, VerificationBadge } from '@prisma/client';
export declare class VerificationService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<VerificationRequest[]>;
    findOne(id: string): Promise<VerificationRequest | null>;
    findByUserId(userId: string): Promise<VerificationRequest[]>;
    findByType(type: string): Promise<VerificationRequest[]>;
    findByStatus(status: string): Promise<VerificationRequest[]>;
    create(verificationData: CreateVerificationRequestDto): Promise<VerificationRequest>;
    update(id: string, updateData: UpdateVerificationRequestDto): Promise<VerificationRequest | null>;
    delete(id: string): Promise<VerificationRequest>;
    submitForReview(id: string): Promise<VerificationRequest | null>;
    approveRequest(id: string, reviewerid: string, notes?: string): Promise<VerificationRequest | null>;
    rejectRequest(id: string, reviewerid: string, reason: string): Promise<VerificationRequest | null>;
    addDocument(requestid: string, documentData: CreateDocumentDto): Promise<Document>;
    verifyDocument(documentid: string): Promise<Document | null>;
    rejectDocument(documentid: string, reason: string): Promise<Document | null>;
    awardVerificationBadges(userId: string, verificationType: string): Promise<void>;
    private getBadgeTypesForVerification;
    getUserBadges(userId: string): Promise<VerificationBadge[]>;
    getAllBadges(): Promise<VerificationBadge[]>;
    getBadgeById(id: string): Promise<VerificationBadge | null>;
    getUserVerificationStatus(userId: string): Promise<{
        isVerified: boolean;
        verificationLevel: string;
        badges: VerificationBadge[];
        expiringSoon: boolean;
    }>;
    getPendingVerifications(): Promise<VerificationRequest[]>;
    getApprovedVerifications(): Promise<VerificationRequest[]>;
    getRejectedVerifications(): Promise<VerificationRequest[]>;
    getUserVerificationRequests(userId: string): Promise<VerificationRequest[]>;
    getExpiringVerifications(days?: number): Promise<VerificationRequest[]>;
    renewVerification(id: string): Promise<VerificationRequest | null>;
    getVerificationStats(): Promise<{
        total: number;
        pending: number;
        approved: number;
        rejected: number;
        expiringSoon: number;
    }>;
}
