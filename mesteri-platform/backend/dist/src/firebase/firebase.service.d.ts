import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
export declare class FirebaseService {
    private configService;
    private readonly logger;
    private readonly auth;
    private readonly firestore;
    constructor(configService: ConfigService);
    verifyIdToken(idToken: string): Promise<admin.auth.DecodedIdToken>;
    setCustomClaims(uid: string, role: 'client' | 'craftsman', additionalClaims?: Record<string, any>): Promise<void>;
    getUserByUid(uid: string): Promise<admin.auth.UserRecord>;
    getUserByEmail(email: string): Promise<admin.auth.UserRecord>;
    createDocument(collection: string, docId: string, data: any): Promise<void>;
    getDocument(collection: string, docId: string): Promise<any | null>;
    updateDocument(collection: string, docId: string, data: any): Promise<void>;
    deleteUser(uid: string): Promise<void>;
    private filterUndefinedValues;
    createUserProfile(uid: string, profileData: any): Promise<void>;
}
